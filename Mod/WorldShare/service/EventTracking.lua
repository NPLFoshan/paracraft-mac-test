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

-- libs
local ParaWorldAnalytics = NPL.load("(gl)script/apps/Aries/Creator/Game/Login/ParaWorldAnalytics.lua")

-- api
local EventGatewayEventsApi = NPL.load("(gl)Mod/WorldShare/api/EventGateway/Events.lua")

-- service
local KeepworkServiceSession = NPL.load("(gl)Mod/WorldShare/service/KeepworkService/Session.lua")

-- database
local EventTrackingDatabase = NPL.load("(gl)Mod/WorldShare/database/EventTracking.lua")

local EventTrackingService = NPL.export()

EventTrackingService.firstInit = false
EventTrackingService.behaviorParamMap = {}
-- EventTrackingService.stayWorld = {state = 'init', beginTime = -1, timeCount = 0}
-- EventTrackingService.editWorld = {state = 'init', beginTime = -1, timeCount = 0}
EventTrackingService.timeInterval = 4000 -- 2 seconds
EventTrackingService.timeSaveLimit = 12 -- 120 seconds
EventTrackingService.userId = 0
-- EventTrackingService.defaultJsonInfo
EventTrackingService.currentLoop = nil

function EventTrackingService:Init()
    self.firstInit = false
    self.behaviorParamMap = {}
    -- self.stayWorld = {state = 'init', beginTime = -1 , timeCount = 0}
    -- self.editWorld = {state = 'init', beginTime = -1 , timeCount = 0}
    self.timeInterval = 4000 -- 2 seconds
    self.timeSaveLimit = 12 -- 120 seconds
    self.userId = 0
    -- self.defaultJsonInfo = commonlib.Json.Encode({})

    -- send last unsent data
    self:SendLastData()
    self:Loop()
end

function EventTrackingService:GenerateDataPacket(type, action)
    local currentEnterWorld = Mod.WorldShare.Store:Get('world/currentEnterWorld')
    local projectId

    if currentEnterWorld and currentEnterWorld.kpProjectId then
        projectId = kpProjectId
    end

    if type == 1 then -- one click event
        return {
            userId = Mod.WorldShare.Store:Get('user/userId'),
            projectId = projectId
        }
    elseif type == 2 then -- duration event
        local unitinfo =  {
            userId = Mod.WorldShare.Store:Get('user/userId'),
            projectId = projectId
        }

        local beExist = false
        -- get previous action from local storage

        if not beExist then
            unitinfo.beginAt = os.time()
            unitinfo.endAt = 0
            unitinfo.duration = 0
        end

        return unitinfo
    end
end

function EventTrackingService:Send(action, value, otherParams)
    if not KeepworkServiceSession:IsSignedIn() then
        return false
    end

    -- ParaWorldAnalytics:Send()

    echo(format("action: %s", action), true)
    echo(format("value: %s", value), true)
    echo(otherParams, true)

    local userId = Mod.WorldShare.Store:Get('user/userId')
    local dataPacket = self:GenerateDataPacket(2, action)

    echo('from event tracking service send!!!!!!', true)
    echo(dataPacket, true)

    if EventTrackingDatabase:PutPacket(userId, dataPacket) then
        EventGatewayEventsApi:Send(
            "behavior",
            action,
            dataPacket,
            nil,
            function(data, err)
                echo(data, true)
                echo(err, true)

                -- remove packet
                -- todo: we won't remove record if endAt == 0

                EventTrackingDatabase:RemovePacket(userId, datapacket)
            end,
            function(data, err)
                echo(data, true)
                echo(err, true)
                -- fail
                -- do nothing...
            end
        )
    end
end

function EventTrackingService:SendLastData()

end

function EventTrackingService:SaveLastData(unit, action, nowTime, otherParam)
	local keyName = string.format('paraData_%s', action)
	-- local infoStr = GameLogic.GetPlayerController():LoadLocalData(keyName , self.defaultJsonInfo)
    -- local infoMap = commonlib.Json.Decode(infoStr)

    local unitInfo = {}
	unitInfo.userId	= self.userId
	unitInfo.worldId = otherParam --假如是世界id 就是留在世界的时间
	unitInfo.beginAt = unit.beginTime
	unitInfo.endAt = nowTime
	unitInfo.duration = nowTime - unit.beginTime
	unitInfo.traceId = string.format("%s_%s_%s_%s" , unitInfo.userId , unit.beginTime , action , stateInfo)
    unit.timeCount = 0

	infoMap[unitInfo.beginAt] = unitInfo
	infoStr	= commonlib.Json.Encode(infoMap)
	GameLogic.GetPlayerController():SaveLocalData(keyName, infoStr)	
end

function EventTrackingService:Loop()
    if not self.currentLoop then
        self.currentLoop = commonlib.Timer:new(
            {
                callbackFunc = function()
                    local behaviorParamMap = self.behaviorParamMap
                    local nowTime = os.time()

                    for key, unit in pairs(behaviorParamMap) do
                        if unit.state ~= 'init' and unit.state ~= 'inActive' then
                            unit.timeCount = unit.timeCount + self.timeInterval / 1000

                            if unit.timeCount > 120 then
                                if key == 'editWorld' then
                                    self:SaveLastData(unit, key, nowTime, unit.worldId)
                                else
                                    self:SaveLastData(unit, key, nowTime, unit.state)
                                end
                            end
                        end
                    end
                end
            }
        )
    end

	self.currentLoop:Change(0, self.timeInterval)
end

