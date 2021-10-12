% https://neurosciencemike.wordpress.com/2016/07/20/start-and-stop-biosemi-recording-by-eeg-trigger/
% First of all you need to locate this config file which is stored at your 
% Biosemi software installation (where you have simply ActiveView programm). 
% It is called Default.cfg and you need to open as text file 
% (I really do recommend you Atom or Notepad++).
% Then you need to find two entries:

% PauseOff=1
% PauseOn=-1
% And change it to your desired value:
% 
% PauseOff=254
% PauseOn=255
% So from now on if you send EEG trigger with value 254 Biosemi starts to record 
% a session (you have to first click start button which initialize recording but 
% still it is paused). Then when you want to stop recording you just send EEG 
% trigger with value of 255.

design.sp           = BioSemiSerialPort();
pauseOff=254;
pauseOn=255;
design.sp.sendTrigger(pauseOff)
design.sp.sendTrigger(pauseOn)
