%% SCRIPT_SaveData_OptiTrack
%   Save rigid body data regardless of whether rigid bodies enter/exit the
%   MoCap field of view.
%
%   Output(s)
%       rbDataCell - 1xM cell array containing rigid body data recovered
%                    from the OptiTrack.
%           rbDataCell{i} - 1xN structured array contaning rigid body
%                           information for the "ith" index
%
%   NOTE: This script does not ensure that all cell elements are unique.
%
%   M. Kutzer, 09Aug2022, USNA

%% Clear workspace, close all figures, clear command window
clear all
close all
clc

%% Create OptiTrack object and initialize
obj = OptiTrack;
obj.Initialize;

%% Prompt user to begin test
while true
    % Get visible rigid bodies
    rb = obj.RigidBody;
    % Define number of visible rigid bodies
    n = numel(rb);
    
    % Define message for questdlg
    msg = sprintf(...
        ['Total Visible Rigid Bodies: %d\n\n',...
        'Would you like to begin collecting data?'],n);
    
    % Define buttons for questdlg
    bttns{1} = 'Begin';
    bttns{2} = 'Check Rigid Bodies';
    bttns{3} = 'Cancel';
    % Prompt user
    answer = questdlg(msg,'Begin Test',bttns{:},bttns{2});

    % Check answwer
    switch answer
        case bttns{1}
            % Begin collecting data
            drawnow
            break
        case bttns{2}
            % Get new rigid body data and start again
            drawnow
            continue
        case bttns{3}
            % Action cancelled
            drawnow
            return
    end
end

%% Create "end test" pop-up
f = msgbox('Click "OK" to stop collecting data.','End Test');

%% Save data
rbDataCell = {};
while ishandle(f)
    % Get visible rigid bodies
    rb = obj.RigidBody;
    
    % Append data to cell array
    if ~isempty(rb)
        rbDataCell{end+1} = rb;
    end

    drawnow
end

%% Prompt user to define filename for saving

% Define default filename
timeStamp = datestr(now,'yyyymmdd_HHMMSS');
fname = sprintf('rbDataCell_%s',timeStamp);

% Prompt user to save
uisave({'rbDataCell','fname'},fname);