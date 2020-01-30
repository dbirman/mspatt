function precomputBackground(myscreen,stimulus)
%% Code originally from Joshua Ryu at Stanford (Gardner Lab)
% Generates phase-scrambled noise by scrambling a Gaussian
% generate a lot of noise
% takes about 12 minutes to generate on the stimulus test computer. 
savefile = '/Users/gru/proj/grustim/trackpos.mat';

%% noise
% background noise
downsample_timeRes  = 1;
downsample_spatRes  = 1;

ntrials             = 1; %7*9; %7 trials * 9 conditions
nframes             = 1; % 30s; %/downsample_timeRes; 

for idx = 1:ntrials
    tic
    xsize_deg          = round(500/downsample_spatRes);
    ysize_deg          = round(500/downsample_spatRes);

    backgaussian = mglMakeGaussian(xsize_deg,ysize_deg,1,1,0,0,5,5)*255;
    gaussianFFT = getHalfFourier(backgaussian);

    for idx2 = 1:nframes
        disp(idx2/nframes);
        back                        = gaussianFFT; %0.02s
        back.phase                  = rand(size(back.mag))*2*pi; % scramble phase % 0.02s
%         backgroundnoise             = reconstructFromHalfFourier(back);   %0.04s

        backgroundnoise             = round(reconstructFromHalfFourier(back));   %0.04s
        backgroundnoise = backgroundnoise./max(backgroundnoise(:));
    toc
    end
    
end

imagesc(backgroundnoise);