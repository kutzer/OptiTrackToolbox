function sendRigidBody(udpS,RigidBody)
% SENDRIGIDBODY sends rigid body properties via a designated UDP server.
%   SENDRIGIDBODY(udpS,RigidBody) sends the following rigid body properties
%   over a UDP server specified by "udpS"
%       RigidBody(i).Name
%       RigidBody(i).TimeStamp
%       RigidBody(i).Position
%       RigidBody(i).Quaternion
%
%   M. Kutzer, 03Nov2016, USNA

% Updates


%% Check inputs
% TODO - improve error handling
narginchk(1,3);

%% Check UDP Sender
switch class(udpS)
    case 'dsp.UDPSender'
        % Valid UDPSender
    otherwise
        error('ScorSend:BadSender',...
            ['Specified UDP Sender must be valid.',...
             '\n\t-> Use "udpS = ScorInitSender(port);" with a valid port ',...
             '\n\t   number to create a valid UDP Sender.']);
end

%% Send message
% Initiate message
step(udpS, uint8('$$$'));
for i = 1:numel(RigidBody)
    % Create message
    %   $1:Name:TimeStamp,P(1),P(2),P(3),Q(1),Q(2),Q(3),Q(4)!'
    msg_Send = sprintf('$%d:%s:%.3f,%.2f,%.2f,%.2f,%.7f,%.7f,%.7f!');
    % Convert message
    dataSend = uint8(msg_Send);
    % Send message
    step(udpS, dataSend);
end
% End message
step(udpS, uint8('!!!'));