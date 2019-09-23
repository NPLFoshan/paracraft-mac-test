--[[
Title: register modal
Author(s):  big
Date: 2019.9.20
City: Foshan
Desc: 
use the lib:
------------------------------------------------------------
local RegisterModal = NPL.load("(gl)Mod/WorldShare/cellar/RegisterModal/RegisterModal.lua")
RegisterModal:ShowPage()
------------------------------------------------------------
]]

local Utils = NPL.load("(gl)Mod/WorldShare/helper/Utils.lua")
local KeepworkService = NPL.load("(gl)Mod/WorldShare/service/KeepworkService.lua")
local KeepworkServiceSession = NPL.load("(gl)Mod/WorldShare/service/KeepworkService/Session.lua")

local RegisterModal = NPL.export()

function RegisterModal:ShowPage()
    local params = Utils:ShowWindow(360, 480, "Mod/WorldShare/cellar/RegisterModal/RegisterModal.html", "RegisterModal", nil, nil, nil, nil)

    params._page.OnClose = function()
        Mod.WorldShare.Store:Remove('page/RegisterModal')
    end
end

function RegisterModal:ShowBindingPage()
    
end

function RegisterModal:GetServerList()
    local serverList = KeepworkService:GetServerList()

    if self.registerServer then
        for key, item in ipairs(serverList) do
            item.selected = nil
            if item.value == self.registerServer then
                item.selected = true
            end
        end
    end

    return serverList
end

function RegisterModal:Register()
    local RegisterModalPage = Mod.WorldShare.Store:Get('page/RegisterModal')

    if not RegisterModalPage then
        return false
    end

    local loginServer = RegisterModalPage:GetValue("loginServer")
    local account = RegisterModalPage:GetValue("account")
    local password = RegisterModalPage:GetValue("password")
    local captcha = RegisterModalPage:GetValue("captcha")
    local phone = RegisterModalPage:GetValue("phone")
    local phonecaptcha = RegisterModalPage:GetValue("phonecaptcha")
    local agree = RegisterModalPage:GetValue("agree")

    if not agree then
        GameLogic.AddBBS(nil, L"您未同意用户协议", 3000, "255 0 0")
        return false
    end

    if not account or account == "" then
        GameLogic.AddBBS(nil, L"账号不能为空", 3000, "255 0 0")
        return false
    end

    if #password < 6 then
        GameLogic.AddBBS(nil, L"密码最少为6位", 3000, "255 0 0")
        return false
    end

    if not captcha or captcha == "" then
        GameLogic.AddBBS(nil, L"验证码不能为空", 3000, "255 0 0")
    end

    if #phone > 0 and #phone < 11 then
        GameLogic.AddBBS(nil, L"手机号码位数不对", 3000, "255 0 0")
    end

    if #phone > 0 and #captcha == 0 then
        GameLogic.AddBBS(nil, L"手机验证码不能为空", 3000, "255 0 0")
    end

    Mod.WorldShare.Store:Set("user/env", loginServer)

    Mod.WorldShare.MsgBox:Show(L"正在注册，可能需要10-15秒的时间，请稍后...", 20000, L"链接超时", 500)

    KeepworkServiceSession:Register(account, password, captcha, phone, phonecaptcha, function(state)
        if state and state.id then
            GameLogic.AddBBS(nil, L"注册成功，请登录", 5000, "0 255 0")
            RegisterModalPage:CloseWindow()
            Mod.WorldShare.MsgBox:Close()
            return true
        end

        GameLogic.AddBBS(nil, format("%s%s(%d)", L"注册失败，错误信息：", state.message, state.code), 5000, "255 0 0")
        Mod.WorldShare.MsgBox:Close()
    end)
end