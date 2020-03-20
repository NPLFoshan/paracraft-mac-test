﻿--[[
Title: WorldShareMod
Author(s):  Big
Date: 2017.4.17
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/WorldShare/main.lua")
local WorldShare = commonlib.gettable("Mod.WorldShare")
------------------------------------------------------------

CODE GUIDELINE

1. all classes and functions use upper camel case
2. all variables use lower camel case
3. all files use use upper camel case
4. all templates variables and functions use underscore case

]]
NPL.load("(gl)script/ide/Files.lua")
NPL.load("(gl)script/ide/Encoding.lua")
NPL.load("(gl)script/ide/System/Encoding/sha1.lua")
NPL.load("(gl)script/ide/System/Encoding/base64.lua")
NPL.load("(gl)script/ide/System/Windows/Screen.lua")
NPL.load("(gl)script/apps/Aries/Creator/WorldCommon.lua")
NPL.load("(gl)script/apps/Aries/Creator/Game/Login/InternetLoadWorld.lua")
NPL.load("(gl)script/apps/Aries/Creator/Game/Login/CreateNewWorld.lua")
NPL.load("(gl)script/apps/Aries/Creator/Game/Login/LocalLoadWorld.lua")
NPL.load("(gl)script/apps/Aries/Creator/Game/Login/RemoteServerList.lua")
NPL.load("(gl)script/apps/Aries/Creator/Game/Areas/ShareWorldPage.lua")
NPL.load("(gl)script/apps/Aries/Creator/Game/Login/DownloadWorld.lua")
NPL.load("(gl)script/apps/Aries/Creator/Game/Login/RemoteWorld.lua")
NPL.load("(gl)script/ide/System/Core/UniString.lua")
NPL.load("(gl)script/ide/System/Core/Event.lua")
NPL.load("(gl)script/apps/Aries/Creator/Game/Login/TeacherAgent/TeacherAgent.lua")
NPL.load("(gl)script/ide/System/os/os.lua")
NPL.load("(gl)script/apps/Aries/Creator/Game/Network/NPLWebServer.lua")
NPL.load("(gl)script/apps/Aries/Creator/Game/World/SaveWorldHandler.lua")
NPL.load("(gl)Mod/WorldShare/service/SocketService.lua")
NPL.load("(gl)script/apps/Aries/Creator/Game/Network/NetworkMain.lua")
NPL.load("(gl)script/ide/System/Encoding/guid.lua")
NPL.load("(gl)script/apps/Aries/Creator/Game/Login/ParaWorldLessons.lua")
NPL.load("(gl)script/ide/System/Encoding/jwt.lua")

local Store = NPL.load("(gl)Mod/WorldShare/store/Store.lua")
local MsgBox = NPL.load("(gl)Mod/WorldShare/cellar/Common/MsgBox/MsgBox.lua")
local Utils = NPL.load("(gl)Mod/WorldShare/helper/Utils.lua")
local MainLogin = NPL.load("(gl)Mod/WorldShare/cellar/MainLogin/MainLogin.lua")
local UserConsole = NPL.load("(gl)Mod/WorldShare/cellar/UserConsole/Main.lua")
local CreateWorld = NPL.load("(gl)Mod/WorldShare/cellar/CreateWorld/CreateWorld.lua")
local SyncMain = NPL.load("(gl)Mod/WorldShare/cellar/Sync/Main.lua")
local ShareWorld = NPL.load("(gl)Mod/WorldShare/cellar/ShareWorld/ShareWorld.lua")
local HistoryManager = NPL.load("(gl)Mod/WorldShare/cellar/HistoryManager/HistoryManager.lua")
local WorldExitDialog = NPL.load("(gl)Mod/WorldShare/cellar/WorldExitDialog/WorldExitDialog.lua")
local LocalService = NPL.load("(gl)Mod/WorldShare/service/LocalService.lua")
local Grade = NPL.load("(gl)Mod/WorldShare/cellar/Grade/Grade.lua")
local KeepworkServiceWorld = NPL.load("(gl)Mod/WorldShare/service/KeepworkService/World.lua")
local KeepworkServiceSession = NPL.load("(gl)Mod/WorldShare/service/KeepworkService/Session.lua")
local SaveWorld = NPL.load("(gl)Mod/WorldShare/cellar/SaveWorld/SaveWorld.lua")

