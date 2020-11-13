# -machine q35,accel=kvm \

/usr/libexec/qemu-kvm \
    -name 'avocado-vt-vm1'  \
    -sandbox on  \
    -machine q35,accel=kvm \
    -device pcie-root-port,id=pcie-root-port-0,multifunction=on,bus=pcie.0,addr=0x1,chassis=1 \
    -device pcie-pci-bridge,id=pcie-pci-bridge-0,addr=0x0,bus=pcie-root-port-0  \
    -nodefaults \
    -device VGA,bus=pcie.0,addr=0x2 \
    -m 16G  \
    -smp 10,maxcpus=10,cores=5,threads=1,dies=1,sockets=2  \
    -device pcie-root-port,id=pcie-root-port-1,port=0x1,addr=0x1.0x1,bus=pcie.0,chassis=2 \
    -device qemu-xhci,id=usb1,bus=pcie-root-port-1,addr=0x0 \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
    -object iothread,id=iothread0 \
    -object iothread,id=iothread1 \
    -device pcie-root-port,id=pcie-root-port-2,port=0x2,addr=0x1.0x2,bus=pcie.0,chassis=3 \
    -device virtio-scsi-pci,id=virtio_scsi_pci0,bus=pcie-root-port-2,addr=0x0,iothread=iothread0 \
    -blockdev node-name=file_image1,driver=file,aio=native,filename=/home/kvm_autotest_root/images/rhel830-64-virtio-scsi.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_image1,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_image1 \
    -device scsi-hd,id=image1,drive=drive_image1,bootindex=0,write-cache=on \
    -device pcie-root-port,id=pcie-root-port-3,port=0x3,addr=0x1.0x3,bus=pcie.0,chassis=4 \
    -device virtio-net-pci,mac=9a:88:7a:d3:8b:74,id=id9QVzBa,netdev=idEb8qPI,bus=pcie-root-port-3,addr=0x0  \
    -netdev tap,id=idEb8qPI,vhost=on  \
    -rtc base=utc,clock=host,driftfix=slew  \
    -boot menu=off,order=cdn,once=c,strict=off \
    -enable-kvm \
    -device pcie-root-port,id=pcie_extra_root_port_0,multifunction=on,bus=pcie.0,addr=0x3,chassis=5 \
    -device pcie-root-port,id=pcie_extra_root_port_1,addr=0x3.0x1,bus=pcie.0,chassis=6 \
    -device pcie-root-port,id=pcie_extra_root_port_2,addr=0x3.0x2,bus=pcie.0,chassis=7 \
    -device pcie-root-port,id=pcie_extra_root_port_3,addr=0x3.0x3,bus=pcie.0,chassis=8 \
    -device pcie-root-port,id=pcie_extra_root_port_4,addr=0x3.0x4,bus=pcie.0,chassis=9 \
    -device pcie-root-port,id=pcie_extra_root_port_5,addr=0x3.0x5,bus=pcie.0,chassis=10 \
    -device pcie-root-port,id=pcie_extra_root_port_6,addr=0x3.0x6,bus=pcie.0,chassis=11 \
    -device pcie-root-port,id=pcie_extra_root_port_7,addr=0x3.0x7,bus=pcie.0,chassis=12 \
    -device pcie-root-port,id=pcie_extra_root_port_8,multifunction=on,bus=pcie.0,addr=0x4,chassis=13 \
    -device pcie-root-port,id=pcie_extra_root_port_9,addr=0x4.0x1,bus=pcie.0,chassis=14 \
    -device pcie-root-port,id=pcie_extra_root_port_10,addr=0x4.0x2,bus=pcie.0,chassis=15 \
    -device pcie-root-port,id=pcie_extra_root_port_11,addr=0x4.0x3,bus=pcie.0,chassis=16 \
    -device pcie-root-port,id=pcie_extra_root_port_12,addr=0x4.0x4,bus=pcie.0,chassis=17 \
    -device pcie-root-port,id=pcie_extra_root_port_13,addr=0x4.0x5,bus=pcie.0,chassis=18 \
    -device pcie-root-port,id=pcie_extra_root_port_14,addr=0x4.0x6,bus=pcie.0,chassis=19 \
    -device pcie-root-port,id=pcie_extra_root_port_15,addr=0x4.0x7,bus=pcie.0,chassis=20 \
    -device pcie-root-port,id=pcie_extra_root_port_16,multifunction=on,bus=pcie.0,addr=0x5,chassis=21 \
    -device pcie-root-port,id=pcie_extra_root_port_17,addr=0x5.0x1,bus=pcie.0,chassis=22 \
    -device pcie-root-port,id=pcie_extra_root_port_18,addr=0x5.0x2,bus=pcie.0,chassis=23 \
    -device pcie-root-port,id=pcie_extra_root_port_19,addr=0x5.0x3,bus=pcie.0,chassis=24 \
    -device pcie-root-port,id=pcie_extra_root_port_20,addr=0x5.0x4,bus=pcie.0,chassis=25 \
    -device pcie-root-port,id=pcie_extra_root_port_21,addr=0x5.0x5,bus=pcie.0,chassis=26 \
    -device pcie-root-port,id=pcie_extra_root_port_22,addr=0x5.0x6,bus=pcie.0,chassis=27 \
    -device pcie-root-port,id=pcie_extra_root_port_23,addr=0x5.0x7,bus=pcie.0,chassis=28 \
    -device pcie-root-port,id=pcie_extra_root_port_24,multifunction=on,bus=pcie.0,addr=0x6,chassis=29 \
    -device pcie-root-port,id=pcie_extra_root_port_25,addr=0x6.0x1,bus=pcie.0,chassis=30 \
    -device pcie-root-port,id=pcie_extra_root_port_26,addr=0x6.0x2,bus=pcie.0,chassis=31 \
    -device pcie-root-port,id=pcie_extra_root_port_27,addr=0x6.0x3,bus=pcie.0,chassis=32 \
    -device pcie-root-port,id=pcie_extra_root_port_28,addr=0x6.0x4,bus=pcie.0,chassis=33 \
    -device pcie-root-port,id=pcie_extra_root_port_29,addr=0x6.0x5,bus=pcie.0,chassis=34 \
    -device pcie-root-port,id=pcie_extra_root_port_30,addr=0x6.0x6,bus=pcie.0,chassis=35 \
    -device pcie-root-port,id=pcie_extra_root_port_31,addr=0x6.0x7,bus=pcie.0,chassis=36 \
    -device pcie-root-port,id=pcie_extra_root_port_32,multifunction=on,bus=pcie.0,addr=0x7,chassis=37 \
    -device pcie-root-port,id=pcie_extra_root_port_33,addr=0x7.0x1,bus=pcie.0,chassis=38 \
    -device pcie-root-port,id=pcie_extra_root_port_34,addr=0x7.0x2,bus=pcie.0,chassis=39 \
    -device pcie-root-port,id=pcie_extra_root_port_35,addr=0x7.0x3,bus=pcie.0,chassis=40 \
    -device pcie-root-port,id=pcie_extra_root_port_36,addr=0x7.0x4,bus=pcie.0,chassis=41 \
    -device pcie-root-port,id=pcie_extra_root_port_37,addr=0x7.0x5,bus=pcie.0,chassis=42 \
    -device pcie-root-port,id=pcie_extra_root_port_38,addr=0x7.0x6,bus=pcie.0,chassis=43 \
    -device pcie-root-port,id=pcie_extra_root_port_39,addr=0x7.0x7,bus=pcie.0,chassis=44 \
    -device pcie-root-port,id=pcie_extra_root_port_40,multifunction=on,bus=pcie.0,addr=0x8,chassis=45 \
    -device pcie-root-port,id=pcie_extra_root_port_41,addr=0x8.0x1,bus=pcie.0,chassis=46 \
    -device pcie-root-port,id=pcie_extra_root_port_42,addr=0x8.0x2,bus=pcie.0,chassis=47 \
    -device pcie-root-port,id=pcie_extra_root_port_43,addr=0x8.0x3,bus=pcie.0,chassis=48 \
    -device pcie-root-port,id=pcie_extra_root_port_44,addr=0x8.0x4,bus=pcie.0,chassis=49 \
    -device pcie-root-port,id=pcie_extra_root_port_45,addr=0x8.0x5,bus=pcie.0,chassis=50 \
    -device pcie-root-port,id=pcie_extra_root_port_46,addr=0x8.0x6,bus=pcie.0,chassis=51 \
    -device pcie-root-port,id=pcie_extra_root_port_47,addr=0x8.0x7,bus=pcie.0,chassis=52 \
    -device pcie-root-port,id=pcie_extra_root_port_48,multifunction=on,bus=pcie.0,addr=0x9,chassis=53 \
    -device pcie-root-port,id=pcie_extra_root_port_49,addr=0x9.0x1,bus=pcie.0,chassis=54 \
    -device pcie-root-port,id=pcie_extra_root_port_50,addr=0x9.0x2,bus=pcie.0,chassis=55 \
    -device pcie-root-port,id=pcie_extra_root_port_51,addr=0x9.0x3,bus=pcie.0,chassis=56 \
    -device pcie-root-port,id=pcie_extra_root_port_52,addr=0x9.0x4,bus=pcie.0,chassis=57 \
    -device pcie-root-port,id=pcie_extra_root_port_53,addr=0x9.0x5,bus=pcie.0,chassis=58 \
    -device pcie-root-port,id=pcie_extra_root_port_54,addr=0x9.0x6,bus=pcie.0,chassis=59 \
    -device pcie-root-port,id=pcie_extra_root_port_55,addr=0x9.0x7,bus=pcie.0,chassis=60 \
    -device pcie-root-port,id=pcie_extra_root_port_56,multifunction=on,bus=pcie.0,addr=0xa,chassis=61 \
    -device pcie-root-port,id=pcie_extra_root_port_57,addr=0xa.0x1,bus=pcie.0,chassis=62 \
    -device pcie-root-port,id=pcie_extra_root_port_58,addr=0xa.0x2,bus=pcie.0,chassis=63 \
    -device pcie-root-port,id=pcie_extra_root_port_59,addr=0xa.0x3,bus=pcie.0,chassis=64 \
    -device pcie-root-port,id=pcie_extra_root_port_60,addr=0xa.0x4,bus=pcie.0,chassis=65 \
    -device pcie-root-port,id=pcie_extra_root_port_61,addr=0xa.0x5,bus=pcie.0,chassis=66 \
    -device pcie-root-port,id=pcie_extra_root_port_62,addr=0xa.0x6,bus=pcie.0,chassis=67 \
    -device pcie-root-port,id=pcie_extra_root_port_63,addr=0xa.0x7,bus=pcie.0,chassis=68 \
    -device pcie-root-port,id=pcie_extra_root_port_64,multifunction=on,bus=pcie.0,addr=0xb,chassis=69 \
    -device pcie-root-port,id=pcie_extra_root_port_65,addr=0xb.0x1,bus=pcie.0,chassis=70 \
    -device pcie-root-port,id=pcie_extra_root_port_66,addr=0xb.0x2,bus=pcie.0,chassis=71 \
    -device pcie-root-port,id=pcie_extra_root_port_67,addr=0xb.0x3,bus=pcie.0,chassis=72 \
    -device pcie-root-port,id=pcie_extra_root_port_68,addr=0xb.0x4,bus=pcie.0,chassis=73 \
    -device pcie-root-port,id=pcie_extra_root_port_69,addr=0xb.0x5,bus=pcie.0,chassis=74 \
    -device pcie-root-port,id=pcie_extra_root_port_70,addr=0xb.0x6,bus=pcie.0,chassis=75 \
    -device pcie-root-port,id=pcie_extra_root_port_71,addr=0xb.0x7,bus=pcie.0,chassis=76 \
    -device pcie-root-port,id=pcie_extra_root_port_72,multifunction=on,bus=pcie.0,addr=0xc,chassis=77 \
    -device pcie-root-port,id=pcie_extra_root_port_73,addr=0xc.0x1,bus=pcie.0,chassis=78 \
    -device pcie-root-port,id=pcie_extra_root_port_74,addr=0xc.0x2,bus=pcie.0,chassis=79 \
    -device pcie-root-port,id=pcie_extra_root_port_75,addr=0xc.0x3,bus=pcie.0,chassis=80 \
    -device pcie-root-port,id=pcie_extra_root_port_76,addr=0xc.0x4,bus=pcie.0,chassis=81 \
    -device pcie-root-port,id=pcie_extra_root_port_77,addr=0xc.0x5,bus=pcie.0,chassis=82 \
    -device pcie-root-port,id=pcie_extra_root_port_78,addr=0xc.0x6,bus=pcie.0,chassis=83 \
    -device pcie-root-port,id=pcie_extra_root_port_79,addr=0xc.0x7,bus=pcie.0,chassis=84 \
    -device pcie-root-port,id=pcie_extra_root_port_80,multifunction=on,bus=pcie.0,addr=0xd,chassis=85 \
    -device pcie-root-port,id=pcie_extra_root_port_81,addr=0xd.0x1,bus=pcie.0,chassis=86 \
    -device pcie-root-port,id=pcie_extra_root_port_82,addr=0xd.0x2,bus=pcie.0,chassis=87 \
    -device pcie-root-port,id=pcie_extra_root_port_83,addr=0xd.0x3,bus=pcie.0,chassis=88 \
    -device pcie-root-port,id=pcie_extra_root_port_84,addr=0xd.0x4,bus=pcie.0,chassis=89 \
    -device pcie-root-port,id=pcie_extra_root_port_85,addr=0xd.0x5,bus=pcie.0,chassis=90 \
    -device pcie-root-port,id=pcie_extra_root_port_86,addr=0xd.0x6,bus=pcie.0,chassis=91 \
    -device pcie-root-port,id=pcie_extra_root_port_87,addr=0xd.0x7,bus=pcie.0,chassis=92 \
    -device pcie-root-port,id=pcie_extra_root_port_88,multifunction=on,bus=pcie.0,addr=0xe,chassis=93 \
    -device pcie-root-port,id=pcie_extra_root_port_89,addr=0xe.0x1,bus=pcie.0,chassis=94 \
    -device pcie-root-port,id=pcie_extra_root_port_90,addr=0xe.0x2,bus=pcie.0,chassis=95 \
    -device pcie-root-port,id=pcie_extra_root_port_91,addr=0xe.0x3,bus=pcie.0,chassis=96 \
    -device pcie-root-port,id=pcie_extra_root_port_92,addr=0xe.0x4,bus=pcie.0,chassis=97 \
    -device pcie-root-port,id=pcie_extra_root_port_93,addr=0xe.0x5,bus=pcie.0,chassis=98 \
    -device pcie-root-port,id=pcie_extra_root_port_94,addr=0xe.0x6,bus=pcie.0,chassis=99 \
    -device pcie-root-port,id=pcie_extra_root_port_95,addr=0xe.0x7,bus=pcie.0,chassis=100 \
    -device pcie-root-port,id=pcie_extra_root_port_96,multifunction=on,bus=pcie.0,addr=0xf,chassis=101 \
    -device pcie-root-port,id=pcie_extra_root_port_97,addr=0xf.0x1,bus=pcie.0,chassis=102 \
    -device pcie-root-port,id=pcie_extra_root_port_98,addr=0xf.0x2,bus=pcie.0,chassis=103 \
    -device pcie-root-port,id=pcie_extra_root_port_99,addr=0xf.0x3,bus=pcie.0,chassis=104 \
    -device pcie-root-port,id=pcie_extra_root_port_100,addr=0xf.0x4,bus=pcie.0,chassis=105 \
    -device pcie-root-port,id=pcie_extra_root_port_101,addr=0xf.0x5,bus=pcie.0,chassis=106 \
    -device pcie-root-port,id=pcie_extra_root_port_102,addr=0xf.0x6,bus=pcie.0,chassis=107 \
    -device pcie-root-port,id=pcie_extra_root_port_103,addr=0xf.0x7,bus=pcie.0,chassis=108 \
    -device pcie-root-port,id=pcie_extra_root_port_104,multifunction=on,bus=pcie.0,addr=0x10,chassis=109 \
    -device pcie-root-port,id=pcie_extra_root_port_105,addr=0x10.0x1,bus=pcie.0,chassis=110 \
    -device pcie-root-port,id=pcie_extra_root_port_106,addr=0x10.0x2,bus=pcie.0,chassis=111 \
    -device pcie-root-port,id=pcie_extra_root_port_107,addr=0x10.0x3,bus=pcie.0,chassis=112 \
    -device pcie-root-port,id=pcie_extra_root_port_108,addr=0x10.0x4,bus=pcie.0,chassis=113 \
    -device pcie-root-port,id=pcie_extra_root_port_109,addr=0x10.0x5,bus=pcie.0,chassis=114 \
    -device pcie-root-port,id=pcie_extra_root_port_110,addr=0x10.0x6,bus=pcie.0,chassis=115 \
    -device pcie-root-port,id=pcie_extra_root_port_111,addr=0x10.0x7,bus=pcie.0,chassis=116 \
    -device pcie-root-port,id=pcie_extra_root_port_112,multifunction=on,bus=pcie.0,addr=0x11,chassis=117 \
    -device pcie-root-port,id=pcie_extra_root_port_113,addr=0x11.0x1,bus=pcie.0,chassis=118 \
    -device pcie-root-port,id=pcie_extra_root_port_114,addr=0x11.0x2,bus=pcie.0,chassis=119 \
    -device pcie-root-port,id=pcie_extra_root_port_115,addr=0x11.0x3,bus=pcie.0,chassis=120 \
    -device pcie-root-port,id=pcie_extra_root_port_116,addr=0x11.0x4,bus=pcie.0,chassis=121 \
    -device pcie-root-port,id=pcie_extra_root_port_117,addr=0x11.0x5,bus=pcie.0,chassis=122 \
    -device pcie-root-port,id=pcie_extra_root_port_118,addr=0x11.0x6,bus=pcie.0,chassis=123 \
    -device pcie-root-port,id=pcie_extra_root_port_119,addr=0x11.0x7,bus=pcie.0,chassis=124 \
    -device pcie-root-port,id=pcie_extra_root_port_120,multifunction=on,bus=pcie.0,addr=0x12,chassis=125 \
    -device pcie-root-port,id=pcie_extra_root_port_121,addr=0x12.0x1,bus=pcie.0,chassis=126 \
    -device pcie-root-port,id=pcie_extra_root_port_122,addr=0x12.0x2,bus=pcie.0,chassis=127 \
    -device pcie-root-port,id=pcie_extra_root_port_123,addr=0x12.0x3,bus=pcie.0,chassis=128 \
    -device pcie-root-port,id=pcie_extra_root_port_124,addr=0x12.0x4,bus=pcie.0,chassis=129 \
    -device pcie-root-port,id=pcie_extra_root_port_125,addr=0x12.0x5,bus=pcie.0,chassis=130 \
    -device pcie-root-port,id=pcie_extra_root_port_126,addr=0x12.0x6,bus=pcie.0,chassis=131 \
    -device pcie-root-port,id=pcie_extra_root_port_127,addr=0x12.0x7,bus=pcie.0,chassis=132 \
    -device pcie-root-port,id=pcie_extra_root_port_128,multifunction=on,bus=pcie.0,addr=0x13,chassis=133 \
    -device pcie-root-port,id=pcie_extra_root_port_129,addr=0x13.0x1,bus=pcie.0,chassis=134 \
    -device pcie-root-port,id=pcie_extra_root_port_130,addr=0x13.0x2,bus=pcie.0,chassis=135 \
    -device pcie-root-port,id=pcie_extra_root_port_131,addr=0x13.0x3,bus=pcie.0,chassis=136 \
    -device pcie-root-port,id=pcie_extra_root_port_132,addr=0x13.0x4,bus=pcie.0,chassis=137 \
    -device pcie-root-port,id=pcie_extra_root_port_133,addr=0x13.0x5,bus=pcie.0,chassis=138 \
    -device pcie-root-port,id=pcie_extra_root_port_134,addr=0x13.0x6,bus=pcie.0,chassis=139 \
    -device pcie-root-port,id=pcie_extra_root_port_135,addr=0x13.0x7,bus=pcie.0,chassis=140 \
    -device pcie-root-port,id=pcie_extra_root_port_136,multifunction=on,bus=pcie.0,addr=0x14,chassis=141 \
    -device pcie-root-port,id=pcie_extra_root_port_137,addr=0x14.0x1,bus=pcie.0,chassis=142 \
    -device pcie-root-port,id=pcie_extra_root_port_138,addr=0x14.0x2,bus=pcie.0,chassis=143 \
    -device pcie-root-port,id=pcie_extra_root_port_139,addr=0x14.0x3,bus=pcie.0,chassis=144 \
    -device pcie-root-port,id=pcie_extra_root_port_140,addr=0x14.0x4,bus=pcie.0,chassis=145 \
    -device pcie-root-port,id=pcie_extra_root_port_141,addr=0x14.0x5,bus=pcie.0,chassis=146 \
    -device pcie-root-port,id=pcie_extra_root_port_142,addr=0x14.0x6,bus=pcie.0,chassis=147 \
    -device pcie-root-port,id=pcie_extra_root_port_143,addr=0x14.0x7,bus=pcie.0,chassis=148 \
    -device pcie-root-port,id=pcie_extra_root_port_144,multifunction=on,bus=pcie.0,addr=0x15,chassis=149 \
    -device pcie-root-port,id=pcie_extra_root_port_145,addr=0x15.0x1,bus=pcie.0,chassis=150 \
    -device pcie-root-port,id=pcie_extra_root_port_146,addr=0x15.0x2,bus=pcie.0,chassis=151 \
    -device pcie-root-port,id=pcie_extra_root_port_147,addr=0x15.0x3,bus=pcie.0,chassis=152 \
    -device pcie-root-port,id=pcie_extra_root_port_148,addr=0x15.0x4,bus=pcie.0,chassis=153 \
    -device pcie-root-port,id=pcie_extra_root_port_149,addr=0x15.0x5,bus=pcie.0,chassis=154 \
    -device pcie-root-port,id=pcie_extra_root_port_150,addr=0x15.0x6,bus=pcie.0,chassis=155 \
    -device pcie-root-port,id=pcie_extra_root_port_151,addr=0x15.0x7,bus=pcie.0,chassis=156 \
    -device pcie-root-port,id=pcie_extra_root_port_152,multifunction=on,bus=pcie.0,addr=0x16,chassis=157 \
    -device pcie-root-port,id=pcie_extra_root_port_153,addr=0x16.0x1,bus=pcie.0,chassis=158 \
    -device pcie-root-port,id=pcie_extra_root_port_154,addr=0x16.0x2,bus=pcie.0,chassis=159 \
    -device pcie-root-port,id=pcie_extra_root_port_155,addr=0x16.0x3,bus=pcie.0,chassis=160 \
    -device pcie-root-port,id=pcie_extra_root_port_156,addr=0x16.0x4,bus=pcie.0,chassis=161 \
    -device pcie-root-port,id=pcie_extra_root_port_157,addr=0x16.0x5,bus=pcie.0,chassis=162 \
    -device pcie-root-port,id=pcie_extra_root_port_158,addr=0x16.0x6,bus=pcie.0,chassis=163 \
    -device pcie-root-port,id=pcie_extra_root_port_159,addr=0x16.0x7,bus=pcie.0,chassis=164 \
    -device pcie-root-port,id=pcie_extra_root_port_160,multifunction=on,bus=pcie.0,addr=0x17,chassis=165 \
    -device pcie-root-port,id=pcie_extra_root_port_161,addr=0x17.0x1,bus=pcie.0,chassis=166 \
    -device pcie-root-port,id=pcie_extra_root_port_162,addr=0x17.0x2,bus=pcie.0,chassis=167 \
    -device pcie-root-port,id=pcie_extra_root_port_163,addr=0x17.0x3,bus=pcie.0,chassis=168 \
    -device pcie-root-port,id=pcie_extra_root_port_164,addr=0x17.0x4,bus=pcie.0,chassis=169 \
    -device pcie-root-port,id=pcie_extra_root_port_165,addr=0x17.0x5,bus=pcie.0,chassis=170 \
    -device pcie-root-port,id=pcie_extra_root_port_166,addr=0x17.0x6,bus=pcie.0,chassis=171 \
    -device pcie-root-port,id=pcie_extra_root_port_167,addr=0x17.0x7,bus=pcie.0,chassis=172 \
    -device pcie-root-port,id=pcie_extra_root_port_168,multifunction=on,bus=pcie.0,addr=0x18,chassis=173 \
    -device pcie-root-port,id=pcie_extra_root_port_169,addr=0x18.0x1,bus=pcie.0,chassis=174 \
    -device pcie-root-port,id=pcie_extra_root_port_170,addr=0x18.0x2,bus=pcie.0,chassis=175 \
    -device pcie-root-port,id=pcie_extra_root_port_171,addr=0x18.0x3,bus=pcie.0,chassis=176 \
    -device pcie-root-port,id=pcie_extra_root_port_172,addr=0x18.0x4,bus=pcie.0,chassis=177 \
    -device pcie-root-port,id=pcie_extra_root_port_173,addr=0x18.0x5,bus=pcie.0,chassis=178 \
    -device pcie-root-port,id=pcie_extra_root_port_174,addr=0x18.0x6,bus=pcie.0,chassis=179 \
    -device pcie-root-port,id=pcie_extra_root_port_175,addr=0x18.0x7,bus=pcie.0,chassis=180 \
    -device pcie-root-port,id=pcie_extra_root_port_176,multifunction=on,bus=pcie.0,addr=0x19,chassis=181 \
    -device pcie-root-port,id=pcie_extra_root_port_177,addr=0x19.0x1,bus=pcie.0,chassis=182 \
    -device pcie-root-port,id=pcie_extra_root_port_178,addr=0x19.0x2,bus=pcie.0,chassis=183 \
    -device pcie-root-port,id=pcie_extra_root_port_179,addr=0x19.0x3,bus=pcie.0,chassis=184 \
    -device pcie-root-port,id=pcie_extra_root_port_180,addr=0x19.0x4,bus=pcie.0,chassis=185 \
    -device pcie-root-port,id=pcie_extra_root_port_181,addr=0x19.0x5,bus=pcie.0,chassis=186 \
    -device pcie-root-port,id=pcie_extra_root_port_182,addr=0x19.0x6,bus=pcie.0,chassis=187 \
    -device pcie-root-port,id=pcie_extra_root_port_183,addr=0x19.0x7,bus=pcie.0,chassis=188 \
    -device pcie-root-port,id=pcie_extra_root_port_184,multifunction=on,bus=pcie.0,addr=0x1a,chassis=189 \
    -device pcie-root-port,id=pcie_extra_root_port_185,addr=0x1a.0x1,bus=pcie.0,chassis=190 \
    -device pcie-root-port,id=pcie_extra_root_port_186,addr=0x1a.0x2,bus=pcie.0,chassis=191 \
    -device pcie-root-port,id=pcie_extra_root_port_187,addr=0x1a.0x3,bus=pcie.0,chassis=192 \
    -device pcie-root-port,id=pcie_extra_root_port_188,addr=0x1a.0x4,bus=pcie.0,chassis=193 \
    -device pcie-root-port,id=pcie_extra_root_port_189,addr=0x1a.0x5,bus=pcie.0,chassis=194 \
    -device pcie-root-port,id=pcie_extra_root_port_190,addr=0x1a.0x6,bus=pcie.0,chassis=195 \
    -device pcie-root-port,id=pcie_extra_root_port_191,addr=0x1a.0x7,bus=pcie.0,chassis=196 \
    -device pcie-root-port,id=pcie_extra_root_port_192,multifunction=on,bus=pcie.0,addr=0x1b,chassis=197 \
    -device pcie-root-port,id=pcie_extra_root_port_193,addr=0x1b.0x1,bus=pcie.0,chassis=198 \
    -device pcie-root-port,id=pcie_extra_root_port_194,addr=0x1b.0x2,bus=pcie.0,chassis=199 \
    -device pcie-root-port,id=pcie_extra_root_port_195,addr=0x1b.0x3,bus=pcie.0,chassis=200 \
    -device pcie-root-port,id=pcie_extra_root_port_196,addr=0x1b.0x4,bus=pcie.0,chassis=201 \
    -device pcie-root-port,id=pcie_extra_root_port_197,addr=0x1b.0x5,bus=pcie.0,chassis=202 \
    -device pcie-root-port,id=pcie_extra_root_port_198,addr=0x1b.0x6,bus=pcie.0,chassis=203 \
    -device pcie-root-port,id=pcie_extra_root_port_199,addr=0x1b.0x7,bus=pcie.0,chassis=204 \
    -monitor stdio \
    -chardev file,id=qmp_id_qmpmonitor1,path=/var/tmp/monitor-qmpdbg.log,server,nowait \
    -mon chardev=qmp_id_qmpmonitor1,mode=control  \
    -qmp tcp:0:5955,server,nowait  \
    -vnc :5  \
    -chardev file,path=/var/tmp/monitor-serialdbg.log,id=serial_id_serial0 \
    -device isa-serial,chardev=serial_id_serial0  \

