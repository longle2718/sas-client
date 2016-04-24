function allEvents = IllQuery2(servAddr,DB,USER,PWD,EVENT,q)
% events = IllQuery2(q)
% Concatnate events from multiple query
%
% Long Le
% University of Illinois
%

T1 = q.t1;
T2 = q.t2;

T = T1:6/24:T2;
allEvents = [];
for k = 1:numel(T)-1
    q.t1 = T(k);
    q.t2 = T(k+1);
    events = IllQuery(servAddr,DB,USER,PWD,EVENT,q);
    allEvents = [allEvents events];
end
