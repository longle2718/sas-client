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
var http = require('http')

var servAddr = 'http://acoustic.ifp.illinois.edu:8080';
var DB = 'publicDb';
var USER = 'nan';
var PWD = 'publicPwd';
var DATA = 'data';
var EVENT = 'event';

var xscript = function(data,cb_done,cb_fail){
	console.log('google ASR');
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
				/*
				var recogWords = [];
				if (rawRes.result.length>0){
					for (var l = 0; l < rawRes.result[0].alternative.length; l++){
						// alternative[0] also has confidence level
						recogWords.push(rawRes.result[0].alternative[l].transcript);
					}
					console.log(recogWords);
					var sentence = recogWords.join(' ');

					eventj.tag = 'speech '+sentence;
					cb_done();
				}
				*/
			}
		});
	});

	req.on('error', function(err){
		console.log(err);
		cb_fail();
	});
	req.write(data);
	req.end();
}

var q = {};
q.t1 = '2016-09-04T21:50:21.002Z'
q.t2 = '2016-09-05T21:50:21.002Z'
Ill.Query(servAddr,DB,USER,PWD,EVENT,q,function(events){
	console.log('# of events = '+events.length)

	events.forEach(function(aEvent){
		Ill.GridGet(servAddr,DB,USER,PWD,DATA,aEvent.filename,function(data){
			xscript(data,function(str){
				console.log(str);
			},function(){
				console.log('no transcription for '+aEvent.filename);
			});
		},function(){
			console.log("Ill.GridGet failed")
		});
	});
	
}, function(){
	console.log("Ill.Query failed")
})

