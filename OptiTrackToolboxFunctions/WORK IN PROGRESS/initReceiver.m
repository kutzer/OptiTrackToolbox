function udpR = initReceiver(port)
% INITRECEIVER defines a UDP client for receiving information from to a 
% remote server.
%   udpR = INITRECEIVER(port) initializes a UDP Receiver tied to the 
%   designated port (suggested ports 31000 - 32000) using a default IP of
%   '0.0.0.0' allowing data to be accepted from any remote IP address.
%
%   Note: This function requires the DSP System Toolbox.
%
%   See also initSender
%
%   M. Kutzer, 31Oct2016, USNA

% Updates


%% Check inputs
% TODO - improve error handling
narginchk(1,1);
% TODO - check port range

%% Create UDP receiver
udpR = dsp.UDPReceiver('LocalIPPort',port);