%% IBL Task d' Simulation
% Nick and I discussed on 1/21/20 how to interpret the d' changes from the
% IBL behavior paper (link:
% https://www.biorxiv.org/content/10.1101/2020.01.17.909838v2.full.pdf)
%
% The mice in the paper are incorporating a biased prior (80:20 L:R or vice
% versa) into their responses. The result of this is a horizontal shift in
% their psychometric functions. What kinds of models of behavior could
% explain this?
%
% A) Mice have a (relatively) high lapse rate, perhaps when lapsing they are now biased
% to guess R>L or vice versa. Does this explain the data?
% B) Mice correctly incorporate the prior trial by trial by shifting
% attention to one side, making it more likely that they will get that side
% right but less likely that they will get the other side right.
% C) Mice are biased in a contrast-dependent manner, where when the task is
% more difficult they are more likely to use the prior than when the task
% is hard.

%% Null: Basic d' model

% possible values of contrast
cvals = [0 6.25 12.5 25 100];
% bias, i.e. how often the target is on the right side
bias = 0.5;
% noise
noise = 10;
% lapse rate
lapse = 0.1;
% number of trials
n = 10000;

% COLUMNS OF DATA
%   1     2        3      4      5     6       7        8      9
% CVAL   LCON    RCON   L+noi  R+noi  choice correct  corrR  delta
data = zeros(n,9);

% do a loop for clarity
for i = 1:n
    C = cvals(randi(length(cvals)));
    clear L R 
    corrR = rand<bias;
    if corrR
        R = C; L = 0;
    else
        L = C; R = 0;
    end
    
    % generate randn based on the signals and choose a side
    Lv = L+randn*noise;
    Rv = R+randn*noise;
    
    choice = Rv>Lv;
    if rand<lapse % lapse (guess)
        choice = rand<0.5;
    end
    corr = corrR==choice;
    
    data(i,:) = [C L R Lv Rv choice corr corrR R-L];
end

% plotting

% get the proportion in each cval group of choices to the right (mean of
% column 6)
udeltas = unique(data(:,9));
rvals = zeros(1,length(udeltas));
for ui = 1:length(udeltas)
    data_ = data(data(:,9)==udeltas(ui),:);
    rvals(ui) = mean(data_(:,6));
end

% save the data
null = struct;
null.uvals = udeltas;
null.rvals = rvals;

%% A Lapse bias: High lapse rate, guess according to perfect prior

% possible values of contrast
cvals = [0 6.25 12.5 25 100];
% bias, i.e. how often the target is on the right side
bias = 0.8;
% noise
noise = 10;
% lapse rate
lapse = 0.10;
% number of trials
n = 10000;

% COLUMNS OF DATA
%   1     2        3      4      5     6       7        8      9
% CVAL   LCON    RCON   L+noi  R+noi  choice correct  corrR  delta
data = zeros(n,9);

% do a loop for clarity
for i = 1:n
    C = cvals(randi(length(cvals)));
    clear L R 
    corrR = rand<bias;
    if corrR
        R = C; L = 0;
    else
        L = C; R = 0;
    end
    
    % generate randn based on the signals and choose a side
    Lv = L+randn*noise;
    Rv = R+randn*noise;
    
    choice = Rv>Lv;
    if rand<lapse % lapse (guess according to prior)
        choice = rand<bias;
    end
    corr = corrR==choice;
    
    data(i,:) = [C L R Lv Rv choice corr corrR R-L];
end

% plotting

% get the proportion in each cval group of choices to the right (mean of
% column 6)
udeltas = unique(data(:,9));
rvals = zeros(1,length(udeltas));
for ui = 1:length(udeltas)
    data_ = data(data(:,9)==udeltas(ui),:);
    rvals(ui) = mean(data_(:,6));
end

% save the data
lbias = struct;
lbias.uvals = udeltas;
lbias.rvals = rvals;

%% C Contrast-dependent bias: guess when confused

% possible values of contrast
cvals = [0 6.25 12.5 25 100];
% bias, i.e. how often the target is on the right side
bias = 0.8;
% noise
noise = 10;
% lapse rate
lapse = 0.1;
% number of trials
n = 10000;

% COLUMNS OF DATA
%   1     2        3      4      5     6       7        8      9
% CVAL   LCON    RCON   L+noi  R+noi  choice correct  corrR  delta
data = zeros(n,9);

% do a loop for clarity
for i = 1:n
    C = cvals(randi(length(cvals)));
    clear L R 
    corrR = rand<bias;
    if corrR
        R = C; L = 0;
    else
        L = C; R = 0;
    end
    
    % generate randn based on the signals and choose a side
    Lv = L+randn*noise;
    Rv = R+randn*noise;
    
    choice = Rv>Lv;
    
    if abs(Rv-Lv)<(noise*1)
        % if the decision was "hard", then use the prior
        choice = rand<bias;
    end
    
    if rand<lapse % lapse (guess randomly)
        choice = rand<0.5;
    end
    
    corr = corrR==choice;
    
    data(i,:) = [C L R Lv Rv choice corr corrR R-L];
end

% plotting

% get the proportion in each cval group of choices to the right (mean of
% column 6)
udeltas = unique(data(:,9));
rvals = zeros(1,length(udeltas));
for ui = 1:length(udeltas)
    data_ = data(data(:,9)==udeltas(ui),:);
    rvals(ui) = mean(data_(:,6));
end

% save the data
cdep = struct;
cdep.uvals = udeltas;
cdep.rvals = rvals;

%% Plotting

h = figure; hold on

plot(null.uvals,null.rvals,'o','MarkerFaceColor','k','MarkerEdgeColor','w');

% plot(lbias.uvals,lbias.rvals,'o','MarkerFaceColor','r','MarkerEdgeColor','w');

plot(cdep.uvals,cdep.rvals,'o','MarkerFaceColor','r','MarkerEdgeColor','w');
% invert this in blue, to match the IBL paper
plot(-fliplr(cdep.uvals),1-cdep.rvals,'o','MarkerFaceColor','b','MarkerEdgeColor','w');