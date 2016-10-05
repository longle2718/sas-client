"""
sasclient subroutines

Author: Ian
Updated by: Long Le <longle1@illinois.edu>
University of Illinois
"""
import requests

def IllStatusGet(servAddr):
    r = requests.get('http://'+servAddr+'/',timeout=10)
    return r.text

def IllModelGet(servAddr):
    r = requests.get('http://'+servAddr+'/model',timeout=10)
    return r.json()
    
def IllColPost(servAddr, db, user, pwd, col, aEvent):
    payload = {'dbname': db, 'colname': col, 'user': user, 'passwd': pwd}
    r = requests.post('http://'+servAddr+'/col',params=payload, json=aEvent,timeout=10)
    return r.text

def IllQuery(servAddr,db, user, pwd, col, q):    
# A query q is a structure of 
# .limit - cap on return items. A limit of 0 is equivalent to no limit.
# .t1 - starting time. Ex: datetime(2014,8,3,16,22,44)
# .t2 - ending time. Ex: datetime(2014,8,3,16,22,55)
# .loc - location array of lat and lng: loc(1) - lat, loc(2) - lng
# .rad - radius around the location, in miles
    earthRad = 3959 #miles
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
        locDat = '{"location":{"$geoWithin":{"$centerSphere":[[' + str(q['loc'][1]) + ',' + str(q['loc'][0]) + '], ' + str(q['rad']/earthRad) +  ']}}}'
    else:
        locDat = '';
    #Tag
    if ('tag' in q):
        tagDat = '{"$text": {"$search":"' + q['tag'] + '"}}'
    else:
        tagDat = ''
    #Device
    if ('device' in q):
        devDat = '{"device":"' + q['device'] + '"}'
    else:
        devDat = ''
    
    seq = [timeDat,locDat,freqDat,durDat,tagDat,devDat]
    seq = [x for x in seq if x]
    postDat = ","
    postDat = postDat.join(seq)
    postDat = '[{"$and":[' + postDat + ']},{}]' # no mask for now
    r = requests.post('http://'+servAddr+'/query',params=payload,data = postDat, timeout=15)
    return r.json()

def IllColGet(servAddr,db, user, pwd, col, filename):
    payload = {'dbname': db, 'colname': col, 'user': user, 'passwd': pwd, 'filename': filename}
    r = requests.get('http://'+servAddr+'/col', params=payload, timeout=10)
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
    r = requests.put('http://'+servAddr+'/col', params=payload, data = putDat, timeout=15)
    return r.json()

def IllGridPost(servAddr, db, user, pwd, gridCol, filename, data):
    payload = {'dbname': db, 'colname': gridCol, 'user': user, 'passwd': pwd, 'filename': filename}
    r = requests.post('http://'+servAddr+'/gridfs',params=payload,data = data, timeout=15)
    return r.text

def IllGridGet(servAddr, db, user, pwd, gridCol, filename):
    payload = {'dbname': db, 'colname': gridCol, 'user': user, 'passwd': pwd, 'filename': filename}
    r = requests.get('http://'+servAddr+'/gridfs',params=payload, timeout=15)
    return r.content

def IllColDelete(servAddr, db, user, pwd, col, filename):
    payload = {'dbname': db, 'colname': col, 'user': user, 'passwd': pwd, 'filename': filename}
    r = requests.delete('http://'+servAddr+'/col',params=payload, timeout=15)
    return r.text

def IllGridDelete(servAddr, db, user, pwd, gridCol, filename):
    payload = {'dbname': db, 'colname': gridCol, 'user': user, 'passwd': pwd, 'filename': filename}
    r = requests.delete('http://'+servAddr+'/gridfs',params=payload, timeout=15)
    return r.text

