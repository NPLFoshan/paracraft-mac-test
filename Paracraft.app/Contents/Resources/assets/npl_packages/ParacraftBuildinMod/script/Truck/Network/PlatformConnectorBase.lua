--[[
    Title: PlatformConnectorBase
    Author(s): Cellfy
    Date Created: Aug 24, 2018
    Date Updated: Aug 24, 2018
    Desc: 
    Usage:
    ------------------------------------------------------------
    NPL.load("(gl)script/Truck/Network/PlatformConnectorBase.lua");
    local PlatformConnectorBase = commonlib.gettable("Mod.Truck.Network.PlatformConnectorBase");
    ------------------------------------------------------------
]]

NPL.load("(gl)script/Truck/Network/NetworkClient.lua");
local NetworkClient = commonlib.gettable("Mod.Truck.Network.NetworkClient");

local PlatformConnectorBase = commonlib.inherit(nil, commonlib.gettable("Mod.Truck.Network.PlatformConnectorBase"));

function PlatformConnectorBase:ctor()
    self.identity = "PlatformConnectorBase";
    self.inited = nil;
end

function PlatformConnectorBase:Identity()
    return self.identity;
end

function PlatformConnectorBase:Init()
    LOG.std(nil, "debug", "truckstar", "initing platform connecter base");
end

function PlatformConnectorBase:SendMessage(msg)
    LOG.std(nil, "debug", "truckstar", "platform connecter base empty message sender");
end

function PlatformConnectorBase:Destroy()
    LOG.std(nil, "debug", "truckstar", "destroying platform connecter base");
    self.inited = nil;
end
