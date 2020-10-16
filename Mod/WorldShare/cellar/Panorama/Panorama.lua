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

local Panorama = NPL.export()

function Panorama:ShowCreate()
    local params = Mod.WorldShare.Utils.ShowWindow(600, 420, "(ws)Panorama/Create.html", "Mod.WorldShare.Panorama.Create")
end

function Panorama:ShowPreview()
    local params = Mod.WorldShare.Utils.ShowWindow(600, 420, "(ws)Panorama/Preview.html", "Mod.WorldShare.Panorama.Preview")
end

function Panorama:ShowShare()
    local params = Mod.WorldShare.Utils.ShowWindow(600, 420, "(ws)Panorama/Share.html", "Mod.WorldShare.Panorama.Share")
end