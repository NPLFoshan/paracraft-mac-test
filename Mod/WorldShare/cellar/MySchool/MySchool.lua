--[[
Title: my school page
Author(s):  big
Date: 2019.09.11
Desc: 
use the lib:
------------------------------------------------------------
local MySchool = NPL.load("(gl)Mod/WorldShare/cellar/MySchool/MySchool.lua")
------------------------------------------------------------
]]

local Utils = NPL.load("(gl)Mod/WorldShare/helper/Utils.lua")
local Store = NPL.load("(gl)Mod/WorldShare/store/Store.lua")
local KeepworkService = NPL.load("(gl)Mod/WorldShare/service/KeepworkService.lua")

local MySchool = NPL.export()

function MySchool:Show()
    local params = Utils:ShowWindow(870, 650, "Mod/WorldShare/cellar/MySchool/MySchool.html", "MySchool")

    params._page:CallMethod("nplbrowser_instance", "SetVisible", true)

    params._page.OnClose = function()
        Store:Remove('page/MySchoolPage')
        params._page:CallMethod("nplbrowser_instance", "SetVisible", false)
    end
end

function MySchool:SetPage()
    Store:Set('page/MySchoolPage', document:GetPageCtrl())
end

function MySchool:Close()
    local MySchoolPage = Store:Get('page/MySchoolPage')

    if MySchoolPage then
        MySchoolPage:CloseWindow()
    end
end

function MySchool.GetUrl()
    local token = Store:Get("user/token") or ''
    local url = KeepworkService:GetKeepworkUrl() .. '/p/org/home?port=8099&token=' .. token

    return url
end