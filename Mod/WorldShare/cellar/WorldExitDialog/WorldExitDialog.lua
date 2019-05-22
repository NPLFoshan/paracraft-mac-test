--[[
Title: World Exit Dialog
Author(s):  Big, LiXizhi
Date: 2017/5/15
Desc: 
use the lib:
------------------------------------------------------------
local WorldExitDialog = NPL.load("(gl)Mod/WorldShare/cellar/WorldExitDialog/WorldExitDialog.lua")
WorldExitDialog.ShowPage();
------------------------------------------------------------
]]
local ShareWorldPage = commonlib.gettable("MyCompany.Aries.Creator.Game.Desktop.Areas.ShareWorldPage")

local Utils = NPL.load("(gl)Mod/WorldShare/helper/Utils.lua")
local Store = NPL.load("(gl)Mod/WorldShare/store/Store.lua")
local Compare = NPL.load("(gl)Mod/WorldShare/service/SyncService/Compare.lua")
local KeepworkService = NPL.load("(gl)Mod/WorldShare/service/KeepworkService.lua")
local LoginModal = NPL.load("(gl)Mod/WorldShare/cellar/LoginModal/LoginModal.lua")
local Grade = NPL.load("./Grade.lua")

local WorldExitDialog = NPL.export()
local self = WorldExitDialog

-- @param callback: function(res) end.
function WorldExitDialog.ShowPage(callback)
    -- TODO: if world is read only we should not compare revision

    Compare:Init(function()
        local function Handle()
            local params = Utils:ShowWindow(610, 400, "Mod/WorldShare/cellar/WorldExitDialog/WorldExitDialog.html", "WorldExitDialog")

            params._page.OnClose = function()
                Store:Remove('page/WorldExitDialog')
            end

            local WorldExitDialogPage = Store:Get('page/WorldExitDialog')
            if(WorldExitDialogPage) then
                if(not GameLogic.IsReadOnly() and not ParaIO.DoesFileExist(self.GetPreviewImagePath(), false)) then
                    WorldExitDialog.Snapshot()
                end
                WorldExitDialogPage.callback = callback
            end
        end

        local enterWorld = Store:Get('world/enterWorld')

        if enterWorld and enterWorld.kpProjectId then
            KeepworkService:GetProject(tonumber(enterWorld.kpProjectId), function(data)
                if data and data.world and data.world.worldName then
                    self.currentWorldKeepworkInfo = data
                end

                Grade:GetScoreFromKeepwork()

                Handle()
            end)

            return true
        end
        
        Handle()
    end)
end

function WorldExitDialog:IsUserWorld()
    local enterWorld = Store:Get('world/enterWorld')
    local userId = Store:Get('user/userId')

    if enterWorld and enterWorld.kpProjectId and userId then
        if self.currentWorldKeepworkInfo and self.currentWorldKeepworkInfo.userId and self.currentWorldKeepworkInfo.userId == userId then
            return true
        else
            return false
        end
    else
        return false
    end
end

function WorldExitDialog.GetPreviewImagePath()
    return ParaWorld.GetWorldDirectory() .. "preview.jpg"
end

function WorldExitDialog:OnInit()
    Store:Set('page/WorldExitDialog', document:GetPageCtrl())

    document:GetPageCtrl():SetNodeValue("ShareWorldImage", self.GetPreviewImagePath())
end

function WorldExitDialog:Refresh(sec)
    local worldExitDialogPage = Store:Get('page/WorldExitDialog')

    if worldExitDialogPage then
        worldExitDialogPage:Refresh(sec or 0.01)
    end
end

-- @param res: _guihelper.DialogResult
function WorldExitDialog.OnDialogResult(res)
    local WorldExitDialogPage = Store:Get('page/WorldExitDialog')

    if (WorldExitDialogPage) then
        WorldExitDialogPage:CloseWindow()
    end

    if (WorldExitDialogPage.callback) then
        WorldExitDialogPage.callback(res)
    end
end

function WorldExitDialog.Snapshot()
    ShareWorldPage.TakeSharePageImage()
    WorldExitDialog.UpdateImage(true)
end

function WorldExitDialog.UpdateImage(bRefreshAsset)
    local WorldExitDialogPage = Store:Get('page/WorldExitDialog')

    if (WorldExitDialogPage) then
        local filepath = ShareWorldPage.GetPreviewImagePath()
        WorldExitDialogPage:SetUIValue("ShareWorldImage", filepath)

        if (bRefreshAsset) then
            ParaAsset.LoadTexture("", filepath, 1):UnloadAsset()
        end
    end
end

function WorldExitDialog:CanSetStart()
    if not KeepworkService:IsSignedIn() then
        LoginModal:Init(function()
            local enterWorld = Store:Get('world/enterWorld')

            if enterWorld and enterWorld.kpProjectId then
                KeepworkService:GetProject(tonumber(enterWorld.kpProjectId), function(data)
                    if data and data.world and data.world.worldName then
                        self.currentWorldKeepworkInfo = data
                    end

                    self:Refresh()
                end)
            end
        end)

        return false
    end

    return true
end
