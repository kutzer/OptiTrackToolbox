function OptiTrackToolboxUpdate
% OPTITRACKTOOLBOXUPDATE download and update the OptiTrack Toolbox. 
%
%   M. Kutzer 27Feb2016, USNA

% Updates
%   07Jan2021 - Updated ToolboxUpdate

% TODO - Find a location for "OptiTrackToolbox Example SCRIPTS"
% TODO - update function for general operation

% Install OptiTrack Toolbox
ToolboxUpdate('OptiTrack');

end


function ToolboxUpdate(toolboxName)

%% Setup functions
ToolboxVer = str2func( sprintf('%sToolboxVer',toolboxName) );
installToolbox = str2func( sprintf('install%sToolbox',toolboxName) );

%% Check current version
try
    A = ToolboxVer;
catch ME
    A = [];
    fprintf('No previous version of %s detected.\n',toolboxName);
end

%% Setup temporary file directory
fprintf('Downloading the %s Toolbox...',toolboxName);
tmpFolder = sprintf('%sToolbox',toolboxName);
pname = fullfile(tempdir,tmpFolder);
if isfolder(pname)
    % Remove existing directory
    [ok,msg] = rmdir(pname,'s');
end
% Create new directory
[ok,msg] = mkdir(tempdir,tmpFolder);

%% Download and unzip toolbox (GitHub)
url = sprintf('https://github.com/kutzer/%sToolbox/archive/master.zip',toolboxName);
try
    %fnames = unzip(url,pname);
    %urlwrite(url,fullfile(pname,tmpFname));
    tmpFname = sprintf('%sToolbox-master.zip',toolboxName);
    websave(fullfile(pname,tmpFname),url);
    fnames = unzip(fullfile(pname,tmpFname),pname);
    delete(fullfile(pname,tmpFname));
    
    fprintf('SUCCESS\n');
    confirm = true;
catch ME
    fprintf('FAILED\n');
    confirm = false;
    fprintf(2,'ERROR MESSAGE:\n\t%s\n',ME.message);
end

%% Check for successful download
alternativeInstallMsg = [...
    sprintf('Manually download the %s Toolbox using the following link:\n',toolboxName),...
    newline,...
    sprintf('%s\n',url),...
    newline,...
    sprintf('Once the file is downloaded:\n'),...
    sprintf('\t(1) Unzip your download of the "%sToolbox"\n',toolboxName),...
    sprintf('\t(2) Change your "working directory" to the location of "install%sToolbox.m"\n',toolboxName),...
    sprintf('\t(3) Enter "install%sToolbox" (without quotes) into the command window\n',toolboxName),...
    sprintf('\t(4) Press Enter.')];
        
if ~confirm
    warning('InstallToolbox:FailedDownload','Failed to download updated version of %s Toolbox.',toolboxName);
    fprintf(2,'\n%s\n',alternativeInstallMsg);
	
    msgbox(alternativeInstallMsg, sprintf('Failed to download %s Toolbox',toolboxName),'warn');
    return
end

%% Find base directory
install_pos = strfind(fnames, sprintf('install%sToolbox.m',toolboxName) );
sIdx = cell2mat( install_pos );
cIdx = ~cell2mat( cellfun(@isempty,install_pos,'UniformOutput',0) );

pname_star = fnames{cIdx}(1:sIdx-1);

%% Get current directory and temporarily change path
cpath = cd;
cd(pname_star);

%% Install OptiTrack Toolbox
installToolbox(true);

%% Move back to current directory and remove temp file
cd(cpath);
[ok,msg] = rmdir(pname,'s');
if ~ok
    warning('Unable to remove temporary download folder. %s',msg);
end

%% Complete installation
fprintf('Installation complete.\n');

end