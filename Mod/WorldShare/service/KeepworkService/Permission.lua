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
    OnlineTeaching = "t_online_teaching",
    OnlineLearning = "s_online_learning",
}

function KeepworkServicePermission:GetAuth(authName)
    return self.AllAuth[authName]
end

function KeepworkServicePermission:Authentication(authName, callback)
    KeepworkPermissionsApi:Check(
        self:GetAuth(authName),
        function(data, err)
            if data and data.data == true then
                if type(callback) == "function" then
                    callback(true)
                end
            else
                if type(callback) == "function" then
                    callback(false)
                end
            end
        end,
        function(data, err)
            callback(false)
        end
    )
end