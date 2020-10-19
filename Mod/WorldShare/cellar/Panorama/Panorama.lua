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
local CommandManager = commonlib.gettable("MyCompany.Aries.Game.CommandManager")
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager")

-- UI
local LoginModal = NPL.load("(gl)Mod/WorldShare/cellar/LoginModal/LoginModal.lua")

-- service
local KeepworkServicePanorama = NPL.load("(gl)Mod/WorldShare/service/KeepworkService/Panorama.lua")

local Panorama = NPL.export()

function Panorama:ShowCreate()
    LoginModal:CheckSignedIn(L"登录后才能分享全景图", function(bSucceed)
        if bSucceed then
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
    end)
end

function Panorama:ShowPreview()
    local params = Mod.WorldShare.Utils.ShowWindow(500, 653, "(ws)Panorama/Preview.html", "Mod.WorldShare.Panorama.Preview")

    if params._page then
        params._page:CallMethod("panorama_preview", "SetVisible", bShow ~= false) 
        params._page.OnClose = function()
            if params._page then
                params._page:CallMethod("panorama_preview", "SetVisible", false)
            end
        end
    end
end

function Panorama:ShowShare()
    local params = Mod.WorldShare.Utils.ShowWindow(520, 392, "(ws)Panorama/Share.html", "Mod.WorldShare.Panorama.Share")
end

function Panorama:StartShooting()
    _guihelper.MessageBox(L"拍摄全景图期间，请勿操作窗口，否则可能导致拍摄失败。", function(res)
        if res and res == _guihelper.DialogResult.Yes then
            local entityPlayer = EntityManager.GetFocus()
            local x, y, z = entityPlayer:GetBlockPos()
        
            -- GameLogic.GetCodeGlobal():RegisterTextEvent("after_generate_panorama", self.AfterGeneratePanorama)

            -- CommandManager:Run(format("/panorama %d,%d,%d", x, y, z))
            self:FinishShooting()
        end

    end,
    _guihelper.MessageBoxButtons.YesNo)
end

function Panorama.AfterGeneratePanorama()
    Panorama:FinishShooting()
end

function Panorama:FinishShooting()
    GameLogic.AddBBS(nil, L"生成全景图完成", 3000, "0 255 0")
    -- GameLogic.GetCodeGlobal():UnregisterTextEvent("after_generate_panorama", self.AfterGeneratePanorama)

    Mod.WorldShare.MsgBox:Show(L"正在上传全景图，请稍后...", 30000, L"分享失败", 320, 120)
    self:UploadPanoramaPhoto(function(data)
        Mod.WorldShare.MsgBox:Close()
    end)
end

function Panorama:UploadPanoramaPhoto(callback)
    KeepworkServicePanorama:Upload(function(data, err)
        echo(data, true)
    end)
end