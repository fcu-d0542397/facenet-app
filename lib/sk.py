#!/usr/bin/python3
# -*- coding: UTF-8 -*-
import socket
import struct

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)      
host = socket.gethostname()
port = 9999               
s.bind((host, port))
s.listen(1)

client, addr = s.accept()
print ('Got connected from', addr)

buf = b''
while len(buf) < 4:

    buf += client.recv(4-len(buf))
size = struct.unpack('!i', buf)
print ("receiving %s bytes" % size)

with open('tst.jpg', 'wb') as img:
    while True:
        data = client.recv(1024)
        if not data:
            break
        img.write(data)
print ('Received, yay!')

client.close()