--[[
Title: GetVipMemberByCode
Author(s):  big
Date: 2020.09.24
place: Foshan
Desc: 
use the lib:
------------------------------------------------------------
local VipNotice = NPL.load("(gl)Mod/WorldShare/cellar/Vip/GetVipMemberByCode/GetVipMemberByCode.lua")
------------------------------------------------------------
]]

local GetVipMemberByCode = NPL.export()

function GetVipMemberByCode:Show()
    local params = Mod.WorldShare.Utils.ShowWindow(400, 200, "(ws)Vip/GetVipMemberByCode/GetVipMemberByCode.html", "Mod.WorldShare.Vip.GetVipMemberByCode", nil, nil, nil, true, 102)
end

function GetVipMemberByCode:Activation()
    
end