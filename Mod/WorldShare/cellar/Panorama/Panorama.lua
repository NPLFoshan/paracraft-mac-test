--[[
Title: Panorama
Author(s):  big
Date: 2020.10.16
place: Foshan
Desc: 
use the lib:
------------------------------------------------------------
local Panorama = NPL.load("(gl)Mod/WorldShare/cellar/Panorama/Panorama.lua")
------------------------------------------------------------
]]

-- lib
local Screen = commonlib.gettable("System.Windows.Screen")

local Panorama = NPL.export()

function Panorama:ShowCreate()
    local width = Screen:GetWidth()
    local height = Screen:GetHeight()

    local scaleWidth = width * 0.9
    local scaleHeight = height * 0.9

    local params = Mod.WorldShare.Utils.ShowWindow(
        scaleWidth,
        scaleHeight,
        format("Mod/WorldShare/cellar/Panorama/Create.html?width=%d&height=%d", scaleWidth, scaleHeight),
        "Mod.WorldShare.Panorama.Create",
        nil,
        nil,
        nil,
        false
    )
end

function Panorama:ShowPreview()
    local params = Mod.WorldShare.Utils.ShowWindow(600, 420, "(ws)Panorama/Preview.html", "Mod.WorldShare.Panorama.Preview")
end

function Panorama:ShowShare()
    local params = Mod.WorldShare.Utils.ShowWindow(600, 420, "(ws)Panorama/Share.html", "Mod.WorldShare.Panorama.Share")
end

function Panorama:StartShooting()
    self:ShowPreview()
end