function [recordedaudio]=ListenToSilence(audiochannel) 

PsychPortAudio('Start',audiochannel,1);
triggerlevel=0.1;
level=10;
recordedaudio=[];
while level > triggerlevel
    % Fetch current audiodata:
    recordedaudio = PsychPortAudio('GetAudioData', audiochannel);
    % Compute maximum signal amplitude in this chunk of data:
    if length(recordedaudio)>500
        level = min(abs(recordedaudio(1,end-500:end)));
    else
        level = 10;
    end
    % Below trigger-threshold?
    if level > triggerlevel
        % Wait for five milliseconds before next scan:
        WaitSecs(1);
    else
        break
    end
end