local SocketService = commonlib.gettable("Mod.WorldShare.service.SocketService")
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
local WorldCommon = commonlib.gettable("MyCompany.Aries.Creator.WorldCommon")

local WorldShare = commonlib.inherit(commonlib.gettable("Mod.ModBase"), commonlib.gettable("Mod.WorldShare"))

WorldShare:Property({"Name", "WorldShare", "GetName", "SetName", { auto = true }})
WorldShare:Property({"Desc", "world share mod can share world to keepwork online", "GetDesc", "SetDesc", { auto = true }})
WorldShare.version = '0.0.14'

-- register mod global variable
WorldShare.Store = Store
WorldShare.MsgBox = MsgBox
WorldShare.Utils = Utils

LOG.std(nil, "info", "WorldShare", "world share version %s", WorldShare.version)

function WorldShare:init()
    -- replace load world page
    GameLogic.GetFilters():add_filter(
        "ShowLoginModePage",
        function()
            MainLogin:Show()
            return false
        end
    )

    -- replace load world page
    GameLogic.GetFilters():add_filter(
        "InternetLoadWorld.ShowPage",
        function(bEnable, bShow)
            UserConsole:ShowPage()
            return false
        end
    )

    -- replace the exit world dialog
    GameLogic.GetFilters():add_filter(
        "ShowExitDialog",
        function(dialog)
            if (dialog and dialog.callback) then
                WorldExitDialog.ShowPage(dialog.callback)
                return nil
            end
        end
    )

    -- replace share world page
    GameLogic.GetFilters():add_filter(
        "SaveWorldPage.ShowSharePage",
        function(bEnable)
            ShareWorld:Init()
            return false
        end
    )

    -- replace implement or replace create new world event
    GameLogic.GetFilters():add_filter(
        "OnClickCreateWorld",
        function()
            return CreateWorld.OnClickCreateWorld()
        end
    )

    -- replcae implement local world event
    GameLogic.GetFilters():add_filter(
        "load_world_info",
        function(ctx, node)
            LocalService:LoadWorldInfo(ctx, node)
        end
    )

    -- replace implement save world event
    GameLogic.GetFilters():add_filter(
        "save_world_info",
        function(ctx, node)
            LocalService:SaveWorldInfo(ctx, node)
        end
    )

    -- handle enter world width pid
    GameLogic.GetFilters():add_filter(
        "cmd_loadworld", 
        function(url, options)
            local pid = UserConsole:GetProjectId(url)
            if pid then
                UserConsole:HandleWorldId(pid)
                return
            else
                return url
            end
        end
    )

    -- return current user worlds folder or temp folder
    GameLogic.GetFilters():add_filter(
        "LocalLoadWorld.GetWorldFolderFullPath",
        function()
            return LocalService:FilterGetWorldsFolderFullPath()
        end
    )

    -- save world
    GameLogic.GetFilters():add_filter(
        "SaveWorldPage.OnSaveWorld",
        function(callback)
            return SaveWorld:Save(callback)
        end
    )

    -- save world as
    GameLogic.GetFilters():add_filter(
        "WorldCommon.SaveWorldAs",
        function(callback)
            return SaveWorld:SaveAs(callback)
        end
    )

    -- send udp online msg
    SocketService:StartUDPService()

    -- refresh token
    KeepworkServiceSession:RenewToken()
end

function WorldShare:OnInitDesktop()
end

function WorldShare:OnLogin()
end

function WorldShare:OnWorldLoad()
    Store:Set('world/isEnterWorld', true)

    UserConsole:ClosePage()
    HistoryManager:OnWorldLoad()

    local curLesson = Store:Getter("lesson/GetCurLesson")

    -- if enter with lesson method, we will not check revision
    if not curLesson then
        SyncMain:OnWorldLoad()
    end   
end

function WorldShare:OnLeaveWorld()
    KeepworkServiceWorld:UnlockWorld()
    Store:Remove("world/currentWorld")
end