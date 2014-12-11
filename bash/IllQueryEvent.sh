#!/bin/bash

# $1 - db name, i.e. publicDb
# $2 - collection name, i.e. event
# $3 - username, i.e. publicUser
# $4 - password, i.e. publicPwd
# $5 - query, i.e. {filename:'"'2014-10-05T18:27:58.443Z.wav'"'}
# $6 - limit, i.e. 2
curl -k -i "https://acoustic.ifp.illinois.edu:8081/query?dbname=$1&colname=$2&user=$3&passwd=$4&limit=$6" --data-binary "$5"
