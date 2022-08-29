% SCRIPT_rbDataVisualize_OptiTrack
%   Load and visualize "rbData" produced from
%   "SCRIPT_VisualizeAndSave_OptiTrack.m"
%
%   Input(s) [loaded from user specified *.mat file]
%       rbData - structured array containing saved data
%           rbData(i).Name          - character array specifying ith rigid
%                                     body name (e.g. 'Rigid Body 1')
%           rbData(i).TimeStamp     - 1xN array containing frame time stamp
%                                     of the ith rigid body (seconds)
%           rbData(i).HgTransform   - 1xN cell array containing rigid body
%                                     pose (position and orientation)
%                                     relative to the OptiTrack World Frame
%                                     represented using a 4x4 homogeneous
%                                     rigid body transformation (i.e. an
%                                     element of the Special Euclidean
%                                     Group SE(3))
%
%   NOTE: This code assumes Data Streaming -> Up Axis -> Y Up in the 
%         Motive Software. This assumption only impacts the default view
%         used for the visualization.
%
%   See also SCRIPT_VisualizeAndSave_OptiTrack
%
%   M. Kutzer 12Aug2022, USNA


%% Clear workspace, close all figures, clear command window
clearvars -except fpath
close all
clc

%% Load rbData
% Load file
%uiopen('*.mat');
if ~exist('fpath','var')
    fpath = cd;
end
[fname,fpath] = uigetfile('*.mat','Select *.mat file containing rbData.',fpath);
if ischar(fname)
    load( fullfile(fpath,fname) );
else
    clear fpath
    error('User cancelled action. No file selected.');
end

% Check for proper contents
tf = exist('rbData','var');
if ~tf
    error('*.mat file must contain an "rbData" variable (see SCRIPT_VisualizeAndSave_OptiTrack.m');
end

%% Extract position information from rbData
for i = 1:numel(rbData)
    H_i2w = rbData(i).HgTransform;
    for j = 1:numel(H_i2w)
        X_i2w{i}(:,j) = H_i2w{j}(1:3,4);
    end
end

%% Define initial visualization limits and coordinate frame scale
%   NOTE: The variable "rbData" does include sufficient information
%         to use plotRigidBody.m. This script will create a rough
%         approximation of this using rigid body pose information.
%
%         hg = plotRigidBody(axs,obj.RigidBody); % <--- CANNOT USE

% Approximate visualization axes limits
X_all = [];
for i = 1:numel(X_i2w)
    X_all = [X_all, X_i2w{i}];
end
X_lims = [min(X_all,[],2),max(X_all,[],2)];

% Define reference frame scale for visualization
dX_lims = max( diff(X_lims,1,2) );
hgScale = dX_lims/10;

% Update visualization axes limits
X_lims = X_lims + hgScale*[-ones(3,1), ones(3,1)];

%% Create and setup figure and axes (downward looking FOV)
fig = figure('Name','Visualize OptiTrack rbData','Color',[1,1,1]);
axs = axes('Parent',fig,'DataAspectRatioMode','manual',...
    'DataAspectRatio',[1 1 1],'NextPlot','add','View',[180,0]);
ttl = title(axs,'STATUS');

% Label axes
xlabel(axs,'x (mm)');
ylabel(axs,'y (mm)');
zlabel(axs,'z (mm)');

% Update limits to match tracking volume
set(axs,'xlim',X_lims(1,:),'ylim',X_lims(2,:),'zlim',X_lims(3,:));

%% Create position track visualizations
for i = 1:numel(X_i2w)
    plt(i) = plot3(axs,X_i2w{i}(1,:),X_i2w{i}(2,:),X_i2w{i}(3,:),'.',...
        'MarkerSize',3);
end

%% Create rigid body visualizations
%   NOTE: The variable "rbData" does include sufficient information
%         to use plotRigidBody.m. This script will create a rough
%         approximation of this using rigid body pose information.
%
%         hg = plotRigidBody(axs,obj.RigidBody); % <--- CANNOT USE
for i = 1:numel(rbData)
    h_i2w(i) = triad('Parent',axs,'Tag',rbData(i).Name,'Scale',hgScale,...
        'LineWidth',1.5);
    x_i2w(i) = plot3(nan,nan,nan,'.','Color',rand(1,3),'MarkerSize',3);
end

%% Define common time stamp
t_sample = [];
for i = 1:numel(rbData)
    t_sample = [t_sample, reshape(rbData(i).TimeStamp,1,[])];
end
t_sample = unique(t_sample);    % Ordered unique time stamps
t_round  = round(t_sample,2);   % Rounded to *assume* 100Hz sample rate

%% Allow user to specify video filename
[~,bname,~] = fileparts(fname);
fnow = cd;
cd(fpath);
[vfile,vpath] = uiputfile('*.mp4','Save Data Animations',bname);
cd(fnow);
if isequal(vfile,0) || isequal(vpath,0)
    fprintf(2,'User did not define video filename.\n')
    makeVideo = false;
