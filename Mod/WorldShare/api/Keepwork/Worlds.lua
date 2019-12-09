--[[
Title: Keepwork Worlds API
Author(s):  big
Date:  2019.11.8
Place: Foshan
use the lib:
------------------------------------------------------------
local KeepworkWorldsApi = NPL.load("(gl)Mod/WorldShare/api/Keepwork/Worlds.lua")
------------------------------------------------------------
]]

local Encoding = commonlib.gettable("commonlib.Encoding")

local KeepworkBaseApi = NPL.load('./BaseApi.lua')

local KeepworkWorldsApi = NPL.export()

-- url: /worlds?worldName=%s
-- method: GET
-- params:
--[[
]]
-- return: object
function KeepworkWorldsApi:GetWorldByName(worldName, success, error)
    local url = format("/worlds?worldName=%s", Encoding.url_encode(worldName or ''))

    KeepworkBaseApi:Get(url, nil, nil, success, error)
end