--[[
Title: user store
Author(s): big
Date: 2018.8.17
City: Foshan 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/WorldShare/store/User.lua")
local UserStore = commonlib.gettable('Mod.WorldShare.store.User')
------------------------------------------------------------
]]

local UserStore = commonlib.gettable('Mod.WorldShare.store.User')

function UserStore:Action()
    return {
        SetToken = function(token)
            self.token = token
            commonlib.setfield("System.User.keepworktoken", token)
        end,
        SetUserinfo = function(token, username, nickname)
            self.token = token
            self.username = username
            self.nickname = nickname
            commonlib.setfield("System.User.keepworktoken", token)
            commonlib.setfield("System.User.username", username)
            commonlib.setfield("System.User.keepworkUsername", username)
            commonlib.setfield("System.User.NickName", nickname)

            local player = MyCompany.Aries.Game.EntityManager.GetPlayer()

            if player then
                player:ShowHeadOnDisplay(true)
                player:UpdateDisplayName(username)
            end
        end,
        SetPlayerController = function(playerController)
            self.playerController = playerController
        end,
        Logout = function()
            self.token = nil
            self.username = nil
            self.nickname = nil

            commonlib.setfield("System.User.keepworktoken", nil)
            commonlib.setfield("System.User.username", nil)
            commonlib.setfield("System.User.keepworkUsername", nil)
            commonlib.setfield("System.User.NickName", nil)

            local player = MyCompany.Aries.Game.EntityManager.GetPlayer()

            if player then
                player:UpdateDisplayName("")
                player:ShowHeadOnDisplay(false)
            end
        end
    }
end

function UserStore:Getter()
    return {
        GetPlayerController = function()
            return self.playerController
        end
    }
end