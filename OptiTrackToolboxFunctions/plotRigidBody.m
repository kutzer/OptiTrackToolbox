function hg = plotRigidBody(varargin)
% plotRigidBody
%   plotRigidBody(RigidBody)
%   plotRigidBody(RigidBody, RigidBodySettings)
%   plotRigidBody(axs,___)
%
%   M. Kutzer 20Jan2016, USNA

%% Parse inputs
narginchk(1,3);
% Assign output axes (or hgtransform)
if ishandle(varargin{1})
    axsOut = varargin{1};
    idx = 2;
else
    axsOut = gca;
    idx = 1;
end
% Assign rigid body
if nargin >= idx
    rigidBody = varargin{idx};
    idx = idx+1;
else
    error('Rigid body information must be specified (obj.RigidBody).');
end
% Assign rigid body settings
if nargin >= idx
   rbSettings = varargin{idx};
else
    % Set default values for rigid body settings.
    % NOTE: This is identical to the end of the obj.Initialize code in the 
    %   OptiTrack classdef. 
    for i = 1:numel(rigidBody)
        rbSettings(i).DisplayName = rigidBody(i).Name;
        rbSettings(i).Color = 'b';
        rbSettings(i).MarkerDesignPosition = ...
            rigidBody(i).MarkerPosition;
        rbSettings(i).HgOffset = eye(4);
    end
end

%% Create plot
% Create invisible figure
fig = figure('Visible','On');
axs = axes('Parent',fig,'NextPlot','add','DataAspectRatio',[1 1 1]);
view(axs,3);
% Define unit sphere surface coordinates
[X,Y,Z] = sphere(20);
for i = 1:numel(rigidBody)
    % Get Marker position
    mPos = rigidBody(i).MarkerPosition;
    % Move marker position to body-fixed frame
    H = rigidBody(i).HgTransform;
    mPos(4,:) = 1;
    mPos = minv(H)*mPos;
    % Get marker diameter
    mSze = rigidBody(i).MarkerSize;
    
    % Apply rigid body settings
    tag = rbSettings(i).DisplayName;
    color = rbSettings(i).Color;
    
    n = numel(mSze);
    for j = 1:n
        ptch(j) = patch(surf2patch(...
            (mSze(j)/2)*X + repmat(mPos(1,j),size(X)),...
            (mSze(j)/2)*Y + repmat(mPos(2,j),size(Y)),...
            (mSze(j)/2)*Z + repmat(mPos(3,j),size(Z))),...
            'FaceColor',color,'EdgeColor','None');
        set(ptch(j),'Tag',sprintf('%s, Marker %d',tag,j));
    end
    
    lims = [xlim(axs); ylim(axs); zlim(axs)];
    scle = max( lims(:,2) - lims(:,1) );
    
    ishandle(axsOut)
    
    % Create triad
    hg(i) = triad('Parent',axsOut,'Scale',1.2*scle,'LineWidth',2,...
        'Matrix',H,'Tag',tag);
    % Set markers to correct frame
    set(ptch,'Parent',hg(i));
end
delete(fig);
