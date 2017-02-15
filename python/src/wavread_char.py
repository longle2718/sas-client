"""
Decode WAV file format

Author: Ian
Updated by: Long Le <longle1@illinois.edu>
University of Illinois
"""
import numpy as np

def wavread_char(x):
    if x[0:4].decode("utf-8") != 'RIFF':
        raise Exception('Not a WAV file')
        return
    #header
    head = x[0:44]
    numChannels = int.from_bytes(head[22:24], byteorder='little', signed=False)
    sampleRate = int.from_bytes(head[24:28], byteorder='little', signed=False)
    byteRate = int.from_bytes(head[28:32], byteorder='little', signed=False)
    blockAlign = int.from_bytes(head[32:34], byteorder='little', signed=False)
    bitsPerSample = int.from_bytes(head[34:36], byteorder='little', signed=False)
    header = {'numChannels':numChannels, 'sampleRate':sampleRate, 'byteRate':byteRate,
             'blockAlign':blockAlign, 'bitsPerSample':bitsPerSample}
    # data
    dat = x[44:len(x)]
    if len(dat)%2 != 0:
        raise Exception('File length error')
        return
    data = []
    for i in range(0,len(dat)-1,2):
        data.append(int.from_bytes(dat[i:i+2], byteorder='little', signed=True))
    data = np.array(data)/32768
    return {'header':header, 'data':data}

