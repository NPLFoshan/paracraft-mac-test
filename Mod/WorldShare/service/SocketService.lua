--[[
Title: SocketService
Author(s):  big
Date:  2019.10.30
Desc: 
use the lib:
------------------------------------------------------------
local SocketService = NPL.load("(gl)Mod/WorldShare/service/SocketService.lua")
------------------------------------------------------------
]]

local SocketService = MPL.export()

SocketService.isStartedUDPService = false

-- start socket service
function SocketService:StartUDPService()
	if self:IsUDPStarted() then
		return false
	end

	local att = NPL.GetAttributeObject();
	local ipList = att:GetField("ExternalIPList");
	ipList = commonlib.split(ipList, ",");
	self._ExternalIPList = ipList;

	ParaScene.RegisterEvent("_n_paracraft_lobby", ";_OnLobbyServerNetworkEvent();");
	
	self:SetUDPStarted(true);
	self:started();
end

function SocketService:IsUDPStarted()

end

function SocketService:SetUDPStarted(val)
    self.isStartedUDPService = val
end

-- send udp msg
function SocketService:SendUDPMsg()

end

-- receive udp msg
function SocketService:ReceiveUDPMsg()

end