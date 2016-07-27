"""
GDB connector from Illiad

Long Le <longle1@illinois.edu>
University of Illinois
"""
import os
dir = os.path.dirname(__file__)
import sys
sys.path.append(os.path.join(dir, '../../python/src/'))
from sasclient import *
sys.path.append(os.path.join(dir, '../../../gdp/lang/python/'))
import gdp
#sys.path.append(os.path.join(dir, '../../../gdp/lang/python/apps/'))
#from KVstore import KVstore
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
gdp.gdp_init()
gcl_name = gdp.GDP_NAME('edu.illinois.ifp.longle1')
gcl_handle = gdp.GDP_GCL(gcl_name,gdp.GDP_MODE_RA)
for idx in xrange(10):
	datum = {"data": "Hello world " + str(idx)}
	gcl_handle.append(datum)
