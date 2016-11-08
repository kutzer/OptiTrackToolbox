%% SCRIPT_SendRigidBodies

%% Create OptiTrack object and initialize
obj = OptiTrack;
obj.Initialize;

%% Get initial number of rigid bodies
rb = obj.RigidBody;
n = numel(rb);

%% Setup sender
port0 = 31000;
for i = 1:n
    % Define and open port
    port = port0 + i;
    udpSs{i} = initSender(port);
    % Display port information for each rigid body
    fprintf('---- Rigid Body %d ----\n',i);
    fprintf('\t Rigid Body Name: %s\n',rb(i).Name);
    fprintf('\t     Port Number: %d\n',port);
end

%% Send data
while true
    % Get current rigid body information
    rb = obj.RigidBody;
    % Send rigid body
    sendRigidBody(udpSs,rb);
    % Pause for a fixed interval
    pause(0.008);
end