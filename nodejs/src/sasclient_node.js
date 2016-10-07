/* SAS client library for nodejs

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

var request = require('request');
const querystring = require('querystring');

// form request to remote service using the user query
var formReq = function(db, user, pwd, col, q){
    //var tZoneOffset = 5/24;
    var strArr = [];
    
    // Construct the query data to send
    var timeDat;
    if (q.hasOwnProperty('t1') && q.hasOwnProperty('t2')){
        timeDat = '{"recordDate":{"$gte":{"$date":"'+ q.t1+'"}, "$lte":{"$date":"'+q.t2+'"}}}';
    }
    else if (q.hasOwnProperty('t1')){
        timeDat = '{"recordDate":{"$gte":{"$date":"'+ q.t1+'"}}}';
    }
    else if (q.hasOwnProperty('t2')){
        timeDat = '{"recordDate":{"$lte":{"$date":"'+ q.t2+'"}}}';
    } else{
	timeDat = [];
    }
    strArr = strArr.concat(timeDat);

	var freqDat;
    if (q.hasOwnProperty('f1') && q.hasOwnProperty('f2')){
        freqDat = '{"minFreq":{"$gte":'+q.f1+'}},{"maxFreq":{"$lte":'+q.f2+'}}';
    }
    else if (q.hasOwnProperty('f1')){
        freqDat = '{"minFreq":{"$gte":'+q.f1+'}}';
    }else if (q.hasOwnProperty('f2')){
        freqDat = '{"maxFreq":{"$lte":'+q.f2+'}}';
    }else{
        freqDat = [];
    }
    strArr = strArr.concat(freqDat);
    
	var durDat;
    if (q.hasOwnProperty('dur1') && q.hasOwnProperty('dur2')){
        durDat = '{"maxDur":{"$gte":'+q.dur1+', "$lte":'+q.dur2+'}}';
    }
    else if (q.hasOwnProperty('dur1')){
        durDat = '{"maxDur":{"$gte":'+q.dur1+'}}';
    }
    else if (q.hasOwnProperty('dur2')){
        durDat = '{"maxDur":{"$lte":'+q.dur2+'}}';
    }
    else{
        durDat = [];
    }
    strArr = strArr.concat(durDat);

    /*
	var lpDat;
    if (q.hasOwnProperty('lp1') && q.hasOwnProperty('lp2')){
        lpDat = '{"logProb":{"$gte":'+q.lp1+', "$lte":'+q.lp2+'}}';
    }
    else if (q.hasOwnProperty('lp1')){
        lpDat = '{"logProb":{"$gte":'+q.lp1+'}}';
    }
    else if (q.hasOwnProperty('lp2')){
        lpDat = '{"logProb":{"$lte":'+q.lp2+'}}';
    }
    else{
        lpDat = '';
    }
    */
    
	// location and radius
	var locDat;
    if (q.hasOwnProperty('loc') && q.hasOwnProperty('rad')){
        locDat = '{"location":{"$geoWithin":{"$centerSphere":[['+q.loc[1]+','+q.loc[0]+'], '+q.rad/3959+']}}}'; // earthRad = 3959 miles
    }else{
        locDat = [];
    }
    strArr = strArr.concat(locDat);
    
	// tag
	var tagDat;
    if (q.hasOwnProperty('tag')){
        tagDat = '{"$text": {"$search":"'+q.tag+'"}}';
    }else{
        tagDat = [];
    }
    strArr = strArr.concat(tagDat);

	var devDat;
	if (q.hasOwnProperty('device')){
		devDat = '{"device":"'+q.device+'"}';
	}else{
		devDat = [];
	}
    strArr = strArr.concat(devDat);

	var filenameDat;
    if (q.hasOwnProperty('filename')){
        filenameDat = '{"filename": "'+q.filename+'"}';
    }else{
        filenameDat = [];
    }
    strArr = strArr.concat(filenameDat);

	/*
	if ($("#seq").prop('checked')){
		var filenameDat;
		var markers = oms.getMarkers();
		if (markers.length > 0){
			filenameDat = '{"filename":{"$in":[';

			for (var i = 0; i <markers.length;i++){
				filenameDat += '"'+JSON.parse(markers[i].info).filename+'",';
			}
			filenameDat = filenameDat.slice(0,-1);

			filenameDat += ']}}';
		} else{
			filenameDat = [];
		}
		strArr = strArr.concat(filenameDat);
	}
	*/
    if (!q.hasOwnProperty('mask')){
        q.mask={};
    }
    var postDat = '[{"$and":['+strArr.join(',')+']},'+ JSON.stringify(q.mask) + ']';                     //'{"$and":['+strArr.join(',')+']}';
    // Construct the query string
    var qStr = querystring.stringify({'dbname':db, 'colname': col, 'user': user, 'passwd': pwd, 'classname': q.cname});
	
	return [qStr, postDat];
}

module.exports = {
	StatusGet: function(servAddr,cb_done,cb_fail){
		request(servAddr,function(err,resp,body){
			if (!err && resp.statusCode == 200){
				cb_done();
			} else{
				cb_fail();
			}
		});
	},
	
	Query: function(servAddr,db,user,pwd,col,q,cb_done,cb_fail){
		var reqForm = formReq(db,user,pwd, col,q);
		
		request.post({
			//headers: {'content-type':'text/xml'},
			url:servAddr+'/query?'+reqForm[0],
			body: reqForm[1]
		},function(err,resp,body){
			if (!err && resp.statusCode == 200){
	  			var events = JSON.parse(body);
				cb_done(events);
			} else{
	  			console.log('ajax failed');
				cb_fail();
			}
		});
	},
	
	GridGet: function(servAddr,db,user,pwd,gridCol,filename,cb_done,cb_fail){
    	var qStr = querystring.stringify({'dbname':db, 'colname': gridCol, 'user':user, 'passwd': pwd, 'filename': filename});
		
		request({
			//headers: {'content-type':'application/octet-stream'},
			url:servAddr+'/gridfs?'+qStr,
			encoding: null
		},function(err,resp,data){
			if (!err && resp.statusCode == 200){
				cb_done(data);
			} else{
				console.log('request failed');
				cb_fail();
			}
		});
	},

    ColPost: function(servAddr,db,user,pwd,col,aEvent){
    	var qStr = querystring.stringify({'dbname':db, 'colname': col, 'user':user, 'passwd':pwd});

		request.post({
			//headers: {'content-type':'application/json'},
			url:servAddr+'/col?'+qStr,
            json: aEvent
		},function(err,resp,body){
			if (!err && resp.statusCode == 200){
				cb_done(body);
			} else{
				console.log('request failed');
				cb_fail();
			}
		});
    },

    /*
     * 'op' includes (but not limited to, see the MongoDb 
     * field update operators for the complete list): 
     * inc, mul, max, min, set, unset.
     * 'field' is json string, i.e. has the form {<name>:<value>}.
     */
    ColPut: function(servAddr,db,user,pwd,col,filename,op,field,cb_done,cb_fail){
    	var qStr = querystring.stringify({'dbname':db, 'colname': col, 'user':user, 'passwd':pwd});

        var mStr = '{"filename":"'+filename+'"}\n{"$'+op+'":'+field+'}'
		request.put({
			//headers: {'content-type':'application/json'},
			url:servAddr+'/col?'+qStr,
            body: mStr
		},function(err,resp,body){
			if (!err && resp.statusCode == 200){
				cb_done(body);
			} else{
				console.log('request failed');
				cb_fail();
			}
		});
    }
};
