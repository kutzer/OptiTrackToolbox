function [localIP,broadcastIP,infoIP] = getIPv4(varargin)
% GETIPV4 uses Java functionality to find the local IP and broadcast IP for
% wired connections.
%   [localIP,broadcastIP,infoIP] = getIPv4;
%   ___ = getIPv4(promptName)
%
%   Input(s)
%       promptName - [OPTIONAL] character array specifying the prompt to
%                    use as the name of the listdlg. Default if unspecified
%                    is 'Multiple NIC Found'
%
%   Output(s)
%           localIP - character array specifying local IP address selected
%                     by user
%       broadcastIP - character array specifying broadcast IP address
%            infoIP - structured array specifying IP information
%               *.localIP
%               *.broadcastIP
%               *.CIDR
%               *.subnetMask
%               *.networkIP
%
%   M. Kutzer, 25Apr2016, USNA

% Updates
%   08Nov2016 - Updated to account for multiple network connections
%   07Jan2021 - Updated to allow the user to specify the prompt name
%   17Oct2024 - Updated to parse CIDR, subnet mask, and network address

%% Parse inputs
narginchk(0,1);
promptName = 'Multiple NIC Found';
if nargin > 0
    promptName = varargin{1};
end

%% Get local host, networkInterface, and interface addresses using java
% Get the local network host
localhost = java.net.Inet4Address.getLocalHost();
% Get all IPv4 addresses by name
allIPs = java.net.Inet4Address.getAllByName(localhost.getCanonicalHostName());

n = numel(allIPs);
adapterName      = cell(n,1); % Network adapter name
interfaceAddress = cell(n,1); % Network interface address
localIP          = cell(n,1); % Local IP address
broadcastIP      = cell(n,1); % Broadcast IP address
nicInfo          = cell(n,1); % Combine NIC info (to eliminate redundancy)
for i = 1:n
    % Get network interface
    networkInterface(i) = java.net.NetworkInterface.getByInetAddress(allIPs(i));

    if ~isempty(networkInterface(i))
        % Get adapter display name
        adapterName{i} = char( networkInterface(i).getDisplayName() );
        % Define interface address
        interfaceAddress{i} = char( networkInterface(i).getInterfaceAddresses() );
        % Parse interface address
        out = sscanf(interfaceAddress{i},'[/%d.%d.%d.%d/%d [/%d.%d.%d.%d]',[1,9]);
        % Define Local IP
        localIP_bits = int2bit(out(1:4),8);
        localIP{i} = sprintf('%d.%d.%d.%d',out(1:4));
        % Define CIDR (Classless Inter-Domain Routing)
        CIDR{i} = out(5);
        % Define subnet mask
        subnetMask_bits = repmat(int2bit(255,8),1,4);
        if CIDR{i} < numel(subnetMask_bits)
            subnetMask_bits( (CIDR{i}+1):end ) = 0;
        end
        subnetMask{i} = sprintf('%d.%d.%d.%d',bit2int(subnetMask_bits,8));
        % Define Broadcast IP
        broadcastIP{i} = sprintf('%d.%d.%d.%d',out(6:9));
        % Define Network Address
        networkIP_bits = localIP_bits & subnetMask_bits;
        networkIP{i} = sprintf('%d.%d.%d.%d',bit2int(networkIP_bits,8));
        % Combine NIC info to find unique options
        nicInfo{i} = sprintf('%s,%s,%s',adapterName{i},localIP{i},broadcastIP{i});
    end
end

% Remove redundant adapters
[~,idx] = unique(nicInfo,'Stable');
adapterName = adapterName(idx);
localIP = localIP(idx);
CIDR = CIDR(idx);
subnetMask = subnetMask(idx);
broadcastIP = broadcastIP(idx);
networkIP = networkIP(idx);

%% Define adapter list for listdlg
n = numel(adapterName);
listStr = cell(n,1);
for i = 1:n
    % Append list for list dialog
    listStr{i} = sprintf('(%2.0d) %s --- Network IP: [%s] --- Broadcast IP: [%s]',...
        i,...
        adapterName{i},...
        localIP{i},...
        broadcastIP{i});
end

%% Prompt user
[s,ok] = listdlg('Name',promptName,...
    'PromptString','Select network adapter:',...
    'SelectionMode','single',...
    'ListString',listStr,...
    'ListSize',[900 300]);

% Parse output
if ok
    localIP = localIP{s};
    broadcastIP = broadcastIP{s};
    infoIP.localIP = localIP;
    infoIP.broadcastIP = broadcastIP;
    infoIP.CIDR = CIDR{s};
    infoIP.subnetMask = subnetMask{s};
    infoIP.networkIP = networkIP{s};
else
    localIP = [];
    broadcastIP = [];
    infoIP.localIP = [];
    infoIP.broadcastIP = [];
    infoIP.CIDR = [];
    infoIP.subnetMask = [];
    infoIP.networkIP = [];
end