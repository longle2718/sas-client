"""
GDB connector from Illiad

Long Le <longle1@illinois.edu>
University of Illinois
"""
import os
dir = os.path.dirname(__file__)
import sys
sys.path.append(os.path.join(dir, '../../python/src/'))
print(sys.path)
from sasclient import *
sys.path.append(os.path.join(dir, '../../../gdp/lang/python/apps/'))
sys.path.append(os.path.join(dir, '../../../gdp/lang/python/'))
import KVstore
from datetime import datetime, timedelta

#======================
# Get data from Illiad
servAddr = 'acoustic.ifp.illinois.edu:8080'
DB = 'publicDb'
USER = 'nan'
PWD = 'publicPwd'
DATA = 'data'
EVENT = 'event'

currTime = datetime.utcnow()
t2 = currTime;
t1 = currTime - timedelta(minutes=120)
print(t1)
print(t2)

q = {'t1':t1,'t2':t2}
events = IllQuery(servAddr,DB, USER, PWD, EVENT, q);
if len(events) > 0:
	print("Number of events found is "+str(len(events)))
	#print(events[0])
else:
	print('No event found!')

#======================
# Put data (if any) into GDP
logname = "gdp.illiad.log"
kv = KVstore(logname, mode=KVstore.MODE_RW) # create a kvstore

for idx in range(len(events)):
	kv[idx] = events[idx]

# verified log-writing
assert len(kv) == len(events)

