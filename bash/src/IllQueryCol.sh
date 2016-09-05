#!/bin/bash

# $1 - db name, i.e. publicDb
# $2 - username, i.e. publicUser
# $3 - password, i.e. publicPwd
# $4 - collection name, i.e. event
# $5 - query, i.e. {filename:'"'2014-10-05T18:27:58.443Z.wav'"'}
# $6 - limit, i.e. 2
curl -k -i "https://acoustic.ifp.illinois.edu:8081/query?dbname=$1&colname=$4&user=$2&passwd=$3&limit=$6" --data-binary "$5"
