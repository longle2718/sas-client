#!/bin/bash

# $1 - db name, i.e. publicDb
# $2 - collection name, i.e. event
# $3 - username, i.e. publicUser
# $4 - password, i.e. publicPwd
# $5 - filename, i.e. tmp.wav
curl -k "https://acoustic.ifp.illinois.edu:8081/query?dbname=$1&colname=$2&user=$3&passwd=$4" --data-binary '{filename:"'"$5"'"}'
