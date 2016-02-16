% SCRIPT_Visualize_OptiTrack
%% 
clear all
close all
clc

%% 
obj = OptiTrack;
obj.Initialize;

%% 
fig = figure;
axs = axes('Parent',fig);
daspect(axs,[1 1 1]);
xlabel(axs,'x');
ylabel(axs,'-z');
zlabel(axs,'y');

% Create global frame
%gf = triad('Parent',axs,'LineWidth',2.5,'Scale',35,'Matrix',Rx(-pi/2));

% Update limits to match tracking volume
xx = [-3100,3200];
yy = [0,3000];
zz = [-5100,6000];
%set(axs,'xlim',xx,'ylim',sort(-zz),'zlim',yy);
set(axs,'xlim',xx,'ylim',yy,'zlim',zz);

% Create rigid bodies
hg = plotRigidBody(axs,obj.RigidBody);

%% Views
view(axs,[180,0]); % OptiTrack Top View
%view(2)
%%
while true
    rb = obj.RigidBody;
    for i = 1:numel(rb)
        if rb(i).isTracked
            set(hg(i),'Matrix',rb(i).HgTransform,'Visible','On');
        else
            set(hg(i),'Visible','Off');
        end
    end
    drawnow
end