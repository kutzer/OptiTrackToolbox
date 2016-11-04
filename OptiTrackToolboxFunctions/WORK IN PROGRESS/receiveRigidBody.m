function RigidBody = receiveRigidBody(udpR)
% RECEIVERIGIDBODY sends rigid body properties via a port designated by a 
% UDP receiver.
%   RigidBody = RECEIVERIGIDBODY(udpR) receives the following rigid body 
%   properties via a port designated by "udpR"
%       RigidBody(i).Name
%       RigidBody(i).TimeStamp
%       RigidBody(i).Position
%       RigidBody(i).Quaternion
%
%   M. Kutzer, 03Nov2016, USNA

% Updates


%% Check inputs
% TODO - improve error handling
narginchk(1,1);

%% Check UDP Receiver
switch class(udpR)
    case 'dsp.UDPReceiver'
        % Valid UDPReceiver
    otherwise
        error('ScorReceive:BadReceiver',...
            ['Specified UDP Receiver must be valid.',...
             '\n\t-> Use "udpR = ScorInitReceiver(port);" with a valid port ',...
             '\n\t   number to create a valid UDP Receiver.']);
end

%% Receive message
% Define message format
msgFormat = msgFormatRigidBody;

% Receive message
dataReceived = step(udpR);
% Convert message
msgRsvd = char(dataReceived');
% Parse message
numMsg = sscanf(msgRsvd,msgFormat,[1,inf]);
idx   = numMsg(1);
Name  = char(numMsg((     2):(end-11)));
TimeStamp  = numMsg((end-10):(end- 9));
isTracked  = numMsg((end- 8):(end- 7));
Position   = numMsg((end- 6):(end- 4));
Quaternion = numMsg((end- 3):(end   ));

% Display message
fprintf('Bytes Received: %d\n',numel(msgRsvd));
fprintf('%s\n',msgRsvd);

RigidBody = [];

