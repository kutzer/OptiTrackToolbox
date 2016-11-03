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
% TODO - improve message handling
% Receive message
dataReceived = step(udpR);
% Convert message
msg_Rsvd = char(dataReceived');
% Parse message
disp(msg_Rsvd)

RigidBody = [];

