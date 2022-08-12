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
%   NOTE: This code assumes Data Streaming -> Up Axis -> Y Up in the Motive
%   Software.
%
%   See also SCRIPT_VisualizeAndSave_OptiTrack
%
%   M. Kutzer 12Aug2022, USNA


%% Clear workspace, close all figures, clear command window
clear all
close all
clc

%% Load rbData
uiopen('*.mat');
tf = exist('rbData','var');
if ~tf
    error('*.mat file must contain an "rbData" variable (see SCRIPT_VisualizeAndSave_OptiTrack.m');
end

%% Extract position information
for i = 1:numel(rbData)
    H_i2w = rbData(i).HgTransform;
    for j = 1:numel(H_i2w)
        X_i2w{i}(:,j) = H_i2w{j}(1:3,4);
    end
end

%% Define initial visualization limits
X_all = [];
for i = 1:numel(X_i2w)
    X_all = [X_all, X_i2w{i}];
end
X_lims = [min(X_all,[],2),max(X_all,[],2)];

%% Define reference frame scale 
dX_lims = max( diff(X_lims,1,2) );
hgScale = dX_lims/10;

%% Update visualization limits
X_lims = X_lims + 1.2*dX_lims*[-ones(3,1), ones(3,1)];

%% Create and setup figure and axes (downward looking FOV)
fig = figure('Name','Visualize OptiTrack rbData','Color',[0,0,0]);
axs = axes('Parent',fig,'DataAspectRatioMode','manual',...
	'DataAspectRatio',[1 1 1],'NextPlot','add','View',[180,0]);
ttl = title(axs,'STATUS')
% Label axes
xlabel(axs,'x (mm)');
ylabel(axs,'y (mm)');
zlabel(axs,'z (mm)');

% Update limits to match tracking volume
set(axs,'xlim',X_lims(1,:),'ylim',X_lims(2,:),'zlim',X_lims(3,:));

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
t_round  = round(t_sample,2);   % Rounded to *assumed* 100Hz sample rate
%% Allow user to specify video filename


%% Visualize data
% Define time stamps for assumed 100Hz sample rate
t_100Hz = t_sample(1):(1/100):t_sample(end);
for t = t_100Hz
    for i = 1:numel(rbData)
        % Find timestamp index
        j = find(t == rbData(i).TimeStamp); 
        % Update plot
        if isempty(j)
            set(h_i2w(i),'Visible','off');
        else
            set(h_i2w(i),'Visible','on','Matrix',rbData(i).HgTransform{j});
        end
    end
    drawnow
end