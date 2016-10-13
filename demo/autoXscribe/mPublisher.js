#!/usr/bin/env node
// Usage: node mPublisher.js '{"p_presenting":0.8,"p_QA":0.1}'

var amqp = require('amqplib/callback_api');

amqp.connect('amqp://localhost', function(err, conn) {
  conn.createChannel(function(err, ch) {
    var ex = 'roomStateProb';
	// print out all the strings after the command or Hello world if empty
    var msg = process.argv.slice(2).join(' ') || 'Hello World!';

    ch.assertExchange(ex, 'direct', {durable: false});
    ch.publish(ex, 'probVec', new Buffer(msg));
    console.log(" [x] Sent %s", msg);
  });

  setTimeout(function() { conn.close(); process.exit(0) }, 500);
});
