'''
Try processing audio from Illiad in python

Long Le <longle1@illinois.edu>
University of Illinois
'''
print(__doc__)

import numpy as np
from scipy.io import wavfile
from scipy import signal
import matplotlib.pyplot as plt
import sys
sys.path.insert(0,sys.path[0]+'/../src/')
#print(sys.path)
from sasclient import *
from datetime import datetime

servAddr = 'acoustic.ifp.illinois.edu:8080'
DB = 'publicDb'
USER = 'nan'
PWD = 'publicPwd'
DATA = 'data'
EVENT = 'event'

q = {'t1':datetime(2016,7,20,00,00,00),\
     't2':datetime(2016,8,3,00,00,00)}
events = IllQuery(servAddr,DB, USER, PWD, EVENT, q);
print("Number of events found is "+str(len(events)))
# bytes
data = IllGridGet(servAddr, DB, USER, PWD, DATA, events[0]['filename'])
if 'RIFF' == data[0:4].decode('utf-8'):
	with open('audio.wav', 'wb') as f:
		f.write(data)
else:
	sys.exit('Corrupted audio file!')

fs,data = wavfile.read('audio.wav')
T = np.arange(len(data))/fs
f,t,Sxx = signal.spectrogram(data,fs,window='hann',nperseg=512,noverlap=256)

fig = plt.figure()
fig.add_subplot(211)
plt.pcolormesh(t,f,Sxx)
plt.ylabel('Frequency (Hz)')
plt.xlabel('Time (sec)')
fig.add_subplot(212)
plt.plot(T,data)
plt.ylabel('Amplitude')
plt.xlabel('Time (sec)')
plt.show()
