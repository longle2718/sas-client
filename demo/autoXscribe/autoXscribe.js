/* Automatic transcription using SAS

  MIT License (MIT)

  Copyright (c) 2016 Long Le

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
	
	Authors: Long Le <longle1@illinois.edu>
*/

var Ill = require('../../nodejs/src/sasclient_node')
//var http = require('http')
var request = require('request')
var async = require('async')
var fs = require('fs');
var amqp = require('amqplib/callback_api');
var exec = require('child_process').exec;

var servAddr = 'http://acoustic.ifp.illinois.edu:8080';
var DB = 'publicDb';
var USER = 'nan';
var PWD = 'publicPwd';
var DATA = 'data';
var EVENT = 'event';
var access_token = '';

var q = {};
// hardcoded query for now that only use time range
//q.t1 = '2016-09-05T22:35:25.443Z';
//q.t2 = '2016-09-05T22:45:25.443Z';
q.t2 = new Date();
q.t1 = new Date();
var streamTimerId;
var isOn = false;

// Authenticate using Google service account and short-lived OAuth tokens. Namely,
// it is assumed that the user has access to a Google service account key file 
// (json format), which must be stored safely in the server. 
// Newly-generated access_token is only temporary.
//
// See https://cloud.google.com/speech/docs/common/auth.
// For an example, see https://cloud.google.com/speech/docs/getting-started.
exec('gcloud auth print-access-token', function(err,stdout,stderr){
    if (err){
        console.log(err);
        return;
    }
    if (stdout){
        access_token = stdout
        console.log('Current access token is '+access_token.slice(0,10)+'...')
    }
});

//Using google service for autoxscribe.
var xscript = function(data,cb_done,cb_fail){
    request.post({
        headers:{"Content-Type": "application/json","Authorization": "Bearer "+access_token},
        url:'https://speech.googleapis.com/v1beta1/speech:syncrecognize',
        json: {
            'config': {
                'encoding':'LINEAR16',
                'sampleRate': 16000,
                'languageCode': 'en-US'
            },
            'audio': {
                'content':data.toString('base64')
            }
        }
    }, function(error, response, body){
        //console.log(response);
        if (error){
            cb_fail(error);
            return;
        }

        //console.log(body);
        if ('results' in body && body.results.length>0){
            cb_done(body.results[0].alternatives[0].transcript);
        } else{
            cb_done('');
        }
    });

	//console.log('google ASR');
	// prepare params for http requests
    /*
	var options = {
		hostname: 'www.google.com',
		path: '/speech-api/v2/recognize?key=AIzaSyD5NvcrQ54Rbzdxpo3FtJsAyvUjy6O3cn4&output=json&lang=en-us',
		method: 'POST',
		headers:{
			'Content-Type':'audio/l16; rate=16000;'
		}
	};

	var req = http.request(options, function(google_res){
		//console.log('STATUS: '+google_res.statusCode);
		//console.log('HEADERS: '+JSON.stringify(google_res.headers));
		google_res.setEncoding('utf8');
		
		var chunks = "";
		google_res.on('data', function (chunk) {
			chunks += chunk;
		});

		google_res.on('end', function(){
			//console.log('google responses: '+chunks);
			// navigating through the nasty json return by google
			var rawResStr = chunks.split('\n');// only the second chunk contains valid responses.
			if (! rawResStr[1])
				cb_fail();
			else{
				var rawRes = JSON.parse(rawResStr[1]);
				if (rawRes.result.length>0){
					cb_done(rawRes.result[0].alternative[0].transcript);
				} else{
					cb_done('');
				}
				
				//var recogWords = [];
				//if (rawRes.result.length>0){
				//	for (var l = 0; l < rawRes.result[0].alternative.length; l++){
						// alternative[0] also has confidence level
				//		recogWords.push(rawRes.result[0].alternative[l].transcript);
				//	}
				//	console.log(recogWords);
				//	var sentence = recogWords.join(' ');

				//	eventj.tag = 'speech '+sentence;
				//	cb_done();
				//}
				
			}
		});
	});

	req.on('error', function(err){
		console.log(err);
		cb_fail();
	});
	req.write(data);
	req.end();
    */
}

// query and transcribe audio
var queryXscribe = function(){
    q.t2.setTime(Date.now())
    q.t1.setTime(q.t2.getTime()-10000)
    console.log('From '+q.t1+' to '+q.t2)

    // Query the Illiad service for audio events that matches the query q
    Ill.Query(servAddr,DB,USER,PWD,EVENT,q,function(events){
        console.log('# of events = '+events.length);

        async.eachSeries(events,function(aEvent,cb){
            // read raw audio data associated with each audio event
            Ill.GridGet(servAddr,DB,USER,PWD,DATA,aEvent.filename,function(data){
                // write the data locally for verification
                /*
                var wstream = fs.createWriteStream(aEvent.filename);
                wstream.write(data);
                wstream.end();
                */

                // xscribe the raw audio data of an event
                xscript(data,function(str){
                    console.log(aEvent.filename+' => '+str);
                },function(){
                    console.log(aEvent.filename+' => unable to transcribe');
                });
                cb();
            },function(){
                console.log("Ill.GridGet failed");
                cb();
            });
        },function(err){
            if (err)
                console.log(err.message);
            //console.log('async finished');
        });
        
    }, function(){
        console.log("Ill.Query failed");
    })
}

// control logic for turning on/off the transcription based on the message queue
amqp.connect('amqp://localhost',function(err,conn){
	conn.createChannel(function(err,ch){
		var ex = 'roomStateProb'; // the name of the exchange abstraction from rabbitmq
		ch.assertExchange(ex, 'fanout', {durable: false});
		ch.assertQueue('',{exclusive: true},function(err,q){
			//console.log(" [*] Waiting for messages in %s. To exit press CTRL+C", q.queue);
			ch.bindQueue(q.queue, ex, '');
			ch.consume(q.queue, function(msg) {
				// handle rabbitmq message here
				roomStateProbStr = msg.content.toString();
				//console.log(roomStateProbStr);
				try{
					roomStateProb = JSON.parse(roomStateProbStr);
					probOn =  roomStateProb.p_presenting+roomStateProb.p_QA;
					//console.log("Probability: "+probOn);
				} catch(exc){
					console.log(exc);
					return;
				}

				if (probOn > 0.7){
					if (!isOn){
						clearInterval(streamTimerId);
						streamTimerId = setInterval(queryXscribe,10000)
						isOn = true;
						console.log('autoXscribe: ON')
                        // TODO: dummy marker event for start

					}
				}else{
					if (isOn){
						clearInterval(streamTimerId);
						isOn = false;
						console.log('autoXscribe: OFF')
                        // TODO: dummy marker event for stop
					}
				}
				
			},{noAck: true});
		});
	})
})

