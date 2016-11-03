%% SCRIPT_Test_sendRigidBody
% Designate port
port = 31500;
% Initialize sender
udpS = initSender(port);

%% Create default rigid bodies for sending
tic;
for frame = 1:500
    % Create simulated rigid body
    t = toc;
    for i = 1:7
        RigidBody(i).Name = sprintf('Rigid Body %d',i);
        RigidBody(i).TimeStamp = t;
        RigidBody(i).Position = i*rand(1,3);
        RigidBody(i).Quaternion = rand(1,4);
    end
    % Send rigid body
    sendRigidBody(udpS,RigidBody);
    % Display update to command window
    fprintf('Frame %d Sent, t = %f\n',[frame,t]);
end