steps(){
  wloop 1 210 qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg@@.qcow2 128M

{'execute':'qmp_capabilities'}
{'execute': 'blockdev-add', 'arguments': {'node-name': 'file_stg1', 'driver': 'file','filename': '/home/kvm_autotest_root/images/stg1.qcow2' }}
{'execute': 'blockdev-add', 'arguments': {'node-name': 'drive_stg1', 'driver': 'qcow2', 'file': 'file_stg1'}}
{'execute': 'device_add', 'arguments': {'id': 'virtio_scsi_pci1', 'driver': 'virtio-scsi-pci', 'bus':'pcie_extra_root_port_0','addr':'0x0', 'iothread':'iothread1'}}
{'execute': 'device_add', 'arguments':{'driver':'scsi-hd', 'id':'stg1', 'bus':'virtio_scsi_pci1.0', 'drive':'drive_stg1'}}

{'execute': 'device_del', 'arguments': {'id': 'stg1'}}
{'execute': 'blockdev-del', 'arguments': {'node-name': 'drive_stg1'}}
{'execute': 'blockdev-del', 'arguments': {'node-name': 'file_stg1'}}
{'execute': 'device_del', 'arguments': {'id': 'virtio_scsi_pci1'}}

  wqmp_loop 1 190 "
{'execute': 'blockdev-add', 'arguments': {'node-name': 'file_stg@@', 'driver': 'file','filename': '/home/kvm_autotest_root/images/stg@@.qcow2' }}
;{'execute': 'blockdev-add', 'arguments': {'node-name': 'drive_stg@@', 'driver': 'qcow2', 'file': 'file_stg@@'}}
;{'execute': 'device_add', 'arguments': {'id': 'virtio_scsi_pci@@', 'driver': 'virtio-scsi-pci', 'bus':'pcie_extra_root_port_@@','addr':'0x0', 'iothread':'iothread1'}}
;{'execute': 'device_add', 'arguments':{'driver':'scsi-hd', 'id':'stg@@', 'bus':'virtio_scsi_pci@@.0', 'drive':'drive_stg@@'}}
;sleep 0.3
"



}

