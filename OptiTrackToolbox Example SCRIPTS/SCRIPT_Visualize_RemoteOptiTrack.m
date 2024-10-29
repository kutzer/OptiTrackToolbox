%% SCRIPT_Visualize_RemoteOptiTrack
% This script visualizes data from Motive using either the Unicast or
% Multicast interface.
%
%   M. Kutzer, 08Jan2021, USNA

% Updates
%   18Oct2024 - Updated documentation and unicast/multicast distinction

%% Create OptiTrack object
obj = OptiTrack;

%% Initialize
% Specify unicast or multicast
ConnectionType = 'unicast';
%ConnectionType = 'multicast';

switch ConnectionType
    case 'unicast'
        % Option 1:
        % IP should match the "Local Interface" IP in Motive Data Streaming 
        % and "Unicast" should be enabled.
        IP = '10.24.6.17';
    case 'multicast'
        % Option 2:
        IP = '239.255.42.99';   % NatNet Version >  2.0
        %IP = '224.0.0.1';      % NatNet Version <= 2.0
    otherwise
        error('Unexpected connection type.');
end

% Initialize object
obj.Initialize(IP,ConnectionType);

%% Initialize figure and axes
fig = figure('Name','SCRIPT_Visualize_RemoteOptiTrack');
axs = axes('Parent',fig,'NextPlot','add','DataAspectRatio',[1 1 1]);
view(axs,3);
ttl = title(axs,'Initializing...');
xlabel(axs,'x (mm)');
ylabel(axs,'y (mm)');
zlabel(axs,'z (mm)');

%% Animate feed from Motive
% Initialize empty transform handle array
h_b2a = hgtransform;
h_b2a(1) = [];

% Update information from Motive
while true
    % Get current rigid body information
    frameRate = obj.FrameRate;
    rigidBody = obj.RigidBody;
    nRigidBodies = numel(rigidBody);
    
    % Check if figure is still valid
    if ~ishandle(fig)
        return
    end

    % Update title
    ttl_str = sprintf('%4d Rigid Bodies Tracked',nRigidBodies);
    if isempty(frameRate)
        ttl_str = sprintf('%s, Frame Rate: NaN',ttl_str);
    else
        ttl_str = sprintf('%s, Frame Rate: %.2f',ttl_str,frameRate);
    end
    set(ttl,'String',ttl_str);

    % Update rigid bodies
    set(h_b2a,'Visible','off');
    for i = 1:nRigidBodies
        % Check if figure is still valid
        if ~ishandle(fig)
            return
        end
        
        if numel(h_b2a) < i
            % Add new rigid bodies
            h_b2a(i) = triad('Parent',axs,'Matrix',rigidBody(i).HgTransform);
        else
            % Update existing rigid bodies
            set(h_b2a(i),'Matrix',rigidBody(i).HgTransform,'Visible','on')
        end

    end
    drawnow
end