obj = OptiTrack;
obj.Initialize('10.60.69.244','unicast');
%obj.Initialize('10.60.69.244','multicast');

%%
fig = figure;
axs = axes;
hold(axs,'on');
daspect(axs,[1 1 1]);
view(axs,3);

rigidBody = obj.RigidBody;
for i = 1:numel(rigidBody)
    hg(i) = triad('Matrix',rigidBody(i).HgTransform);
end

while true
    rigidBody = obj.RigidBody;
    for i = 1:numel(rigidBody)
        if ~ishandle(fig)
            break
        end
        if numel(rigidBody) < i
            hg(i) = triad('Matrix',rigidBody(i).HgTransform);
        else
            set(hg(i),'Matrix',rigidBody(i).HgTransform)
        end
        if numel(hg(i)) > numel(rigidBody)
            set(hg(i+1:end),'Visible','off');
        end
    end
    drawnow
end