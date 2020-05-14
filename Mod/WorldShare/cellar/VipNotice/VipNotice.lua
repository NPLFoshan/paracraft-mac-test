--[[
Title: VersionNotice
Author(s):  big
Date: 2020.01.14
place: Foshan
Desc: 
use the lib:
------------------------------------------------------------
local VipNotice = NPL.load("(gl)Mod/WorldShare/cellar/VipNotice/VipNotice.lua")
------------------------------------------------------------
]]

local KeepworkService = NPL.load("(gl)Mod/WorldShare/service/KeepworkService.lua")
local LoginModal = NPL.load("(gl)Mod/WorldShare/cellar/LoginModal/LoginModal.lua")

local VipNotice = NPL.export()

function VipNotice:Init()
    if not KeepworkService:IsSignedIn() then
        LoginModal:Init(function(bSuccesed)
            if bSuccesed then
                self:CheckVip()
            end
        end)
    else
        self:CheckVip()
    end
end

function VipNotice:CheckVip()
    if Mod.WorldShare.Store:Get("user/userType") ~= "vip" then
        local parmas = Mod.WorldShare.Utils.ShowWindow(0, 0, "Mod/WorldShare/cellar/VipNotice/VipNotice.html", "VipNotice", 0, 0, "_fi", false)
    end
end