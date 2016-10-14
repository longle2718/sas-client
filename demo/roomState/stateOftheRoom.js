var Ill = require('../../nodejs/src/sasclient_node');
var http = require('http');
var async = require('async');
var fs = require('fs');
var _ =require('underscore');
var servAddr = 'http://acoustic.ifp.illinois.edu:8080';
var DB = 'publicDb';
var USER = 'nan';
var PWD = 'publicPwd';
var DATA = 'data';
var EVENT = 'event';
var amqp = require('amqplib/callback_api');
var PRESENTING_PHONEID= 'b8a9953125a933af'; ////Long Phone 
var QA_PHONEID = '2c3f3c41c3f247c6'; // Duc Phone

var state = {"p_presenting":0.,"p_QA":0,"p_break":1.};
var q = {};
//q.t1 = '2016-09-05T22:35:25.443Z';
//q.t2 = '2016-09-05T22:45:25.443Z'; // asumme this is current time
q.mask ={'_id':false,'androidID':true, 'maxDur':true};
var customSort= function(e1,e2){
	return new Date(e1.recordDate).getTime() - new Date(e2.recordDate).getTime()
}
var t=new Date();
var intensity =0;

var queryClassify= function (ch,ex){
    var T = 30;

	t+=1000;
	//console.log('running ...'+ t +'\n');
	var currentTime= new Date();//new Date();
	var startTime = currentTime.getTime() - T*1000// in production currentTIme should be used
	q.t1= new Date(startTime).toISOString();
	q.t2 = currentTime.toISOString();

	Ill.Query(servAddr,DB,USER,PWD,EVENT,q,function(events){
		console.log('---------------------------------------------------------------');
		console.log('# of events = '+events.length);
        //console.log(events[0]);
		//events.sort(customSort);
		/*_.each(events,function(e,ind){
			//console.log('recordTime:'+e.recordDate, 'Duration:'+ e.maxDur+'\n');
			//temp = new Date(e.recordDate).getTime();
			pauseTime+= temp - parseFloat(e.maxDur)*1000- startTime; //note maxDur in second
			if (pauseTime<0){ // it mean the begin of the block there is a speech
				pauseTime =0
			} 
			startTime = temp;
			//console.log('pauseTime at'+ind+':'+pauseTime)
			intensity+=intensityCal(e);
		});*/
		var presentingEvents = new Array();
		var qAEvents= new Array(); 
		var pauseTimeForQAphone=0;
		var pauseTimeForPresentingphone=0;
		var totalDurationForQA =0;
		var totalDurationForPresenting=0;
		for (var i = 0; i < events.length; i++) {
			if (events[i].androidID ===PRESENTING_PHONEID){ //Long Phone 
				totalDurationForPresenting+=parseFloat(events[i].maxDur);
				presentingEvents.push(events[i]);
			}

			if (events[i].androidID===QA_PHONEID){ // Duc Phone
				totalDurationForQA+=parseFloat(events[i].maxDur);
				presentingEvents.push(events[i]);
			}
			//console.log(events[i].androidID);
			

		};
		// totalDuration is in seconds
		//pauseTimeForPresentingphone=30000-totalDurationForPresenting*1000;
		//pauseTimeForQAphone = 30000-totalDurationForQA*1000;

		//pauseTime+=currentTime.getTime()-startTime;  //adding the time at the edge
		//console.log('total pauseTime for QA phone in ms:'+ pauseTimeForQAphone);
		//console.log('total pauseTime for presentin phone in ms:'+ pauseTimeForPresentingphone)
		//console.log(totalDurationForPresenting);
		//console.log(totalDurationForQA);
		msgObj = decision(totalDurationForPresenting,totalDurationForQA,T);
        // attach a time stamp
        msgObj['recordDate'] = q.t2;
        msg = JSON.stringify(msgObj);
        //console.log('probability Log:');
		//console.log(msg);
		//console.log('total intensity:'+intensity+'\n');

		intensity=0;
		pauseTime=0 ; // reset paustime after done
		
		// Rabbitmq messaging
		ch.publish(ex, 'probVec', new Buffer(msg));
		console.log("Sent %s", msg);
    }, function(){
	console.log("Ill.Query failed");
	})
}
// Query the Illiad service for audio events that matches the query q

var softmax = function(x){
    ex = new Array();
    sumex = 0;
    for (var k=0;k<x.length;k++){
        ex[k] = Math.exp(x[k]);
        sumex += ex[k];
    }
    
    normex = new Array();
    for (var k=0;k<x.length;k++){
        normex[k] = ex[k]/sumex;
    }
    return normex;
};

var probNorm = function(x){
    sumx = 0;
    for (var k=0;k<x.length;k++){
        sumx += x[k];
    }
    
    normx = new Array();
    for (var k=0;k<x.length;k++){
        normx[k] = x[k]/sumx;
    }
    return normx;
};

var decision = function(dP,dQA,T){
    // manual adjustment based on observations
    T = T-10; 
    dP = Math.min(dP*2,T);
    dQA = Math.min(dQA*7,T);

	var x = [dP/T, dQA/T,(T-Math.max(dP,dQA))/T];
    //console.log(x);
    //var p = softmax(x);
    var p = probNorm(x);
    //console.log(p);
	return {'p_presenting':p[0],'p_QA':p[1],'p_break':p[2]};

	/*
	var  x=pauseTime/1000 -7; //convert to second
	var z1= Math.exp(-(x-8)*(x-8)/18);
	var z2= Math.exp(-(x-12)*(x-12)/18);
	var z3= Math.exp(-(x-29)*(x-29)/18);
	var normalizedFactor = z1+z2+z3;
	var p1 =z1/normalizedFactor;
	var p2 = z2/normalizedFactor;
	var p3 = z3/normalizedFactor;
	if (p1>=p2 && p1>=p3){
		console.log('p_presenting')
	}
	else {
		
		if (p2>=p1 && p2>=p3){
			console.log('p_QA');
		}
		else{
			console.log('p_break');
		}
	}

	return {'p_presenting':p1,'p_QA':p2,'p_break':p3}
	*/
}

amqp.connect('amqp://localhost', function(err, conn) {
  conn.createChannel(function(err, ch) {
    var ex = 'roomStateProb';
	// print out all the strings after the command or Hello world if empty
    //var msg = process.argv.slice(2).join(' ') || 'Hello World!';
	// the first argument must be a no-argument callback function, otherwise exception
	ch.assertExchange(ex, 'direct', {durable: false});
	setInterval(function(){
		queryClassify(ch,ex);
	},5000)

  });

  //setTimeout(function() { conn.close(); process.exit(0) }, 500);
});

/*
function intensityCal(event){// use for continous block of 30s only
	var intensity = 0;
	
	for (var i = 0; i < event.octaveFeat.length; i++) {
		element =event.octaveFeat[i];
		for (var j = 0; j < element.length; j++) {
			intensity +=element[j];
		};
	};
	
	return intensity; 
}
*/

