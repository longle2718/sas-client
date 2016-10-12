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
gcl_name = gdp.GDP_NAME('edu.illinois.ifp.acoustic.log0')
# assume that this log already exists.
gcl_handle = gdp.GDP_GCL(gcl_name,gdp.GDP_MODE_RA)

def callback(ch,method,properties,body):
    print(body)
    gcl_handle.append({'data':body})
    # verify if write successful
    datum = gcl_handle.read(-1)
    print('The most recent record number is '+ str(datum['recno']))

# === Rabbitmq setup
# subscribe to roomStateProb ex
connection = pika.BlockingConnection(pika.ConnectionParameters(
    host='localhost'))
channel = connection.channel()
ex = 'roomStateProb'
channel.exchange_declare(exchange=ex,type='fanout')
result = channel.queue_declare(exclusive=True)
queue_name = result.method.queue
channel.queue_bind(exchange=ex,queue=queue_name)
channel.basic_consume(callback,queue=queue_name,no_ack=True)
channel.start_consuming()

print('Waiting for logs. To exit press CTRL+C')
