function sendRigidBody(udpSs,RigidBody)
% SENDRIGIDBODY sends individual rigid body properties via a designated 
% UDP servers (one server per rigid body).
%   SENDRIGIDBODY(udpSs,RigidBody) sends the following rigid body 
%   properties over a UDP servers specified by "udpSs"
%
%   udpSs - cell array containing individual udpS elements tied to unique
%           ports (one for each rigid body).
%
%   RigidBody - rigid body cell array output from OptiTrack. Only the
%               following fields are sent:
%
%       RigidBody(i).Name
%       RigidBody(i).TimeStamp
%       RigidBody(i).isTracked
%       RigidBody(i).Position
%       RigidBody(i).Quaternion
%
%   M. Kutzer, 03Nov2016, USNA

% Updates


%% Check inputs
% TODO - improve error handling
narginchk(1,3);

%% Check UDP Sender
for i = 1:numel(udpSs)
    udpS = udpSs{i};
    switch class(udpS)
        case 'dsp.UDPSender'
            % Valid UDPSender
        otherwise
            error('ScorSend:BadSender',...
                ['Specified UDP Sender must be valid.',...
                '\n\t-> Use "udpS = ScorInitSender(port);" with a valid port ',...
                '\n\t   number to create a valid UDP Sender.']);
    end
end

%% Send message
% Define message format
msgFormat = msgFormatRigidBody;

for i = 1:numel(RigidBody)
    % Create message
    %   $1:Name:TimeStamp,isTracked,P(1),P(2),P(3),Q(1),Q(2),Q(3),Q(4)!'
    if RigidBody(i).isTracked
        % Tracked rigid body
        msg_Send = sprintf(msgFormat,...
            i,...
            strrep(RigidBody(i).Name,' ','_'),... % Replace white spaces with underscores (to simplify parsing)
            RigidBody(i).TimeStamp,...
            RigidBody(i).isTracked,...
            RigidBody(i).Position,...
            RigidBody(i).Quaternion);
    else
        % Not tracked rigid body
        msg_Send = sprintf(msgFormat,...
            i,...
            strrep(RigidBody(i).Name,' ','_'),... % Replace white spaces with underscores (to simplify parsing)
            RigidBody(i).TimeStamp,...
            RigidBody(i).isTracked,...
            zeros(1,3),...
            zeros(1,4));
    end
    % Convert message
    dataSend = uint8(msg_Send);
    % Send message
    step(udpSs{i}, dataSend);
    % Display message
    fprintf('%s\n',msg_Send);
end


