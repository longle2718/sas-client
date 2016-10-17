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
var uuid = require('node-uuid');

var servAddr = 'http://acoustic.ifp.illinois.edu:8080';
var DB = 'publicDb';
var USER = 'nan';
var PWD = 'publicPwd';
var DATA = 'data';
var EVENT = 'event';

var q = {};
// hardcoded query for now that only use time range
q.t2 = new Date();
q.t1 = new Date(); // a Date object
var curTime = Date.now(); // a number
var streamTimerId;
var isOn = false;
var access_token = '';
var JWT_access_token = '';

var requestKeys = function(){
// reset key every once in a while
    // Authenticate using Google service account and short-lived OAuth tokens. Namely,
    // it is assumed that the user has access to a Google service account key file 
    // (json format), which must be stored safely in the server. 
    // Newly-generated access token is only temporary.
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

    // Assume access to a Microsoft subscription key as a json file
    // See the following links:
    // https://www.microsoft.com/cognitive-services/en-us/subscriptions
    // https://www.microsoft.com/cognitive-services/en-us/Speech-api/documentation/API-Reference-REST/BingVoiceRecognition
    try{
        var obj = JSON.parse(fs.readFileSync('microsoft_key.json', 'utf8'));
    } catch(exc){
        console.log(exc);
    }
    request.post({
        headers: {"Ocp-Apim-Subscription-Key":obj.subscription_key,"Content-type":"application/x-www-form-urlencoded","Content-Length":"0"},
        url: "https://api.cognitive.microsoft.com/sts/v1.0/issueToken"
    }, function(err,resp,body){
        if (err){
            console.log(err);
        }

        JWT_access_token = body;
        console.log('Current JWT access token is '+JWT_access_token.slice(0,10)+'...')
    });
}

requestKeys();
setInterval(function(){
    requestKeys();
},30*60*1000);

//Using google service for autoxscribe.
var xscript = function(data,cb_done,cb_fail){
    //console.log(data.slice(0,4));
    //console.log(data.length);
    request.post({
        headers:{"Content-Type": "application/json","Authorization": "Bearer "+access_token},
        url:'https://speech.googleapis.com/v1beta1/speech:syncrecognize',
        json: {
            'config': {
                'encoding':'LINEAR16',
                'sampleRate': 16000,
                'profanityFilter': true,
                'languageCode': 'en-US'
            },
            'audio': {
                // linear format does not have the header
                'content':data.slice(44).toString('base64')
            }
        }
    }, function(error, response, body){
        //console.log('response = ');
        //console.log(response);
        if (error){
            cb_fail(error);
            return;
        }

        //console.log('body = ');
        //console.log(body);
        if ('results' in body && body.results.length>0){
            cb_done(body.results[0].alternatives[0].transcript);
        } else{
            // use Microsoft service to try transcribing again
            // assume access to a Microsoft subscription key as a json file
            //console.log('Try again with Microsoft service');
            request.post({
                headers:{"Authorization": "Bearer "+JWT_access_token,"Content-type":"audio/wav;codec='audio/pcm';samplerate=16000;sourcerate=16000;trustsourcerate=true"},
                url: "https://speech.platform.bing.com/recognize?scenarios=smd&appid=D4D52672-91D7-4C74-8AD8-42B1D98141A5&locale=en-US&device.os=Ubuntu&version=3.0&format=json&instanceid="+uuid.v4()+"&requestid="+uuid.v4(),
                body: new Buffer(data)
            }, function(err,resp,body){
                if (err){
                    cb_fail(err);
                    return;
                }

                //console.log('body = ');
                //console.log(body);
                try{
                    body = JSON.parse(body);
                } catch(exc){
                    cb_fail(exc);
                    return;
                }
                if ('results' in body && body.results.length > 0){
                    cb_done(body.results[0].lexical);
                }else{
                    cb_done('');
                }
            });
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
var queryXscribe = function(ch,ex){
    // assume the method toISOString() will be called automatically
    q.t1.setTime(curTime)
    curTime = Date.now()
    q.t2.setTime(curTime)
    //q.t1 = '2016-10-13T04:25:32.927Z';
    //q.t2 = '2016-10-13T04:29:15.927Z';
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
                    // update Illiad
                    Ill.ColPut(servAddr,DB,USER,PWD,EVENT,aEvent.filename,'set','{"tag":"'+str+'"}',function(){
                        //console.log('Db updated with transcribed text');
                    },function(){
                        console.log('Unable to update Db with transcribed text');
                    });
                    console.log(aEvent.filename+' => '+str);
                    // notify the message queue
                    pubDat = '{"text":"'+str+'","recordDate":"'+aEvent.recordDate+'"}'
                    ch.publish(ex,'text',new Buffer(pubDat));
                    //console.log('Notified message broker');
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

// control the operation of queryXscribe based on msg
var controller = function(msg,ch,ex){
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

    if (probOn > 0.5){
        if (!isOn){
            clearInterval(streamTimerId);
            streamTimerId = setInterval(function(){
                queryXscribe(ch,ex);
            },10000);
            isOn = true;
            console.log('autoXscribe: ON');

            Ill.ColPost(servAddr,DB,USER,PWD,EVENT,{"isStart":true,"recordDate":{"$date":new Date().toISOString()}},function(resp){
                console.log('Start marker event sent');
            },function(){
                console.log('Start marker event NOT sent');
            });

        }
    }else{
        if (isOn){
            clearInterval(streamTimerId);
            isOn = false;
            console.log('autoXscribe: OFF');

            Ill.ColPost(servAddr,DB,USER,PWD,EVENT,{"isStart":false,"recordDate":{"$date":new Date().toISOString()}},function(resp){
                console.log('End marker event sent');
            },function(){
                console.log('End marker event NOT sent');
            });
        }
    }
};

// control logic for turning on/off the transcription based on the message queue
amqp.connect('amqp://localhost',function(err,conn){
	conn.createChannel(function(err,ch){
		var ex = 'roomStateProb'; // the name of the exchange abstraction from rabbitmq
		ch.assertExchange(ex, 'direct', {durable: false});
		ch.assertQueue('',{exclusive: true},function(err,q){
			//console.log(" [*] Waiting for messages in %s. To exit press CTRL+C", q.queue);
			ch.bindQueue(q.queue, ex, 'probVec');
			ch.consume(q.queue, function(msg) {
				controller(msg,ch,ex);
			},{noAck: true});
		});
	})
})

