function installOptiTrackToolbox(replaceExisting)
% INSTALLOPTITRACKTOOLBOX installs OptiTrack Toolbox for MATLAB.
%   INSTALLOPTITRACKTOOLBOX installs OptiTrack Toolbox into the following 
%   locations:
%                        Source: Destination
%     OptiTrackToolboxFunctions: matlabroot\toolbox\optitrack
%       OptiTrackToolboxSupport: matlabroot\toolbox\optitrack\support 
%
%   INSTALLOPTITRACKTOOLBOX(true) installs OptiTrack Toolbox regardless of
%   whether a copy of the OptiTrack toolbox exists in the MATLAB root.
%
%   INSTALLOPTITRACKTOOLBOX(false) installs OptiTrack Toolbox only if no copy 
%   of the OptiTrack toolbox exists in the MATLAB root.
%
%   M. Kutzer 17Feb2016, USNA

% Updates

% TODO - Allow users to create a local version if admin rights are not
% possible.

%% Assign tool/toolbox specific parameters
dirName = 'optitrack';

%% Check inputs
if nargin == 0
    replaceExisting = [];
end

%% Installation error solution(s)
adminSolution = sprintf(...
    ['Possible solution:\n',...
     '\t(1) Close current instance of MATLAB\n',...
     '\t(2) Open a new instance of MATLAB "as administrator"\n',...
     '\t\t(a) Locate MATLAB shortcut\n',...
     '\t\t(b) Right click\n',...
     '\t\t(c) Select "Run as administrator"\n']);

%% Check for toolbox directory
toolboxRoot  = fullfile(matlabroot,'toolbox',dirName);
isToolbox = exist(toolboxRoot,'file');
if isToolbox == 7
    % Apply replaceExisting argument
    if isempty(replaceExisting)
        choice = questdlg(sprintf(...
            ['MATLAB Root already contains the OptiTrack Toolbox.\n',...
            'Would you like to replace the existing toolbox?']),...
            'Yes','No');
    elseif replaceExisting
        choice = 'Yes';
    else
        choice = 'No';
    end
    % Replace existing or cancel installation
    switch choice
        case 'Yes'
            % TODO - check if NatNet SDK components are running and close
            % them prior to removing directory
            [isRemoved, msg, msgID] = rmdir(toolboxRoot,'s');
            if isRemoved
                fprintf('Previous version of OptiTrack Toolbox removed successfully.\n');
            else
                fprintf('Failed to remove old OptiTrack Toolbox folder:\n\t"%s"\n',toolboxRoot);
                fprintf(adminSolution);
                error(msgID,msg);
            end
        case 'No'
            fprintf('OptiTrack Toolbox currently exists, installation cancelled.\n');
            return
        case 'Cancel'
            fprintf('Action cancelled.\n');
            return
        otherwise
            error('Unexpected response.');
    end
end

%% Create Scorbot Toolbox Path
[isDir,msg,msgID] = mkdir(toolboxRoot);
if isDir
    fprintf('OptiTrack toolbox folder created successfully:\n\t"%s"\n',toolboxRoot);
else
    fprintf('Failed to create Scorbot Toolbox folder:\n\t"%s"\n',toolboxRoot);
    fprintf(adminSolution);
    error(msgID,msg);
end

%% Migrate toolbox folder contents
toolboxContent = 'OptiTrackToolboxFunctions';
if ~isdir(toolboxContent)
    error(sprintf(...
        ['Change your working directory to the location of "installOptiTrackToolbox.m".\n',...
         '\n',...
         'If this problem persists:\n',...
         '\t(1) Unzip your original download of "OptiTrackToolbox" into a new directory\n',...
         '\t(2) Open a new instance of MATLAB "as administrator"\n',...
         '\t\t(a) Locate MATLAB shortcut\n',...
         '\t\t(b) Right click\n',...
         '\t\t(c) Select "Run as administrator"\n',...
         '\t(3) Change your "working directory" to the location of "installOptiTrackToolbox.m"\n',...
         '\t(4) Enter "installOptiTrackToolbox" (without quotes) into the command window\n',...
         '\t(5) Press Enter.']));
