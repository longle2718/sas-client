/* Basic tests of SAS client library for nodejs

  MIT License (MIT)

  Copyright (c) 2015 Long Le

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

var Ill = require('../src/sasclient_node')
var fs = require('fs');

var servAddr = 'http://acoustic.ifp.illinois.edu:8080';
var DB = 'publicDb';
var USER = 'nan';
var PWD = 'publicPwd';
var DATA = 'data';
var EVENT = 'event';

var numTest = 0;
var numPass = 0;

//==========================
numTest += 1
console.log('Test '+numTest+': check status')

Ill.StatusGet(servAddr,function(){
	console.log("... PASSED\n")
	numPass += 1
	console.log(numPass+" passed out of "+numTest+" tests")
}, function(){
	console.log("... FAILED\n")
})

//==========================
numTest += 1
console.log('Test '+numTest+': query event')

var q = {};
q.t1 = '2016-09-04T20:29:36.776Z'
q.t2 = '2016-09-06T20:29:36.776Z'
Ill.Query(servAddr,DB,USER,PWD,EVENT,q,function(events){
	console.log('# of events = '+events.length)
	console.log("... PASSED\n")
	numPass += 1
	console.log(numPass+" passed out of "+numTest+" tests")
}, function(){
	console.log("... FAILED\n")
})

//==========================
numTest += 1
console.log('Test '+numTest+': download data')

var fname = '17100105-8896-431b-bfcd-94003abed614.wav';
Ill.GridGet(servAddr,DB,USER,PWD,DATA,fname,function(data){
	console.log('data.length = '+data.length);

	var wstream = fs.createWriteStream(fname);
	wstream.write(data);
	wstream.end();

	console.log("... PASSED\n")
	numPass += 1
	console.log(numPass+" passed out of "+numTest+" tests")
},function(){
	console.log("... FAILED\n")
})
