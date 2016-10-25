var Ill = require('../../nodejs/src/sasclient_node');
var http = require('http');
var async = require('async');
var fs = require('fs');
var _ =require('underscore');
var amqp = require('amqplib/callback_api');

var servAddr = 'http://acoustic.ifp.illinois.edu:8080';
var DB = 'publicDb';
var USER = 'nan';
var PWD = 'publicPwd';
var DATA = 'data';
var EVENT = 'event';

var PRESENTING_PHONEID= 'b8a9953125a933af'; ////Long Phone 
var QA_PHONEID = '2c3f3c41c3f247c6'; // Duc White Phone
//var AMB_PHONEID = '543dbfa014eb0798'; // Duc Black Phone 
var AMB_PHONEID = 'beb21323a2242c14'; // Romit phone NS-10
//var state = {"p_presenting":0.,"p_QA":0,"p_break":1.};
var q = {};
q.t2 = new Date();
q.t1 = new Date();
var curTime = Date.now();
//q.t1 = '2016-09-05T22:35:25.443Z';
//q.t2 = '2016-09-05T22:45:25.443Z'; // asumme this is current time
q.mask ={'_id':false,'androidID':true,'maxDur':true,'octaveFeat':true};
//var t=new Date();
//var intensity =0;
var tempWin = 60; // temporal window in seconds
var tempInc = 5; // temporal increment in seconds
var iScale = 0.02;

// Query the Illiad service for audio events that matches the query q
var queryClassify= function (ch,ex){
	//t+=1000;
	//console.log('running ...'+ t +'\n');
    
	//var curTime= new Date();//new Date();
	//var startTime = curTime.getTime() - tempWin*1000// in production currentTIme should be used
	//q.t1= new Date(startTime).toISOString();
	//q.t2 = curTime.toISOString();
    curTime = Date.now()
    q.t2.setTime(curTime)
    q.t1.setTime(curTime-tempWin*1000)

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
		//var presentingEvents = new Array();
		//var qAEvents= new Array(); 
		//var pauseTimeForQAphone=0;
		//var pauseTimeForPresentingphone=0;
		var totalDurationForQA=0;
		var totalDurationForPresenting=0;
		var totalIntensity=0;
		for (var i = 0; i < events.length; i++) {
			//console.log(events[i].androidID);
			//console.log(events[i]);
			//presentingEvents.push(events[i]);
			if (events[i].androidID ===PRESENTING_PHONEID){ //Long Phone 
                if ('maxDur' in events[i]){
				    totalDurationForPresenting+=parseFloat(events[i].maxDur);
                }
			}

			if (events[i].androidID===QA_PHONEID){ // Duc Phone
                if ('maxDur' in events[i]){
				    totalDurationForQA+=parseFloat(events[i].maxDur);
                }
			}
			if (events[i].androidID===AMB_PHONEID){
                if ('octaveFeat' in events[i]){
				    totalIntensity+=avgIntensity(events[i].octaveFeat);
                }
			}
		};
		// totalDuration is in seconds
		//pauseTimeForPresentingphone=30000-totalDurationForPresenting*1000;
		//pauseTimeForQAphone = 30000-totalDurationForQA*1000;

		//pauseTime+=curTime.getTime()-startTime;  //adding the time at the edge
		//console.log('total pauseTime for QA phone in ms:'+ pauseTimeForQAphone);
		//console.log('total pauseTime for presentin phone in ms:'+ pauseTimeForPresentingphone)
		//console.log(totalDurationForPresenting);
		//console.log(totalDurationForQA);
		msgObj = probMeasure(totalDurationForPresenting,totalDurationForQA,totalIntensity);
        // attach a time stamp
        msgObj['recordDate'] = q.t2;
        msg = JSON.stringify(msgObj);
        //console.log('probability Log:');
		//console.log(msg);
		//console.log('total intensity:'+intensity+'\n');

		//intensity=0;
		//pauseTime=0 ; // reset paustime after done
		
		// Rabbitmq messaging
		ch.publish(ex, 'probVec', new Buffer(msg));
		console.log("Sent %s", msg);
    }, function(){
	console.log("Ill.Query failed");
	})
}

var probMeasure = function(dP,dQA,iAmb){
    // manual adjustment based on observations
    var T = tempWin-20; 
    dP = Math.min(dP*8,T);
    dQA = Math.min(dQA*32,T);
    //console.log('dP = '+dP)
    //console.log('dQA = '+dQA)
    console.log('iAmb = '+iAmb)
    //console.log('T = '+T)
    
	var x = [dP/T, dQA/T,(T-Math.max(dP,dQA))/T];
    //console.log(x);

    //var p = softmax(x);
    var p = probNorm(x);
    //console.log(p);

    var q = 1-Math.exp(-Math.max(iAmb/iScale,Math.max(dP,dQA)/T)); // prob non empty
	return {'p_presenting':p[0]*q,'p_QA':p[1]*q,'p_break':p[2]*q,'p_empty':1-q};

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
	},tempInc*1000)

  });

  //setTimeout(function() { conn.close(); process.exit(0) }, 500);
});

var customSort= function(e1,e2){
	return new Date(e1.recordDate).getTime() - new Date(e2.recordDate).getTime()
}

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

function avgIntensity(octaveFeat){// use for continous block of 30s only
	var intensity = 0.;
	var num = 0;
	for (var i = 0; i < octaveFeat.length; i++) {
		for (var j = 0; j < octaveFeat[i].length; j++) {
			intensity += octaveFeat[i][j];
            num += 1
		};
	};
	
	return intensity/num; 
}

