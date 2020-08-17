--[[
Title: Project Setting
Author: big  
Date: 2020.8.15
place: Foshan
Desc: 
use the lib:
------------------------------------------------------------
local OpusSetting = NPL.load("(gl)Mod/WorldShare/cellar/OpusSetting/OpusSetting.lua")
------------------------------------------------------------
]]

local OpusSetting = NPL.export()

function OpusSetting:Show()
    Mod.WorldShare.Utils.ShowWindow(400, 280, "(ws)OpusSetting", "Mod.WorldShare.OpusSetting")
end