else
    makeVideo = true;
    % Define "raw" filename
    [~,bname,bext] = fileparts(vfile);
    rfile = sprintf('%s_RAW.%s',bname,bext);

    % Create video files
    vidRaw = VideoWriter( fullfile(vpath,rfile),'MPEG-4' );
    vidInt = VideoWriter( fullfile(vpath,vfile),'MPEG-4' );

    open(vidRaw);
    open(vidInt);
end

%% Parse and visualize time-sync'd raw data
ZERO = 1e-6; % Define "close-enough" zero value
% Define time stamps for assumed 100Hz sample rate
t_100Hz = t_round(1):(1/100):t_round(end);

% Initialize data for interpolation
t_i2w_i = cell(numel(rbData),1);
H_i2w_i = cell(numel(rbData),1);
v_i2w_i = cell(numel(rbData),1);

% Clear position track visualizations
for i = 1:numel(plt)
    clearLine(plt(i));
end

% Parse & visualize
for k = 1:numel(t_100Hz)
    t = t_100Hz(k);     % Approximate time
    t0 = t-t_sample(1); % Time relative to initial time
    set(ttl,'String',sprintf('t = %5.2f',t0));
    for i = 1:numel(rbData)
        % Find timestamp index
        j = find(t == round(rbData(i).TimeStamp,2));
        % Update plot
        if isempty(j)
            % No data for current frame, hide rigid body
            set(h_i2w(i),'Visible','off');
        else
            % Check if transformation is valid
            H_i2w = rbData(i).HgTransform{j};
            if isSE(H_i2w,ZERO)
                % Valid transformation, move rigid body
                set(h_i2w(i),'Visible','on','Matrix',H_i2w);

                % Display all frames for sparse data set (DEBUG)
                %triad('Parent',axs,'Tag',rbData(i).Name,'Scale',(2/3)*hgScale,...
                %    'LineWidth',1.0,'Matrix',H_i2w);

                % Collect good data
                t_i2w_i{i}(end+1) = t0;
                H_i2w_i{i}{end+1} = H_i2w;
                v_i2w_i{i}(:,end+1) = decoupledSEtoV(H_i2w);

                % Track position
                appendLine(plt(i),v_i2w_i{i}(4:6,end));
            else
                % Invalid transformation, hide rigid body
                set(h_i2w(i),'Visible','off');
            end
        end
    end
    drawnow

    if makeVideo
        frame = getframe(fig);
        writeVideo(vidRaw,frame);
    end

end

%% Fit cubic splines for interpolating data to create a smooth view
for i = 1:numel(v_i2w_i)
    if t_i2w_i{i}(1) ~= 0
        % Artificially add the initial position
        t_i2w_i{i} = [0, t_i2w_i{i}];
        v_i2w_i{i} = [v_i2w_i{i}(:,1),v_i2w_i{i}];
    end

    pp{i} = fitNDspline(t_i2w_i{i},v_i2w_i{i});
end

%% Animate smooth view

% Clear position track visualizations
for i = 1:numel(plt)
    clearLine(plt(i));
end

% Visualize
for k = 1:numel(t_100Hz)
    t = t_100Hz(k);     % Approximate time
    t0 = t-t_sample(1); % Time relative to initial time
    set(ttl,'String',sprintf('t = %5.2f',t0));
    for i = 1:numel(pp)
        % Find timestamp index
        j = find(t == round(rbData(i).TimeStamp,2));

        % Check final breakpoint
        if t0 <= pp{i}(1).breaks(end)
            % Valid transformation, move rigid body

            % Calculate interpolated pose
            v_i2w = ppvalND(pp{i},t0);
            H_i2w = decoupledVtoSE(v_i2w);
            
            % Move rigid body
            set(h_i2w(i),'Visible','on','Matrix',H_i2w);
            
            % Track position
            appendLine(plt(i),v_i2w(4:6));
        else
            set(h_i2w(i),'Visible','off');
        end
    end
    drawnow

    if makeVideo
        frame = getframe(fig);
        writeVideo(vidInt,frame);
    end
end

if makeVideo
    close(vidRaw);
    close(vidInt);
end

%% Internal functions
% We are using these to interpolate pose data

function v = decoupledSEtoV(H)
% Map SE to decoupled vector representation

R = H(1:3,1:3);
d = H(1:3,4);

%v(1:3,:) = vee(logSO(R));  % Exponential map of SO
v(1:3,:) = rotm2eul(R).';   % ZYX Euler angles
v(4:6,:) = d;

end

% ---

function H = decoupledVtoSE(v)
% Map vector representation of SE to SE

%R = expSO(wedge(v(1:3)));  % Exponential map of SO
R = eul2rotm(v(1:3,:).');   % ZYX Euler angles
d = v(4:6);

H = eye(4);
H(1:3,1:3) = R;
H(1:3,4) = d;

end

% ---

function ppN = fitNDspline(x,yN)
% Fit n-dimensional cubic spline

for j = 1:size(yN,1)
    ppN(j) = spline(x,yN(j,:));
end

end

% ---

function y = ppvalND(ppN,x)
% Evaluate n-dimensional cubic spline
y = nan(numel(ppN),numel(x));
for j = 1:numel(ppN)
    y(j,:) = ppval(ppN(j),x);
end

end

% ---