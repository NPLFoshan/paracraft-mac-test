--[[
Title: ParaWorldClient
Author(s): LiXizhi
Date : 2018.12.4
Desc: 
Usage:
------------------------------------------------------------
local ParaWorldClient = NPL.load("ParaWorldClient")
ParaWorldClient:Init()
------------------------------------------------------------
]]

local ParaWorldClient = commonlib.inherit(nil, NPL.export())

function ParaWorldClient:ctor()
end

-- connect to paraworld launcher process via NPL protocol.  
function ParaWorldClient:Init()
    self:GetConnector():Init();
end

function ParaWorldClient:GetConnector()
    if(not self.connector) then
        local PlatformConnectorParaworld = NPL.load("./PlatformConnectorParaworld.lua")
        self.connector = PlatformConnectorParaworld:new();
    end
    return self.connector;
end

