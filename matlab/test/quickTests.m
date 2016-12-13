% Quick tests of the remote service
%
% Long Le <longle1@illinois.edu>
% University of Illinois
%

clear all; close all

rootDir = 'C:/Users/Long/Projects/';

addpath([rootDir 'sas-client/matlab/src/']);
addpath([rootDir 'jsonlab']);
addpath([rootDir 'V1_1_urlread2']);
% Import cert into Matlab jvm truststore.
% Default alias is mykey
% Need write access to the truststore (cacerts)
% Only need to do this once per Matlab copy.
%importcert('illiad.crt')

servAddr = 'acoustic.ifp.illinois.edu:8080';
DB = 'publicDb';
USER = 'nan';
PWD = 'publicPwd';
DATA = 'data';
EVENT = 'event';

q.t1 = datenum(2016,12,13,06,30,00); q.t2 = datenum(2016,12,13,08,00,00);
events = IllQuery(servAddr,DB, USER, PWD, EVENT, q);