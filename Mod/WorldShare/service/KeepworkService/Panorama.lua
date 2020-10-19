--[[
Title: KeepworkService Panorama
Author(s):  big
Date:  2020.10.19
Place: Foshan
use the lib:
------------------------------------------------------------
local KeepworkServicePanorama = NPL.load("(gl)Mod/WorldShare/service/KeepworkService/Panorama.lua")
------------------------------------------------------------
]]

local KeepworkServicePanorama = NPL.export()

-- api
local StoragePanoramasApi = NPL.load("(gl)Mod/WorldShare/api/Storage/Panoramas.lua")
local QiniuRootApi = NPL.load("(gl)Mod/WorldShare/api/Qiniu/Root.lua")

KeepworkServicePanorama.updateIndex = 0

function KeepworkServicePanorama:Upload(callback)
    local currentEnterWorld = Mod.WorldShare.Store:Get('world/currentEnterWorld')

    if not currentEnterWorld or not currentEnterWorld.kpProjectId then
        return false
    end

    local projectId = currentEnterWorld.kpProjectId

    StoragePanoramasApi:UploadToken(projectId, "0.jpg", callback, callback)
end