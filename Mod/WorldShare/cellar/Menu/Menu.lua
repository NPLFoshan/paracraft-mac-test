--[[
Title: Menu
Author: big  
Date: 2020.8.4
place: Foshan
Desc: 
use the lib:
------------------------------------------------------------
local Menu = NPL.load("(gl)Mod/WorldShare/cellar/Menu/Menu.lua")
------------------------------------------------------------
]]

local ShareWorld = NPL.load("(gl)Mod/WorldShare/cellar/ShareWorld/ShareWorld.lua")

local Menu = NPL.export()

function Menu:Init(menuItems)
    menuItems = menuItems or {}

    for key, item in ipairs(menuItems) do
        if item.order == 3 then
            item.order = 2
        end
    end

    local currentWorld = Mod.WorldShare.Store:Get("world/currentWorld") or {}

    menuItems[#menuItems + 1] = 
        {
            text = L"项目", order=3, name="project", children = 
            {
                {text = currentWorld.text or "", name = "project.name", Enable = false, onclick = nil},
                {text = format(L"项目ID：%d", currentWorld.kpProjectId or 0), name = "project.pid", Enable = false, onclick = nil},
                {text = format(L"派生自：%d", currentWorld.fromProjectId or 0),name = "project.ppid", Enable = false, onclick = nil},
                {Type = "Separator"},
                {text = L"上传分享", name = "project.share", onclick = nil},
                {Type = "Separator"},
                {text = L"项目首页", name = "project.index", onclick = function() self:OpenUserOpusPage() end},
                {text = L"项目作者", name = "project.author", onclick = function() self:OpenUserPage() end},
                {Type = "Separator"},
                {text = L"本地目录", name = "project.local", onclick = function() self:OpenOpusFolder() end},
                {text = L"本地备份", name = "project.backup", onclick = function() self:OpusBackup() end},
                {Type = "Separator"},
                {text = L"项目设置", name = "project.setting", onclick = function() self:OpusSetting() end},
                {text = L"成员管理", name = "project.member", onclick = function() self:MemberManager() end},
                {Type = "Separator"},
                {text = L"申请加入", name = "project.apply", onclick = function() self:Apply() end}
            }
        }

    return menuItems
end

function Menu:Share()
    echo(11111, true)
    ShareWorld:Init()
end

function Menu:OpenUserOpusPage()

end

function Menu:OpenUserPage()

end

function Menu:OpenOpusFolder()

end

function Menu:OpusBackup()

end

function Menu:OpusSetting()

end

function Menu:MemberManager()

end

function Menu:Apply()

end