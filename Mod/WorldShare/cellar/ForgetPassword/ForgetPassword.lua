--[[
Title: forget password
Author(s):  big
Date: 2019.9.23
City: Foshan
Desc: 
use the lib:
------------------------------------------------------------
local ForgetPassword = NPL.load("(gl)Mod/WorldShare/cellar/ForgetPassword/ForgetPassword.lua")
ForgetPassword:ShowPage()
------------------------------------------------------------
]]

local Validated = NPL.load("(gl)Mod/WorldShare/helper/Validated.lua")
local KeepworkServiceSession = NPL.load("(gl)Mod/WorldShare/Service/KeepworkService/Session.lua")

local ForgetPassword = NPL.export()

function ForgetPassword:ShowPage()
    local params = Mod.WorldShare.Utils:ShowWindow(360, 480, "Mod/WorldShare/cellar/ForgetPassword/ForgetPassword.html", "ForgetPassword", nil, nil, nil, nil)
end

function ForgetPassword:Reset()
    local ForgetPasswordPage = Mod.WorldShare.Store:Get("page/ForgetPassword")

    if not ForgetPasswordPage then
        return false
    end

    local key = ForgetPasswordPage:GetValue('key')
    local captcha = ForgetPasswordPage:GetValue('captcha')
    local password = ForgetPasswordPage:GetValue('password')

    if not Validated:Email(key) or not Validated:Phone(str) then
        GameLogic.AddBBS(nil, L"账号格式错误", 3000, "255 0 0")
        return false
    end
    
    if captcha == '' then
        GameLogic.AddBBS(nil, L"验证码不能为空", 3000, "255 0 0")
        return false
    end
    
    if not Validated:Password(str) then
        GameLogic.AddBBS(nil, L"密码格式错误", 3000, "255 0 0")
        return false
    end

    -- KeepworkServiceSession:ResetPassword()
end