end
files = dir(toolboxContent);
wb = waitbar(0,'Copying OptiTrack Toolbox toolbox contents...');
n = numel(files);
fprintf('Copying OptiTrack Toolbox contents:\n');
for i = 1:n
    % source file location
    source = fullfile(toolboxContent,files(i).name);
    % destination location
    destination = toolboxRoot;
    if files(i).isdir
        switch files(i).name
            case '.'
                %Ignore
            case '..'
                %Ignore
            otherwise
                fprintf('\t%s...',files(i).name);
                nDestination = fullfile(destination,files(i).name);
                [isDir,msg,msgID] = mkdir(nDestination);
                if isDir
                    [isCopy,msg,msgID] = copyfile(source,nDestination,'f');
                    if isCopy
                        fprintf('[Complete]\n');
                    else
                        bin = msg == char(10);
                        msg(bin) = [];
                        bin = msg == char(13);
                        msg(bin) = [];
                        fprintf('[Failed: "%s"]\n',msg);
                    end
                else
                    bin = msg == char(10);
                    msg(bin) = [];
                    bin = msg == char(13);
                    msg(bin) = [];
                    fprintf('[Failed: "%s"]\n',msg);
                end
        end
    else
        fprintf('\t%s...',files(i).name);
        if fullInstall
            [isCopy,msg,msgID] = copyfile(source,destination,'f');
        else
            isCopy = 0;
            % Ignore general files for simulation-only install
            if strcmp(files(i).name(end-3:end),'.dll')
                isCopy = -1;
            end
            if strcmp(files(i).name(end-1:end),'.h')
                isCopy = -1;
            end
            if strfind(files(i).name,'ScorGet')
                isCopy = -1;
            end
            if strfind(files(i).name,'ScorSet')
                isCopy = -1;
            end
            if strfind(files(i).name,'ScorGo')
                isCopy = -1;
            end
            if strfind(files(i).name,'ScorIs')
                isCopy = -1;
            end
            % Ignore specific files for simulation-only install
            ignoreMe = {...
                'ScorCreateVector.m',...
                'ScorDispError.m',...
                'ScorHome.m',...
                'ScorInit.m',...
                'ScorParseErrorCode.m',...
                'ScorSafeShutdown.m',...
                'ScorShutdownCallback.m',...
                'ScorWaitForMove.m'};
            ignoreMat = cell2mat( strfind(ignoreMe,files(i).name) );
            if ~isempty(ignoreMat)
                isCopy = -1;
            end
            if isCopy ~= -1
                [isCopy,msg,msgID] = copyfile(source,destination,'f');
            end
        end
        if isCopy == 1
            fprintf('[Complete]\n');
        elseif isCopy == -1
            fprintf('[Ignored]\n');
        else
            bin = msg == char(10);
            msg(bin) = [];
            bin = msg == char(13);
            msg(bin) = [];
            fprintf('[Failed: "%s"]\n',msg);
        end
    end
    waitbar(i/n,wb);
end
set(wb,'Visible','off');

%% Save toolbox path
addpath(genpath(toolboxRoot),'-end');
savepath;
    
%% Migrate binary folder contents
if fullInstall
    win32binContent = 'OptiTrackToolboxSupport';
    if ~isdir(win32binContent)
        error(sprintf(...
            ['Change your working directory to the location of "installOptiTrackToolbox.m".\n',...
            '\n',...
            'If this problem persists:\n',...
            '\t(1) Unzip your original download of "OptiTrackToolbox" into a new directory\n',...
            '\t(2) Open a new instance of MATLAB "as administrator"\n',...
            '\t\t(a) Locate MATLAB shortcut\n',...
            '\t\t(b) Right click\n',...
            '\t\t(c) Select "Run as administrator"\n',...
            '\t(3) Change your "working directory" to the location of "installOptiTrackToolbox.m"\n',...
            '\t(4) Enter "installOptiTrackToolbox" (without quotes) into the command window\n',...
            '\t(5) Press Enter.']));
    end
    files = dir(win32binContent);
    waitbar(0,wb,'Copying win32bin contents...');
    set(wb,'Visible','on');
    n = numel(files);
    fprintf('Copying win32bin contents:\n');
    for i = 1:n
        % source file location
        source = fullfile(win32binContent,files(i).name);
        % destination location
        destination = win32binRoot;
        if files(i).isdir
            switch files(i).name
                case '.'
                    %Ignore
                case '..'
                    %Ignore
                otherwise
                    fprintf('\t%s...',files(i).name);
                    nDestination = fullfile(destination,files(i).name);
                    [isDir,msg,msgID] = mkdir(nDestination);
                    if isDir
                        [isCopy,msg,msgID] = copyfile(source,nDestination,'f');
                        if isCopy
                            fprintf('[Complete]\n');
                        else
                            bin = msg == char(10);
                            msg(bin) = [];
                            bin = msg == char(13);
                            msg(bin) = [];
                            fprintf('[Failed: "%s"]\n',msg);
                        end
                    else
                        bin = msg == char(10);
                        msg(bin) = [];
                        bin = msg == char(13);
                        msg(bin) = [];
                        fprintf('[Failed: "%s"]\n',msg);
                    end
            end
        else
            fprintf('\t%s...',files(i).name);
            [isCopy,msg,msgID] = copyfile(source,destination,'f');
            if isCopy
                fprintf('[Complete]\n');
            else
                bin = msg == char(10);
                msg(bin) = [];
                bin = msg == char(13);
                msg(bin) = [];
                fprintf('[Failed: "%s"]\n',msg);
            end
        end
        waitbar(i/n,wb);
    end
    close(wb);
    drawnow
end

%% Rehash toolbox cache
fprintf('Rehashing Toolbox Cache...');
rehash TOOLBOXCACHE
fprintf('[Complete]\n');