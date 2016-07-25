import requests
import numpy as np

def IllStatusGet(servAddr):
    r = requests.get('http://'+servAddr+':8956',timeout=10)
    return r.text

def IllModelGet(serviceAddr):
    r = requests.get('http://'+servAddr+':8956/model',timeout=10)
    return r.json()
    
def IllColPost(servAddr, db, user, pwd, col, aEvent):
    payload = {'dbname': db, 'colname': col, 'user': user, 'passwd': pwd}
    r = requests.post('http://'+servAddr+':8956/col',params=payload, json=aEvent,timeout=10)
    return r.text

def IllQuery(servAddr,db, user, pwd, col, q):    
# A query q is a structure of 
# .limit - cap on return items. A limit of 0 is equivalent to no limit.
# .t1 - starting time. Ex: datetime(2014,8,3,16,22,44)
# .t2 - ending time. Ex: datetime(2014,8,3,16,22,55)
# .loc - location array of lat and lng: loc(1) - lat, loc(2) - lng
# .rad - radius around the location, in miles
    earthRad = 3959; #miles
    # Construct the query string
    payload = {'dbname': db, 'colname': col, 'user': user, 'passwd': pwd};
    if 'limit' in q:
        payload.update({'limit':q['limit']})
    # Construct the query data to send
    # ???ymdHMS3???
    if ('t1' in q) and ('t2' in q):
        timeDat = '{"recordDate":{"$gte":{"$date":"' + q['t1'].isoformat() + 'Z"}, "$lte":{"$date":"' + q['t2'].isoformat() + 'Z"}}}'
    elif 't1' in q:
        timeDat = '{"recordDate":{"$gte":{"$date":"' + q['t1'].isoformat() +  'Z"}}}'
    elif 't2' in q:
        timeDat = '{"recordDate":{"$lte":{"$date":"' + q['t2'].isoformat() +  'Z"}}}'
    else:
        timeDat = ''
    # frequency
    if ('f1' in q) and ('f2' in q):
        freqDat = '{minFreq:{$gte:' + str(q['f1']) + '}},{maxFreq:{$lte:' + str(q['f2']) + '}}'
    elif 'f1' in q:
        freqDat = '{minFreq:{$gte:' + str(q['f1']) + '}}'
    elif 'f2' in q:
        freqDat = '{maxFreq:{$lte:' + str(q['f2']) + '}}'
    else:
        freqDat = ''
    # duration
    if ('dur1' in q) and ('dur2' in q):
        durDat = '{maxDur:{$gte:' + str(q['dur1']) + ', $lte:' + str(q['dur2']) + '}}'
    elif 'dur1' in q:
        durDat = '{maxDur:{$gte:' + str(q['dur1']) + '}}'
    elif 'f2' in q:
        durDat = '{maxDur:{$lte:' + str(q['dur2']) + '}}'
    else:
        durDat = ''
    # Location and Radius
    if ('loc' in q) and ('rad' in q):
        locDat = '{"location":{"$geoWithin":{"$centerSphere":[[' + str(q['loc'][0]) + ',' + str(q['loc'][1]) + '], ' + str(q['rad']/earthRad) +  ']}}}'
    else:
        locDat = '';
    #Tag
    if ('tag' in q):
        tagDat = '{"$text": {"$search":"' + q['tag'] + '"}}'
    else:
        tagDat = ''
    #Device
    if ('dev' in q):
        devDat = '{"device":"' + q['dev'] + '"}'
    else:
        devDat = ''
    
    seq = [timeDat,locDat,freqDat,durDat,tagDat,devDat]
    seq = [x for x in seq if x]
    postDat = ","
    postDat = postDat.join(seq)
    postDat = '{"$and":[' + postDat + ']}'
    r = requests.post('http://'+servAddr+':8956/query',params=payload,data = postDat, timeout=15)
    return r.json()

def IllColGet(servAddr,db, user, pwd, col, filename):
    payload = {'dbname': db, 'colname': col, 'user': user, 'passwd': pwd, 'filename': filename}
    r = requests.get('http://'+servAddr+':8956/col', params=payload, timeout=10)
    return r.json()
    
def IllColPut(servAddr,db, user, pwd, col, filename, op, field):
    # Apply operation 'op' with field 'field' on document 'filename'. 

    # 'field' is json, i.e. has the form {<name>:<value>}.
    # 'op' includes (but not limited to, see the MongoDb field update operators
    # for the complete list): inc, mul, max, min, set, unset.
    op = '$'+op
    payload = {'dbname': db, 'colname': col, 'user': user, 'passwd': pwd}
    putDat = {'filename':filename, op:field}
    # putDat = '{"filename":"' + filename + '"}'+\n+'{"$' + op + '":' + field + '}'
    putDat = '{{"filename":"{0}"}}\n{{"{1}":{2}}}'.format(filename,op,field)
    r = requests.put('http://'+servAddr+':8956/col', params=payload, data = putDat, timeout=15)
    return r.json()

def IllGridPost(servAddr, db, user, pwd, gridCol, filename, data):
    payload = {'dbname': db, 'colname': gridCol, 'user': user, 'passwd': pwd, 'filename': filename}
    r = requests.post('http://'+servAddr+':8956/gridfs',params=payload,data = data, timeout=15)
    return r.text

def IllGridGet(servAddr, db, user, pwd, gridCol, filename):
    payload = {'dbname': db, 'colname': gridCol, 'user': user, 'passwd': pwd, 'filename': filename}
    r = requests.get('http://'+servAddr+':8956/gridfs',params=payload, timeout=15)
    return r.content

def IllColDelete(servAddr, db, user, pwd, col, filename):
    payload = {'dbname': db, 'colname': col, 'user': user, 'passwd': pwd, 'filename': filename}
    r = requests.delete('http://'+servAddr+':8956/col',params=payload, timeout=15)
    return r.text

def IllGridDelete(servAddr, db, user, pwd, gridCol, filename):
    payload = {'dbname': db, 'colname': gridCol, 'user': user, 'passwd': pwd, 'filename': filename}
    r = requests.delete('http://'+servAddr+':8956/gridfs',params=payload, timeout=15)
    return r.text

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
    