wkDir = 'E:\\SAS\\Python\\'
import os
os.chdir(wkDir)
import SAS


servAddr = 'acoustic.ifp.illinois.edu'
# servAddr = '192.168.8.105'
DB = 'publicDb'
USER = 'nan'
PWD = 'publicPwd'
DATA = 'data'
EVENT = 'event'

# Check Status
status = IllStatusGet(servAddr)
print('Test 1 check status')
print(status)
# Check Models
models = IllModelGet(servAddr)
print('Test 2 check models')
print(models)
# Send event
aEvent = {'filename': 'testPoint', 'key': PWD, 'a': 1}
status = IllColPost(servAddr, DB, USER, PWD, EVENT, aEvent)
print('Test 3 send event')
print(status)
# Query event
q = {'filename': 'testPoint'}
#q = {'filename': 'testPoint',
#     'limit': 0,
#     't1':datetime(2014,8,3,16,22,44),
#     't2':datetime(2014,8,3,16,22,55)}
events = IllQuery(servAddr,DB, USER, PWD, EVENT, q);
print('Test 4 query event')
print(type(events))
# Download event
events = IllColGet(servAddr,DB, USER, PWD, EVENT, events[0]['filename'])
print('Test 5 download event')
print(type(events))
# Update event
resp = IllColPut(servAddr, DB, USER, PWD, EVENT, 'testPoint', 'inc', '{"a":1}');
print('Test 6 update event')
print(resp)
# Send data
# [x, fs, nbBits] = audiolab.wavread('hello.wav')
postDat  = open(wkDir+'hello.wav', "rb").read()
resp = IllGridPost(servAddr, DB, USER, PWD, DATA, 'testPoint', postDat)
print('Test 7 download event')
print(resp)
# Download data
getDat = IllGridGet(servAddr, DB, USER, PWD, DATA, 'testPoint')
hello = wavread_char(getDat)
print('Test 8 download data')
# Delete event
resp = IllColDelete(servAddr, DB, USER, PWD, EVENT, 'testPoint')
print('Test 9 delete event')
print(resp)
# Delete data
resp = IllGridDelete(servAddr, DB, USER, PWD, DATA, 'testPoint')
print('Test 7 delete data')
print(resp)