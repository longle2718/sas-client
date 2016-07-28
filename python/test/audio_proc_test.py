'''
Try processing audio from Illiad in python

Long Le <longle1@illinois.edu>
University of Illinois
'''
import numpy as np
from scipy.io import wavfile
from scipy import signal
import matplotlib.pyplot as plt
import sys
sys.path.insert(0,sys.path[0]+'../src/')
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
with open('audio.wav', 'wb') as f:
	f.write(data)

fs,data = wavfile.read('audio.wav')
T = np.arange(len(data))/fs
f,t,Sxx = signal.spectrogram(data,fs)

fig = plt.figure()
ax1 = fig.add_subplot(211)
ax1.pcolormesh(t,f,Sxx)
plt.ylabel('Frequency (Hz)')
plt.xlabel('Time (sec)')
ax2 = fig.add_subplot(212)
ax2.plot(T,data)
plt.ylabel('Amplitude')
plt.xlabel('Time (sec)')
plt.show()
