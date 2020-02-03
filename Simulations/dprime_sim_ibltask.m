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

%% "Real" data from biorxiv paper:

ndata = [-100, .05
    -24.86338797814207, 0.061482820976491936
-12.021857923497265, 0.1844484629294756
-5.73770491803279, 0.31103074141048814
0.13661202185795673, 0.4755877034358047
6.284153005464475, 0.6546112115732369
12.43169398907105, 0.7938517179023508
25, 0.9349005424954793
100, .95];

adata = [-100, .05
    -25, 0.07956600361663635
-12.021857923497265, 0.2531645569620252
-6.147540983606547, 0.4285714285714285
0.13661202185795673, 0.6401446654611211
6.420765027322403, 0.810126582278481
12.295081967213122, 0.9113924050632911
24.8633879781421, 0.9728752260397829
100, .95];

lapse = 0.10; % 10% total (5% on either side)

%% Null: Basic d' model

% possible values of contrast
cvals = [0 6.25 12.5 25 50 100];
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
null.data = data;
null.uvals = udeltas;
null.rvals = rvals;

%% A Lapse bias: High lapse rate, guess according to perfect prior

% possible values of contrast
cvals = [0 6.25 12.5 25 50 100];
% bias, i.e. how often the target is on the right side
bias = 0.8;
% noise
noise = 10;
% lapse rate
lapse = 0.3;
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


%% B real attention bias: less noise on R, more noise on L

% possible values of contrast
cvals = [0 6.25 12.5 25 50 100];
% bias, i.e. how often the target is on the right side
bias = 0.8;
% noise
noise = 10;
% lapse rate
lapse = 0.1;
% number of trials
n = 25000;
% extra noise on R (in %)
noiseChgR = 0.1;
% extra noise on L (in %)
noiseChgL = 1;

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
    Lv = L+randn*(noise*noiseChgL);
    Rv = R+randn*(noise*noiseChgR);
    
    choice = Rv>Lv;
    
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
attmod = struct;
attmod.uvals = udeltas;
attmod.rvals = rvals;

%% C Contrast-dependent bias: guess when confused

% possible values of contrast
cvals = [0 6.25 12.5 25 50 100];
% bias, i.e. how often the target is on the right side
bias = 0.8;
% noise
noise = 7.5;
% lapse rate
lapse = 0.1;
% number of trials
n = 25000;

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

%% Real bias (shift contrast)

% possible values of contrast
cvals = [0 6.25 12.5 25 50 100];
% bias, i.e. how often the target is on the right side
bias = 0.8;
biasEffect = 10;
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
    Lv = (L)+randn*noise;
    Rv = (R)+randn*noise;

    
    choice = Rv>Lv;
    
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
realbias = struct;
realbias.uvals = udeltas-5;
realbias.rvals = rvals;

%% Plotting

h = figure(1); 
clf

subplot(311); hold on

clear p
p(3) = plot(ndata(:,1),ndata(:,2),'-k');
p(4) = plot(adata(:,1),adata(:,2),'-r');

p(1) = plot(null.uvals,null.rvals,'o','MarkerFaceColor','k','MarkerEdgeColor','w');

p(2) = plot(lbias.uvals,lbias.rvals,'o','MarkerFaceColor','r','MarkerEdgeColor','w');

axis([-100 100 0 1]);
set(gca,'XTick',[-100 -50 0 50 100],'YTick',[0 0.5 1],'YTickLabels',{'0%','50%','100%'});

xlabel('\Delta Contrast (R-L, %)');
ylabel('Choices to right (%)');

legend(p,{'No bias','High lapse rate with prior (80:20 R)','Biorxiv 50:50','Biorxiv 80:20'},'Location','SouthEast');
drawPublishAxis;

subplot(312); hold on

p(3) = plot(ndata(:,1),ndata(:,2),'-k');
p(4) = plot(adata(:,1),adata(:,2),'-r');
p(1) = plot(null.uvals,null.rvals,'o','MarkerFaceColor','k','MarkerEdgeColor','w');

p(2) = plot(attmod.uvals,attmod.rvals,'o','MarkerFaceColor','r','MarkerEdgeColor','w');

axis([-100 100 0 1]);
set(gca,'XTick',[-100 -50 0 50 100],'YTick',[0 0.5 1],'YTickLabels',{'0%','50%','100%'});
xlabel('\Delta Contrast (R-L, %)');
ylabel('Choices to right (%)');

legend(p,{'No bias','Attention changes sensitivity model (80:20 R)','Biorxiv 50:50','Biorxiv 80:20'},'Location','SouthEast');
drawPublishAxis;

subplot(313); hold on

clear p
p(3) = plot(ndata(:,1),ndata(:,2),'-k');
p(4) = plot(adata(:,1),adata(:,2),'-r');
p(1) = plot(null.uvals,null.rvals,'o','MarkerFaceColor','k','MarkerEdgeColor','w');

% plot(lbias.uvals,lbias.rvals,'o','MarkerFaceColor','r','MarkerEdgeColor','w');

p(2) = plot(cdep.uvals,cdep.rvals,'o','MarkerFaceColor','r','MarkerEdgeColor','w');
% invert this in blue, to match the IBL paper
% p(3) = plot(-fliplr(cdep.uvals),1-cdep.rvals,'o','MarkerFaceColor','b','MarkerEdgeColor','w');
% p(3) = plot(realbias.uvals,realbias.rvals,'o','MarkerFaceColor','g','MarkerEdgeColor','w');

axis([-100 100 0 1]);
set(gca,'XTick',[-100 -50 0 50 100],'YTick',[0 0.5 1],'YTickLabels',{'0%','50%','100%'});
xlabel('\Delta Contrast (R-L, %)');
ylabel('Choices to right (%)');

legend(p,{'No bias','Guess when uncertain (80:20 R)','Biorxiv 50:50','Biorxiv 80:20'},'Location','SouthEast');
% legend(p,{'No bias','Guess when uncertain (80:20 R)','Guess when uncertain (20:80 R)'},'Location','SouthEast');
drawPublishAxis;

% subplot(312); hold on