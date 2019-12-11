--[[
Title: KeepworkService Project
Author(s):  big
Date:  2019.02.18
Place: Foshan
use the lib:
------------------------------------------------------------
local KeepworkServiceProject = NPL.load("(gl)Mod/WorldShare/service/KeepworkService/Project.lua")
------------------------------------------------------------
]]
local WorldCommon = commonlib.gettable("MyCompany.Aries.Creator.WorldCommon")
local Encoding = commonlib.gettable("commonlib.Encoding")

local KeepworkService = NPL.load("../KeepworkService.lua")
local KeepworkProjectsApi = NPL.load("(gl)Mod/WorldShare/api/Keepwork/Projects.lua")
local KeepworkWorldsApi = NPL.load("(gl)Mod/WorldShare/api/Keepwork/Worlds.lua")

local KeepworkServiceProject = NPL.export()

-- This api will create a keepwork paracraft project and associated with paracraft world.
function KeepworkServiceProject:CreateProject(worldName, callback)
    if not KeepworkService:IsSignedIn() or not worldName then
        return false
    end

    KeepworkProjectsApi:CreateProject(worldName, callback)
end

-- update projectinfo
function KeepworkServiceProject:UpdateProject(pid, params, callback)
    if not KeepworkService:IsSignedIn() then
        return false
    end

    KeepworkProjectsApi:UpdateProject(pid, params, callback)
end

-- get projectinfo
function KeepworkServiceProject:GetProject(pid, callback, noTryStatus)
    KeepworkProjectsApi:GetProject(pid, callback, nil, noTryStatus)
end

function KeepworkServiceProject:GetProjectByWorldName(worldName, callback)
    if not KeepworkService:IsSignedIn() then
        return false
    end

    KeepworkWorldsApi:GetWorldByName(worldName, function(data, err)
        if not data or #data ~= 1 or type(data[1]) ~= 'table' then
            return false
        end

        local currentWorld = Mod.WorldShare.Store:Get('world/currentWorld')
        currentWorld.kpProjectId = data[1].projectId
        Mod.WorldShare.Store:Set('world/currentWorld', currentWorld)

        if type(callback) == 'function' then
            callback(data[1])
        end
    end)
end

-- get project id by worldname
function KeepworkServiceProject:GetProjectIdByWorldName(worldName, callback)
    if not KeepworkService:IsSignedIn() then
        return false
    end

    KeepworkWorldsApi:GetWorldByName(worldName, function(data, err)
        if not data or #data ~= 1 or type(data[1]) ~= 'table' or not data[1].projectId then
            if type(callback) == 'function' then
                callback()
            end

            return false
        end

        local currentWorld = Mod.WorldShare.Store:Get('world/currentWorld')
        currentWorld.kpProjectId = data[1].projectId
        Mod.WorldShare.Store:Set('world/currentWorld', currentWorld)

        if type(callback) == 'function' then
            callback(data[1].projectId)
        end
    end)
end

function KeepworkServiceProject:GetProjectId()
    local urlKpProjectId = self:GetProjectFromUrlProtocol()
    if urlKpProjectId then
        return urlKpProjectId
    end

    local openKpProjectId = Mod.WorldShare.Store:Get('world/openKpProjectId')
    if openKpProjectId then
        return openKpProjectId
    end

    WorldCommon.LoadWorldTag()
    local tagInfo = WorldCommon.GetWorldInfo()

    if tagInfo and tagInfo.kpProjectId then
        return tagInfo.kpProjectId
    end
end

function KeepworkServiceProject:GetProjectFromUrlProtocol()
    local cmdline = ParaEngine.GetAppCommandLine()
    local urlProtocol = string.match(cmdline or "", "paracraft://(.*)$")
    urlProtocol = Encoding.url_decode(urlProtocol or "")

    local kpProjectId = urlProtocol:match('kpProjectId="([%S]+)"')

    if kpProjectId then
        return kpProjectId
    end
end

function KeepworkServiceProject:Visit(pid)
    KeepworkProjectsApi:Visit(pid)
end