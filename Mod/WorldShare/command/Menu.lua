--[[
Title: world menu command
Author(s): big
Date: 2020/8/14
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/WorldShare/command/Menu.lua")
-------------------------------------------------------
]]

-- load lib
local CmdParser = commonlib.gettable("MyCompany.Aries.Game.CmdParser")
local Commands = commonlib.gettable("MyCompany.Aries.Game.Commands")

-- UI
local ShareWorld = NPL.load("(gl)Mod/WorldShare/cellar/ShareWorld/ShareWorld.lua")

local MenuCommand = NPL.export()

function MenuCommand:Init()
    Commands["menu"].desc = [[from world share menu commands
    /menu file.settings
    /menu file.openworlddir
    /menu file.saveworld
    /menu file.createworld
    /menu file.loadworld
    /menu file.worldrevision
    /menu file.uploadworld
    /menu file.export
    /menu file.exit
    /menu window.texturepack
    /menu window.info
    /menu window.pos
    /menu online.server
    /menu help.help
    /menu help.help.shortcutkey
    /menu help.help.tutorial.newusertutorial
    /menu help.about
    /menu help.npl_code_wiki
    /menu help.actiontutorial
]]
end

function MenuCommand:Call(cmdName, cmdText, cmdParams)
    local name, cmdText = CmdParser.ParseString(cmdText);

    if(name == "project.share") then
        ShareWorld:Init()
        return true
    end

    return false
end