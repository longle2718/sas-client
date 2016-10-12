#!/usr/bin/env python
import pika
import sys,os
mDir = os.path.dirname(__file__)
sys.path.append(os.path.join(mDir, '../../../gdp/lang/python/'))
import gdp

# === GDP setup
# Put data (if any) into GDP
gdp.gdp_init()
# create a GDP_NAME object from a human readable python string
#gcl_name = gdp.GDP_NAME('edu.illinois.ifp.longle1.log0')
#gcl_name = gdp.GDP_NAME('edu.illinois.ifp.acoustic.log0')
logNames = {'probVec':'edu.illinois.ifp.acoustic.probVec',
            'text':'edu.illinois.ifp.acoustic.text'}

# assume that the log(s) already exists.
gcl_handles = {}
for key,gcl_name in logNames.items():
    print('gcl_name = '+gcl_name)
    gcl_name = gdp.GDP_NAME(gcl_name)
    gcl_handles[key] = gdp.GDP_GCL(gcl_name,gdp.GDP_MODE_RA)

def callback(ch,method,properties,body):
    print('routing_key = '+method.routing_key+', body = '+body)
    if method.routing_key in gcl_handles:
        gcl_handle = gcl_handles[method.routing_key]
        gcl_handle.append({'data':body})

        # verify if write successful
        datum = gcl_handle.read(-1)
        print('The most recent record number is '+ str(datum['recno']))

# === Rabbitmq setup
# subscribe to roomStateProb exchange
# for multiple severity
ex = 'roomStateProb'
severities = ['probVec','text']

connection = pika.BlockingConnection(pika.ConnectionParameters(
    host='localhost'))
channel = connection.channel()
channel.exchange_declare(exchange=ex,type='direct')
result = channel.queue_declare(exclusive=True)
queue_name = result.method.queue
for severity in severities:
    channel.queue_bind(exchange=ex,queue=queue_name,routing_key=severity)
channel.basic_consume(callback,queue=queue_name,no_ack=True)
channel.start_consuming()

print('Waiting for logs. To exit press CTRL+C')
