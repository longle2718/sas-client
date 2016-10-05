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


var q = {};
//q.t1 = '2016-09-05T22:35:25.443Z';
//q.t2 = '2016-09-05T22:45:25.443Z'; // asumme this is current time

var customSort= function(e1,e2){
	return new Date(e1.recordDate).getTime() - new Date(e2.recordDate).getTime()
}
var t=new Date();
var intensity =0;
var queryClassify= function (ex,ch){
	t+=1000;
	//console.log('running ...'+ t +'\n');
	var currentTime= new Date();//new Date();
	var startTime = currentTime.getTime() - 30*1000// in production currentTIme should be used
	q.t1= new Date(startTime).toISOString();
	q.t2 = currentTime.toISOString();

	Ill.Query(servAddr,DB,USER,PWD,EVENT,q,function(events){
	console.log('# of events = '+events.length);
	//console.log('['+events[0] +','+events[1]+'\n');
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
    var pauseTime=0;
    var totalDuration =0;
    for (var i = 0; i < events.length; i++) {
    	totalDuration+=parseFloat(events[i].maxDur);
    };
	// totalDuration is in seconds
    pauseTime=30000-totalDuration*1000;
    //pauseTime+=currentTime.getTime()-startTime;  //adding the time at the edge
    console.log('total pauseTime in ms:'+ pauseTime);
    console.log('probability Log: \n');
	msg = JSON.stringify(decision(pauseTime))
    console.log(msg);
    //console.log('total intensity:'+intensity+'\n');
    console.log('---------------------------------------------------------------');

	intensity=0;
	pauseTime=0 ; // reset paustime after done
	
	// Rabbitmq messaging
    ch.assertExchange(ex, 'fanout', {durable: false});
    ch.publish(ex, '', new Buffer(msg));
    console.log(" [x] Sent %s", msg);
    }, function(){
	console.log("Ill.Query failed");
	})
}
// Query the Illiad service for audio events that matches the query q

function decision(pauseTime){
	var  x=pauseTime/1000; //convert to second
	var z1= Math.exp(-(x-8)*(x-8)/18);
	var z2= Math.exp(-(x-12)*(x-12)/18);
	var z3= Math.exp(-(x-29)*(x-29)/18);
	var normalizedFactor = z1+z2+z3;
	var p1 =z1/normalizedFactor;
	var p2 = z2/normalizedFactor;
	var p3 = z3/normalizedFactor;

	return {'p_presenting':p1,'p_QA':p2,'p_break':p3}
}

function intensityCal(event){// use for continous block of 30s only
	var intensity = 0;
	_.each(event.octaveFeat,function(e){
		_.each(e,function(band){
			intensity+= band;
		});
	});
	return intensity; 

	


}

amqp.connect('amqp://localhost', function(err, conn) {
  conn.createChannel(function(err, ch) {
    var ex = 'roomStateProb';
	// print out all the strings after the command or Hello world if empty
    //var msg = process.argv.slice(2).join(' ') || 'Hello World!';
	// the first argument must be a no-argument callback function, otherwise exception
	setInterval(function(){
		queryClassify(ex,ch);
	},1000)

  });

  //setTimeout(function() { conn.close(); process.exit(0) }, 500);
});
