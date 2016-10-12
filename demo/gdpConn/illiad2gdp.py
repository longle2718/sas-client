"""
GDB connector from Illiad

Long Le <longle1@illinois.edu>
University of Illinois
"""
import os
mDir = os.path.dirname(__file__)
import sys
sys.path.append(os.path.join(mDir, '../../python/src/'))
from sasclient import *
sys.path.append(os.path.join(mDir, '../../../gdp/lang/python/'))
import gdp
#sys.path.append(os.path.join(dir, '../../../gdp/lang/python/apps/'))
#from KVstore import KVstore
from datetime import datetime, timedelta
import json, pickle

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
# push data in the last few mins if any
t1 = currTime - timedelta(minutes=15)
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
# append data to a local pickle file
for event in events:
	with open('audio_events.pkl','ab') as f:
		pickle.dump(event,f)

#======================
# Put data (if any) into GDP
gdp.gdp_init()
# create a GDP_NAME object from a human readable python string
#gcl_name = gdp.GDP_NAME('edu.illinois.ifp.longle1.log0')
gcl_name = gdp.GDP_NAME('edu.illinois.ifp.acoustic.log0')
# assume that this log already exists.
gcl_handle = gdp.GDP_GCL(gcl_name,gdp.GDP_MODE_RA)
for event in events:
	print(event['recordDate'])
	gcl_handle.append({'data':json.dumps(event)})
# verify if write successful
datum = gcl_handle.read(-1)
print('The most recent record number is '+ str(datum['recno']))
