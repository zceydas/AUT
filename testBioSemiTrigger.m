
% event codes
startTrial      = 666;
stim1           = 111;
stim2           = 222;
stim3           = 333;

% trial timing
isi             = 1;
iti             = .1;

% open serial port
sp = BioSemiSerialPort(); 

% run trigger demo
nTrial = 255;
for i = 0:nTrial
    pause(iti)
    
    sp.sendTrigger(i);i
%     pause(isi)
    
%     sp.sendTrigger(stim1);11
%     pause(isi)
%     sp.sendTrigger(stim2);22
%     pause(isi)
%     sp.sendTrigger(stim3);33
%     pause(isi)
%     
    
end
