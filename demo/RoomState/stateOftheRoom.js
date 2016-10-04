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


var q = {};
 q.t1 = '2016-09-05T22:35:25.443Z';
 q.t2 = '2016-09-05T22:45:25.443Z'; // asumme this is current time
var currentTime= new Date(q.t2);//new Date();
var pauseTime=0;
var startTime = new Date(q.t2).getTime() - 20*1000// in production currentTIme should be used
 q.t1= new Date(startTime).toISOString();
 console.log(q.t1);
var customSort= function(e1,e2){
	return new Date(e1.recordDate).getTime() - new Date(e2.recordDate).getTime()
}
var t=new Date();
var intensity =0;
setInterval(function (){
	t+=1000;
	console.log('running ...'+ t +'\n');

	Ill.Query(servAddr,DB,USER,PWD,EVENT,q,function(events){
	console.log('# of events = '+events.length);
	//console.log(events[1]);
	events.sort(customSort);
    _.each(events,function(e,ind){
    	console.log('recordTime:'+e.recordDate, 'Duration:'+ e.maxDur+'\n');
    	temp = new Date(e.recordDate).getTime();
    	pauseTime+= temp - parseFloat(e.maxDur)*1000- startTime; //note maxDur in second
    	if (pauseTime<0){ // it mean the begin of the block there is a speech
    		pauseTime =0
    	} 
    	startTime = temp;
    	//console.log('pauseTime at'+ind+':'+pauseTime)
    	intensity+=intensityCal(e);
    });
    pauseTime+=currentTime.getTime()-startTime;  //adding the time at the edge
    console.log('total pauseTime in ms:'+ pauseTime);
    console.log('probability Log: \n');
    console.log(JSON.stringify(decision(9000))+'\n');
    console.log('total intensity:'+intensity+'\n');
    console.log('---------------------------------------------------------------');
	
	intensity=0;
	pauseTime=0 ; // reset paustime after done
    }, function(){
	console.log("Ill.Query failed");
})
},1000);
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