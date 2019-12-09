--[[
Title: KeepworkService World
Author(s):  big
Date:  2019.12.9
Place: Foshan
use the lib:
------------------------------------------------------------
local KeepworkServiceWorld = NPL.load("(gl)Mod/WorldShare/service/KeepworkService/World.lua")
------------------------------------------------------------
]]

local KeepworkServiceWorld = NPL.export()

-- get world list
function KeepworkServiceWorld:GetWorldsList(callback)
    if not self:IsSignedIn() then
        return false
    end

    local headers = self:GetHeaders()

    self:Request("/worlds", 'GET', {}, headers, callback)
end

-- get world by worldname
function KeepworkServiceWorld:GetWorld(worldName, callback)
    if (type(worldName) ~= 'string' or not self:IsSignedIn()) then
        return false
    end

    local headers = self:GetHeaders()

    self:Request(
        format("/worlds?worldName=%s", worldName or ''),
        "GET",
        nil,
        headers,
        function(data, err)
            if type(callback) ~= 'function' then
                return false
            end

            if err ~= 200 or #data == 0 then
                return false
            end

            callback(data[1])
        end
    )
end

-- updat world info
function KeepworkServiceWorld:PushWorld(params, callback)
    if type(params) ~= 'table' or not self:IsSignedIn() then
        return false
    end

    local headers = self:GetHeaders()

    self:GetWorld(
        Encoding.url_encode(params.worldName or ''),
        function(world)
            local worldId = world and world.id or false

            if not worldId then
                return false
            end

            self:Request(
                format("/worlds/%s", worldId),
                "PUT",
                params,
                headers,
                callback
            )
        end
    )
end

-- remove a world
function KeepworkServiceWorld:DeleteWorld(kpProjectId, callback)
    if not kpProjectId then
        return false
    end

    if not self:IsSignedIn() then
        return false
    end

    local url = format("/projects/%d", kpProjectId)
    local headers = self:GetHeaders()

    self:Request(url, "DELETE", {}, headers, callback)
end

-- get world by project id
function KeepworkServiceWorld:GetWorldByProjectId(pid, callback)
    if type(pid) ~= 'number' or pid == 0 then
        return false
    end

    local headers = self:GetHeaders()

    self:Request(
        format("/projects/%d/detail", pid),
        "GET",
        nil,
        headers,
        function(data, err)
            if type(callback) ~= 'function' then
                return false
            end

            if err ~= 200 or not data or not data.world then
                callback(nil, err)
                return false
            end

            callback(data.world, err)
        end
    )
end