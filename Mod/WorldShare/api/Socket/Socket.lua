--[[
Title: Socket API
Author(s):  big
Date:  2020.05.26
Place: Foshan
use the lib:
------------------------------------------------------------
local SocketApi = NPL.load("(gl)Mod/WorldShare/api/Socket/Socket.lua")
------------------------------------------------------------
]]

local SocketBaseApi = NPL.load("(gl)Mod/WorldShare/api/Socket/BaseApi.lua")

local SocketIOClient = NPL.load("(gl)script/ide/System/os/network/SocketIO/SocketIOClient.lua");

local SocketApi = NPL.export()

function SocketApi:Connect()
    local client = SocketIOClient:new();
    client:Connect(SocketBaseApi:GetApi())

    return client
end
