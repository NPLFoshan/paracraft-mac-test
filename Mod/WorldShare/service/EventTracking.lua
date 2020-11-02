--[[
Title: Event Tracking Service
Author(s): big
Date: 2020.11.2
City: Foshan
use the lib:
------------------------------------------------------------
local EventTrackingService = NPL.load("(gl)Mod/WorldShare/service/EventTracking.lua")
------------------------------------------------------------
]]

local EventGatewayEventsApi = NPL.load("(gl)Mod/WorldShare/api/EventGateway/Events.lua")

local EventTrackingService = NPL.export()

function EventTrackingService:Send(action, value, otherParams)
    echo('from event tracking service!!!!!!', true)

    echo(action, true)
    echo(value, true)
    echo(otherParams, true)
end

