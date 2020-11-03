--[[
Title: Event Tracking Database
Author(s): big
Date: 2020.11.3
place: Foshan
Desc: 
use the lib:
------------------------------------------------------------
local EventTrackingDatabase = NPL.load("(gl)Mod/WorldShare/database/EventTracking.lua")
------------------------------------------------------------
]]

local EventTrackingDatabase = NPL.export()

-- event tracking struct
--[[
{
    {
        userId = 1,
        unitinfo = {
            {
                localId = '123-ddd-111', -- uuid
                action = 'editWorld',
                userId = 1,
                projectId = 1,
                beginAt = 12345678,
                endAt = 0,
                duration = 0,
                traceId = 123, -- apiTraceId
            },
            {
                localId = '123-ddd-111', -- uuid
                action = 'editWorld'
                userId = 1,
                projectId = 1,
                beginAt = 12345678,
                endAt = 12345678,
                duration = 30000,
                traceId = 123, -- apiTraceId
            },
            {
                localId = 'uuu-999-8888', -- uuid
                action = 'createUser',
                userId = 1,
                currentAt = 1234567,
                traceId = 888
            }
        }
    },
    {
        userId = 2,
        unitinfo = {
            {
                localId = 'ppp-0000-7777', -- uuid
                action = 'createUser',
                userId = 1,
                currentAt = 1234567,
                traceId = 888
            }
        }
    }
}
]]
function EventTrackingDatabase:GetAllData()
    local playerController = GameLogic.GetPlayerController()

    return playerController:LoadLocalData("event_tracking", {}, true)
end

function EventTrackingDatabase:SaveAllData(allData)
    local playerController = GameLogic.GetPlayerController()

    return playerController:SaveLocalData("event_tracking", allData, true)
end

function EventTrackingDatabase:PutPacket(userId, packet)
    if not userId or not packet then
        return false
    end

    local allData = self:GetAllData()

    echo('from event tracking database add packet!!!!!!', true)
    echo(allData, true)
    local beUserExisted = false
    local currentUser

    for key, item in ipairs(allData) do
        if item and item.userId and tonumber(item.userId) == tonumbner(userId) then
            beUserExisted = true
            break
        end
    end

    if not beUserExisted then
        currentUser = {
            userId = tonumber(userId),
            unitinfo = {}
        }
    end

    if not packet and not packet.action then
        return false
    end

    -- check packet action exist
    local beActionExisted = false
    local currentUnitinfo

    for key, item in ipairs(currentUser.unitinfo) do
        if item and item.action and item.action == packet.action then
            beActionExisted = true
            currentUnitinfo = item
            break
        end
    end

    if not beActionExisted then
        currentUser.unitinfo[#currentUser.unitinfo + 1] = packet
    else
        -- update record
        for key, value in pairs(packet) do
            for cKey, cValue in pairs(currentUnitinfo) do
                if key == cKey then
                    currentUnitinfo[cKey] = value
                end
            end
        end
    end

    return self:SaveAllData(allData)
end

function EventTrackingDatabase:RemovePacket(userId, packet)
    if not userId or not packet or not packet.action then
        return false
    end

    local allData = self:GetAllData()
    local beRemoveSuccessed = false

    for aKey, aItem in ipairs(allData) do
        if aItem and tonumber(aItem.userId) == tonumber(userId) then
            local currentUnitinfo = commonlib.Array:new(aItem.unitinfo)

            for uKey, uItem in ipairs(currentUnitinfo) do
                if uItem and uItem.action == packet.action then
                    currentUnitinfo:remove(uKey)
                end
            end

            aItem.unitinfo = currentUnitinfo
            beRemoveSuccessed = true
            break
        end

        break
    end

    if beRemoveSuccessed then
        return self:SaveAllData(allData)
    else
        return false
    end
end