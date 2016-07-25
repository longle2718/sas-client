#!/bin/bash

# $1 - db name, i.e. publicDb
# $2 - username, i.e. publicUser
# $3 - password, i.e. publicPwd
# $4 - collection name, i.e. event
# $5 - filename, i.e. tmp.wav
curl -k "https://acoustic.ifp.illinois.edu:8081/query?dbname=$1&colname=$4&user=$2&passwd=$3" --data-binary '{filename:"'"$5"'"}'
