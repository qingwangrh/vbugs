import requests

import re
# from bs4 import BeautifulSoup
# from lxml import etree
# from selenium import webdriver

url = 'http://www.ok226.com'
url = 'https://brewweb.engineering.redhat.com/brew/taskinfo?taskID=29611480'
r = requests.get(url)
r.encoding = 'gb2312'


# ÀûÓÃ re £¨Ì«»ÆÌ«±©Á¦£¡£©
matchs = re.findall(r"(?<=href=\").+?(?=\")|(?<=href=\').+?(?=\')" , r.text)
for link in matchs:
    print(link)
    
print()


# ÀûÓÃ BeautifulSoup4 £¨DOMÊ÷£©
# soup = BeautifulSoup(r.text,'lxml')
# for a in soup.find_all('a'):
#     link = a['href']
#     print(link)
#
# print()

