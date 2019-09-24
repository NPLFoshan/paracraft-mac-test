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

local ForgetPassword = NPL.export()

function ForgetPassword:ShowPage()
    local params = Mod.WorldShare.Utils:ShowWindow(360, 480, "Mod/WorldShare/cellar/ForgetPassword/ForgetPassword.html", "ForgetPassword", nil, nil, nil, nil)
end

-- function ForgetPassword: