--[[
Title: KeepworkService Permission
Author(s):  big
Date:  2020.05.20
Place: Foshan
use the lib:
------------------------------------------------------------
local KeepworkServicePermission = NPL.load("(gl)Mod/WorldShare/service/KeepworkService/Permission.lua")
------------------------------------------------------------
]]

local KeepworkPermissionsApi = NPL.load("(gl)Mod/WorldShare/api/Keepwork/Permissions.lua")

local KeepworkServicePermission = NPL.export()

KeepworkServicePermission.AllAuth = {
    SchoolManagementSystem = "a_school_management_system",
}

function KeepworkServicePermission:GetAuth(AuthName)
    return self.AllAuth[AuthName]
end

function KeepworkServicePermission:Authentication(AuthName, callback)
    KeepworkPermissionsApi:Check(
        self:GetAuth(AuthName),
        function(data, err)
            if data and data.data == true then
                if type(callback) == "function" then
                    callback()
                end
            end
        end,
        function(data, err) end
    )
end