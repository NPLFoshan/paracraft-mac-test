--[[
Title: register modal
Author(s):  big
Date: 2019.9.20
City: Foshan
Desc: 
use the lib:
------------------------------------------------------------
local RegisterModal = NPL.load("(gl)Mod/WorldShare/cellar/RegisterModal/RegisterModal.lua")
RegisterModal:ShowPage()
------------------------------------------------------------
]]

local Utils = NPL.load("(gl)Mod/WorldShare/helper/Utils.lua")
local KeepworkService = NPL.load("(gl)Mod/WorldShare/service/KeepworkService.lua")

local RegisterModal = NPL.export()

function RegisterModal:ShowPage()
    echo('show register modal page', true)
    local params = Utils:ShowWindow(320, 470, "Mod/WorldShare/cellar/RegisterModal/Binding.html", "RegisterModal", nil, nil, nil, nil)

    params._page.OnClose = function()
        Mod.WorldShare.Store:Remove('page/RegisterModal')
    end
end

function RegisterModal:GetServerList()
    local serverList = KeepworkService:GetServerList()

    if self.registerServer then
        for key, item in ipairs(serverList) do
            item.selected = nil
            if item.value == self.registerServer then
                item.selected = true
            end
        end
    end

    return serverList
end