%% SCRIPT_ReceiveRigidBodies

%% Define number of rigid bodies
n = 3;

%% Setup receiver
port0 = 31000;
for i = 1:n
    % Define and open port
    port = port0 + i;
    udpRs{i} = initReceiver(port);
    % Display port information for each rigid body
    fprintf('---- Rigid Body %d ----\n',i);
    fprintf('\t     Port Number: %d\n',port);
end

%% Receive data
while true
    % Get current rigid body information
    RigidBody = receiveRigidBody(udpRs);
end