function [triggered,audiodata]=AutomaticTrigger(audiochannel,Readit,Recordall,design) 
% % we also open an audio channel when we're doing recording
% audiochannel = PsychPortAudio('Open', [], 2, [], 44000, 1);
% % except we set it to 2 instead of 1
% % 2 is for recording mode
% % 3 is for BOTH
% 
% % we need to set aside from space for the sound that we're going to record
% PsychPortAudio('GetAudioData', audiochannel, 10, 5);
PsychPortAudio('Start',audiochannel,1);

triggerlevel=0.1;
level=0;
while level < triggerlevel && (((GetSecs-Readit) - Recordall) < design.trialdeadline)
    % Fetch current audiodata:
    [audiodata] = PsychPortAudio('GetAudioData', audiochannel);
    % Compute maximum signal amplitude in this chunk of data:
    if ~isempty(audiodata)
        level = max(abs(audiodata(1,:)));
    else
        level = 0;
    end
    % Below trigger-threshold?
    if level < triggerlevel
        % Wait for five milliseconds before next scan:
        WaitSecs(0.005);
        triggered=0;
    else
        triggered=1;
    end
end
PsychPortAudio('Stop',audiochannel); % stop the recording channel
