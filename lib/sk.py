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
print('Got connected from', addr)

buf = client.recv(8)
size = struct.unpack('Q', buf)[0]
print('size:', size)

recieved = 0
with open('./tst', 'wb') as img:
    while recieved < size:
        data = client.recv(1024)
        recieved += 1024
        if not data:
            break
        img.write(data)
    img.close()
print('Received, yay!')

client.close()
