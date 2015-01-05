% Quickly inspect data from Illiad with query q
%
% Long Le
% University of Illinois
% longle1@illinois.edu
%
function events = IllView(db, user, pwd, col, gridCol, q)

events = IllQueryCol(db, user, pwd, col, q);

data = cell(1, numel(events));
y = cell(1, numel(events));
for k = 1:numel(events)
    [data{k}, y{k}, header] = IllDownGrid(db, user, pwd, gridCol, events{k}.filename);
    fs = double(header.sampleRate);
end

C = 'kgrbmy';
figure('units','normalized','outerposition',[0 0 1 1]);
for k = 1:numel(events)
    Y = spectrogram(y{k}, hanning(256), 0);
    subplot(4, ceil(numel(events)/4), k); hold on; ylim([1, 128]);
    imagesc(10*log10(abs(Y))); axis xy;
    
    fdnames = fieldnames(events{k}.TFRidge);
    for l = 1:numel(fdnames)
        cIdx = mod(l-1,length(C))+1;
        time = events{k}.TFRidge.(fdnames{l}).time;
        freq = events{k}.TFRidge.(fdnames{l}).freq;
        plot(time, freq, 'k'); axis tight
        text(time(1), freq(1), fdnames{l});
    end
    title(events{k}.recordDate.x0x24_date);
end