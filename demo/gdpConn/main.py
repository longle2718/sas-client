"""
GDB connector from Illiad

Long Le <longle1@illinois.edu>
University of Illinois
"""
import sys
sys.path.insert(0,sys.path[0]+'../../python/src/')
from sasclient import *
from datetime import datetime, timedelta

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


