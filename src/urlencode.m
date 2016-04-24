function u = urlencode(s)
% custom urlencode from http://www.rosettacode.org/wiki/URL_encoding#MATLAB_.2F_Octave
% needed for binary compiling of m files
%
% Long Le <longle1@illinois.edu>
% University of Illinois
%
	u = '';
	for k = 1:length(s),
		if isstrprop(s(k), 'alphanum')
			u(end+1) = s(k);
		else
			u=[u,'%',dec2hex(s(k)+0)];
		end; 	
	end
end