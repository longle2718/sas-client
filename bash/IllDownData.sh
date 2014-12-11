#!/bin/bash

# $1 - db name, i.e. publicDb
# $2 - gridfs collection name, i.e. data
# $3 - username, i.e. publicUser
# $4 - password, i.e. publicPwd
# $5 - filename, i.e. tmp.wav
curl -k "https://acoustic.ifp.illinois.edu:8081/gridfs/$1/$2?user=$3&passwd=$4&filename=$5"
