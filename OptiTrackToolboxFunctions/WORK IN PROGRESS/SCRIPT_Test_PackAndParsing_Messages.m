%% SCRIPT_Test_PackAndParsing_Messages
% Define message format
msgFormat = msgFormatRigidBody;

tic;
for frame = 1:500
    % Create simulated rigid body
    t = toc;
    for i = 1:7
        RigidBody(i).Name = sprintf('Rigid Body %d',i);
        RigidBody(i).TimeStamp = t;
        RigidBody(i).isTracked = true;
        RigidBody(i).Position = i*rand(1,3);
        RigidBody(i).Quaternion = rand(1,4);
    end
    
    for i = 1:7
        if RigidBody(i).isTracked
            % Tracked rigid body
            msgSend = sprintf(msgFormat,...
                i,...
                strrep(RigidBody(i).Name,' ','_'),... % Replace white spaces with underscores (to simplify parsing)
                RigidBody(i).TimeStamp,...
                RigidBody(i).isTracked,...
                RigidBody(i).Position,...
                RigidBody(i).Quaternion);
        else
            % Not tracked rigid body
            msgSend = sprintf(msgFormat,...
                i,...
                strrep(RigidBody(i).Name,' ','_'),... % Replace white spaces with underscores (to simplify parsing)
                RigidBody(i).TimeStamp,...
                RigidBody(i).isTracked,...
                zeros(1,3),...
                zeros(1,4));
        end
        
        % Receive message
        msgRsvd = msgSend;
        
        % Display original message
        fprintf('Msg: %s\n',msgRsvd);
        
        % Parse message
        numMsg = sscanf(msgRsvd,msgFormat,[1,inf]);
        idx   = numMsg(1);
        Name  = char(numMsg((     2):(end-11)));
        TimeStamp  = numMsg((end-10):(end- 9));
        isTracked  = numMsg((end- 8):(end- 7));
        Position   = numMsg((end- 6):(end- 4));
        Quaternion = numMsg((end- 3):(end   ));
        
        % Display parsed message
        fprintf(['Prs: ',msgFormat,'\n'],...
            idx,...
            Name,...
            TimeStamp,...
            isTracked,...
            TimeStamp,...
            Position,...
            Quaternion);
        pause(0.01);
    end
    
end