--[[
Title: UserConsoleCreate Page
Author(s):  Big
Date: 2020.9.1
Desc: 
use the lib:
------------------------------------------------------------
local UserConsoleCreate = NPL.load("(gl)Mod/WorldShare/cellar/UserConsole/Create/Create.lua")
------------------------------------------------------------
]]

local UserConsoleCreate = NPL.export()

function UserConsoleCreate:Show()
    Mod.WorldShare.Utils.ShowWindow(850, 490, "(ws)UserConsole/Create/Create.html", "Mod.WorldShare.UserConsole")
end