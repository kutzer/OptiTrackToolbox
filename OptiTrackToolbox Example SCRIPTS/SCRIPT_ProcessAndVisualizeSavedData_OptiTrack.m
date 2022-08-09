%% SCRIPT_ProcessAndVisualizeSavedData_OptiTrack
%   Process saved rigid body data collected using
%   "SCRIPT_SaveData_OptiTrack"
%
%   Required Variable(s) Loaded by User
%       rbDataCell - 1xM cell array containing rigid body data recovered
%                    from the OptiTrack.
%           rbDataCell{i} - 1xN structured array contaning rigid body
%                           information for the "ith" index
%
%   Output(s)
%       rbData - 1xK cell array containing 
%
%   M. Kutzer, 09Aug2022, USNA

%% Clear workspace, close all figures, clear command window
clear all
close all
clc

%% Load saved data
uiopen('rbDataCell_*.mat');

%% Define unique rigid bodies
n = numel(rbDataCell);
rbNames = {};
for i = 1:n
    % Isolate ith rigid body
    rb = rbDataCell{i};
    % Continue if no data is available
    if isempty(rb)
        continue;
    end
    % Continue if no "Name" field is available
    if ~isfield(rb,'Name')
        continue;
    end
    
    % Get rigid body names
    rbNames = [rbNames(:),{rb.Name}];
    % Keep unique names
    % TODO - check if all elements of rbNames are character arrays
    rbNames = unique(rbNames);
end

%% Define rigid body data
m = numel(rbNames);
rbFields = ...
    {'FrameIndex','TimeStamp','FrameLatency','isTracked','Position',...
    'Quaternion','Rotation','HgTransform','MarkerPosition','MarkerSize'};
rbFieldDataType = ...
    {'Numeric','Numeric','Numeric','Numeric','Numeric',...
    'Numeric','Cell','Cell','Cell','Cell'};
for i = 1:m
    % Populate rigid body name
    rbData(i).Name = rbNames{i};
    % Populate rigid body data fields
    for k = 1:numel(rbFields)
        switch rbFieldDataType{k}
            case 'Numeric'
                rbData(i).(rbFields{k}) = [];
            case 'Cell'
                rbData(i).(rbFields{k}) = {};
            otherwise
                error('Unrecognised field data type.')
        end
    end
end

%% Place data in appropriate fields
for i = 1:n
    % Isolate ith rigid body
    rb = rbDataCell{i};
    % Continue if no data is available
    if isempty(rb)
        continue;
    end
    % Continue if no "Name" field is available
    if ~isfield(rb,'Name')
        continue;
    end

    % Check each rigid body 
    for j = 1:numel(rbNames)
        ii = find( matches({rb.Name},rbNames{j}) );

        % Populate rigid body data fields
        for k = 1:numel(rbFields)
            % Check if field exists
            if isfield(rb,rbFields{k})
                if ~isempty(rb(j).(rbFields{k}))
                    goodfield = true;
                else
                    goodfield = false;
                end
            else
                goodfield = false;
            end
            
            % Check if rigid body name exists
            if isempty(ii)
                goodfield = false;
            end

            switch rbFieldDataType{k}
                case 'Numeric'
                    if goodfield
                        rbData(j).(rbFields{k})(end+1,:) = rb(ii).(rbFields{k});
                    else
                        rbData(j).(rbFields{k})(end+1,:) = nan;
                    end
                case 'Cell'
                    if goodfield
                        rbData(j).(rbFields{k}){end+1,:} = rb(ii).(rbFields{k});
                    else
                        rbData(j).(rbFields{k}){end+1,:} = [];
                    end
                otherwise
                    error('Unrecognised field data type.')
            end
        end
    end
end

