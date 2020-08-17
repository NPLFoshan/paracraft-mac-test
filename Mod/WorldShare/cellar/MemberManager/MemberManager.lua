--[[
Title: Member Manager
Author: big  
Date: 2020.8.17
place: Foshan
Desc: 
use the lib:
------------------------------------------------------------
local MemberManager = NPL.load("(gl)Mod/WorldShare/cellar/MemberManager/MemberManager.lua")
------------------------------------------------------------
]]

local MemberManager = NPL.export()

function MemberManager:Show()
    Mod.WorldShare.Utils.ShowWindow(500, 320, "(ws)MemberManager", "Mod.WorldShare.MemberManager")
end

function MemberManager:ShowApply()
    Mod.WorldShare.Utils.ShowWindow(400, 260, "(ws)MemberManager/Apply.html", "Mod.WorldShare.MemberManager.Apply")
end