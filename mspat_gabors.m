function mspat_gabors(t, events, params, visStim, inputs, outputs, audio)
%% Mouse spatial attention task 

newTrial = events.newTrial;
trialNum = events.trialNum; 

interactiveStart = newTrial.delay(1);

wheel = inputs.wheel;
wheel0 = wheel.at(interactiveStart);

deltaWheel = 1/3 * (wheel - wheel0);

% Set up the stimulus parameters
% contrast
leftLowCon = params.LeftLowerContrast;
rightLowCon = params.RightLowerContrast;
leftUpCon = params.LeftUpperContrast;
rightUpCon = params.RightUpperContrast;
% which pair is cued
cuedPair = newTrial.map(@(x) randi(2)); % 1 = upper, 2 = lower
leftCuedCon = iff(cuedPair==1,leftUpCon,leftLowCon);
rightCuedCon = iff(cuedPair==1,rightUpCon,rightLowCon);
% positions
xPos = newTrial.then(-90);
stimToMove = iff(leftCuedCon >= rightCuedCon, 1, 2);

% Set up the trial end conditions
% correct movement
correctMove = iff(stimToMove==1, (deltaWheel + xPos) >= 0,...
    (deltaWheel - xPos) <= 0);
% timeout
trialTimeout = (t - t.at(interactiveStart)) > 5;
timeoutInstant = interactiveStart.setTrigger(trialTimeout);
% incorrect movement
incorrectMove = iff(stimToMove==1,...
    (deltaWheel + xPos) <= (xPos - 45),...
    (deltaWheel - xPos) >= (-xPos + 45));
incorrectInstant = interactiveStart.setTrigger(incorrectMove);
% then end the trial
response = (correctMove + trialTimeout + incorrectMove) > 0;
endTrial = interactiveStart.setTrigger(response);

% Set up the rewards
reward = interactiveStart.setTrigger(correctMove);
totalReward = reward.scan(@plus,0);

% Set up the experiment end conditions
stop = trialNum > 100;
expStop = stop.then(1);

% Set up the actual visual stimulus
% left
leftGratingLower = vis.grating(t);
leftGratingLower.azimuth = deltaWheel + xPos;
leftGratingLower.altitude = params.LowerAltitude;
leftGratingLower.contrast = leftLowCon;
leftGratingLower.show = interactiveStart.to(endTrial);

leftGratingUpper = vis.grating(t);
leftGratingUpper.azimuth = deltaWheel + xPos;
leftGratingUpper.altitude = params.UpperAltitude;
leftGratingUpper.contrast = leftUpCon;
leftGratingUpper.show = interactiveStart.to(endTrial);
% right
rightGratingLower = vis.grating(t);
rightGratingLower.azimuth = deltaWheel - xPos;
rightGratingLower.altitude = params.LowerAltitude;
rightGratingLower.contrast = rightLowCon;
rightGratingLower.show = interactiveStart.to(endTrial);

rightGratingUpper = vis.grating(t);
rightGratingUpper.azimuth = deltaWheel - xPos;
rightGratingUpper.altitude = params.UpperAltitude;
rightGratingUpper.contrast = rightUpCon;
rightGratingUpper.show = interactiveStart.to(endTrial);
% cue
cue = vis.patch(t,'torus');
cue.dims = [34 35];
cue.azimuth = 0;
cue.altitude = iff(cuedPair==1,params.UpperAltitude,params.LowerAltitude);
cue.colour = [0 0 0];
cue.show = interactiveStart.to(endTrial);
% save in visStim
visStim.leftLow = leftGratingLower;
visStim.leftUp = leftGratingUpper;
visStim.rightLow = rightGratingLower;
visStim.rightUp = rightGratingUpper;
visStim.cue = cue;

% Set up the outputs
outputs.reward = reward.then(1);

% Save everything in the events structure
events.endTrial = endTrial;
events.expStop = expStop;
events.interactiveStart = interactiveStart;
events.stimToMove = stimToMove;
events.llCon = leftLowCon;
events.rlCon = rightLowCon;
events.deltaWheel = deltaWheel;
events.correctMove = correctMove;
events.cuedPair = cuedPair;
events.reward = reward;
events.totalReward = totalReward;
events.incorrectMove = incorrectMove;
events.incorrectInstant = incorrectInstant;
events.trialTimeout = trialTimeout;
events.timeoutInstant = timeoutInstant;

% Set up the global parameters
try
    params.LowerAltitude = 35;
    params.UpperAltitude = -35;
    
    contrasts = [0.125 0.25 0.5 1];
    % Combine all contrasts, ignoring equal contrasts
    ll = [];
    rl = [];
    ru = [];
    lu = [];
    for ci = 1:length(contrasts)
        for cii = 1:length(contrasts)
            for ciii = 1:length(contrasts)
                for ciiii = 1:length(contrasts)
                    if (contrasts(ci)~=contrasts(cii)) && (contrasts(ciii)~=contrasts(ciiii))
                        ll = [ll contrasts(ci)];
                        rl = [rl contrasts(cii)];
                        lu = [lu contrasts(ciii)];
                        ru = [ru contrasts(ciiii)];
                    end
                end
            end
        end
    end
    params.LeftLowerContrast = ll;
    params.RightLowerContrast = rl;
    params.LeftUpperContrast = lu;
    params.RightUpperContrast = ru;
catch
end