--[[
Title: Storage Files API
Author(s):  big
Date:  2019.12.16
Place: Foshan
use the lib:
------------------------------------------------------------
local StorageFilesApi = NPL.load("(gl)Mod/WorldShare/api/Storage/Files.lua")
------------------------------------------------------------
]]

local StorageBaseApi = NPL.load('./BaseApi.lua')

local StorageFilesApi = NPL.export()

-- url: /files/:key/token
-- method: GET
-- params: key string
-- return: object
function StorageFilesApi:Token(ext, success, error)
    if type(ext) ~= 'string' then
        return false
    end

    local uuid = System.Encoding.guid.uuid()
    local userId = Mod.WorldShare.Store:Get('user/userId')
    local key = format('%s-%s.%s', userId, uuid, ext)

    local url = format('/files/%s/token', key)

    StorageBaseApi:Get("/lessonOrganizations/userOrgInfo", nil, nil, success, error)
end