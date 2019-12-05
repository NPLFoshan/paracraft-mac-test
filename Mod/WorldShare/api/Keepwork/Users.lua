--[[
Title: Keepwork Users API
Author(s):  big
Date:  2019.11.8
Place: Foshan
use the lib:
------------------------------------------------------------
local KeepworkUsersApi = NPL.load("(gl)Mod/WorldShare/api/Keepwork/Users.lua")
------------------------------------------------------------
]]

local KeepworkBaseApi = NPL.load('./BaseApi.lua')

local KeepworkUsersApi = NPL.export()

-- url: /users/login
-- method: POST
-- params:
--[[
    account	string 必须 用户名	
    password string 必须 密码
]]
-- return: object
function KeepworkUsersApi:Login(account, password, callback, error)
    if type(account) ~= "string" or type(password) ~= "string" then
        return false
    end

    local params = {
        username = account,
        password = password
    }

    KeepworkBaseApi:Post("/users/login", params, nil, callback, error, { 503, 400 })
end

-- url: /users/profile
-- method: POST
-- params:
--[[
    token string 必须 token
]]
-- return: object
function KeepworkUsersApi:Profile(token, callback, error)
    if type(token) ~= "string" and #token == 0 then
        return false
    end

    local headers = { Authorization = format("Bearer %s", token) }

    KeepworkBaseApi:Get("/users/profile", nil, headers, callback, error, 401)
end