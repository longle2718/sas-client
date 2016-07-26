"""
Basic tests for sasclient

Author: Ian 
Updated by: Long Le <longle1@illinois.edu>
University of Illinois
"""
import sys
sys.path.insert(0,sys.path[0]+'../src/')
from sasclient import *


servAddr = 'acoustic.ifp.illinois.edu:8080'
DB = 'publicDb'
USER = 'nan'
PWD = 'publicPwd'
DATA = 'data'
EVENT = 'event'

numTest = 0
numPass = 0

#==========================
numTest += 1
print('Test '+str(numTest)+': check status',end='')

status = IllStatusGet(servAddr)
if 'OK' in status:
	print("... PASSED\n")
	numPass += 1
else:
	print("... FAILED\n")

#==========================
numTest += 1
print('Test '+str(numTest)+': check models',end='')

models = IllModelGet(servAddr)
if type(models) is list:
	print("... PASSED\n")
	numPass += 1
else:
	print("... FAILED\n")
	
#==========================
numTest += 1
print('Test '+str(numTest)+': send event',end='')

aEvent = {'filename': 'testPoint', 'key': PWD, 'a': 1}
status = IllColPost(servAddr, DB, USER, PWD, EVENT, aEvent)
if 'inserted' in status:
	print("... PASSED\n")
	numPass += 1
else:
	print("... FAILED\n")

#==========================
numTest += 1
print('Test '+str(numTest)+': query event',end='')

q = {'filename': 'testPoint'}
#q = {'filename': 'testPoint',
#     'limit': 0,
#     't1':datetime(2014,8,3,16,22,44),
#     't2':datetime(2014,8,3,16,22,55)}
events = IllQuery(servAddr,DB, USER, PWD, EVENT, q);
if type(events) is list:
	print("... PASSED\n")
	numPass += 1
else:
	print("... FAILED\n")

#==========================
numTest += 1
print('Test '+str(numTest)+': download event',end='')

events = IllColGet(servAddr,DB, USER, PWD, EVENT, events[0]['filename'])
if type(events) is list:
	print("... PASSED\n")
	numPass += 1
else:
	print("... FAILED\n")

#==========================
numTest += 1
print('Test '+str(numTest)+': update event',end='')

jsonResp = IllColPut(servAddr, DB, USER, PWD, EVENT, 'testPoint', 'inc', '{"a":1}');
if 'ok' in jsonResp:
	print("... PASSED\n")
	numPass += 1
else:
	print("... FAILED\n")

#==========================
numTest += 1
print('Test '+str(numTest)+': send data',end='')

# [x, fs, nbBits] = audiolab.wavread('hello.wav')
with open('hello.wav', "rb") as f:
	postDat = f.read()
resp = IllGridPost(servAddr, DB, USER, PWD, DATA, 'testPoint', postDat)
if 'inserted' in resp:
	print("... PASSED\n")
	numPass += 1
else:
	print("... FAILED\n")

#==========================
numTest += 1
print('Test '+str(numTest)+': download data',end='')

data = IllGridGet(servAddr, DB, USER, PWD, DATA, 'testPoint')
if 'RIFF' == data[0:4].decode('utf-8'):
	print("... PASSED")
	numPass += 1
else:
	print("... FAILED")

#==========================
numTest += 1
print('Test '+str(numTest)+': delete event',end='')

resp = IllColDelete(servAddr, DB, USER, PWD, EVENT, 'testPoint')
if 'ok' in resp:
	print("... PASSED")
	numPass += 1
else:
	print("... FAILED")

#==========================
numTest += 1
print('Test '+str(numTest)+': delete event',end='')

resp = IllGridDelete(servAddr, DB, USER, PWD, DATA, 'testPoint')
if 'file deleted' in resp:
	print("... PASSED")
	numPass += 1
else:
	print("... FAILED")

#==========================
print(str(numPass)+" passed out of "+str(numTest)+" tests")
