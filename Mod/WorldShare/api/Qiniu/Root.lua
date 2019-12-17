--[[
Title: Qiniu Root API
Author(s):  big
Date:  2019.12.16
Place: Foshan
use the lib:
------------------------------------------------------------
local QiniuRootApi = NPL.load("(gl)Mod/WorldShare/api/Qiniu/Root.lua")
------------------------------------------------------------
]]

local QiniuBaseApi = NPL.load('./BaseApi.lua')

local QiniuRootApi = NPL.export()

-- url: /
-- method: POST FIELDS
-- return: object
function QiniuRootApi:Upload(token, key, filename, content, success, error)
    local boundary = ParaMisc.md5('')
    local boundaryLine = "--" .. boundary .. "\n"

    QiniuBaseApi:PostFields(
        '/',
        { ['Content-Type'] = "multipart/form-data; boundary=" .. boundary },
        boundaryLine ..
        "Content-Disposition: form-data; name=\"file\"; filename=\"" .. filename .. "\"\n" ..
        "Content-Type: image/jpeg\n\n" ..
        content .. "\n" ..
        boundaryLine ..
        "Content-Disposition: form-data; name=\"x:filename\"\n\n" ..
        filename ..  "\n" ..
        boundaryLine ..
        "Content-Disposition: form-data; name=\"token\"\n\n" ..
        token ..  "\n" ..
        boundaryLine ..
        "Content-Disposition: form-data; name=\"key\"\n\n" ..
        key .. "\n" .. 
        boundaryLine,
        success,
        error
    )
end