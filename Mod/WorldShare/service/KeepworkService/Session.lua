--[[
Title: KeepworkService Session
Author(s):  big
Date:  2019.09.22
Place: Foshan
use the lib:
------------------------------------------------------------
local KeepworkServiceSession = NPL.load("(gl)Mod/WorldShare/service/KeepworkService/Session.lua")
------------------------------------------------------------
]]

local KeepworkService = NPL.load("../KeepworkService.lua")

local KeepworkServiceSession = NPL.export()

KeepworkServiceSession.captchaKey = ''

function KeepworkServiceSession:Register(username, password, captcha, cellphone, cellphoneCaptcha, callback)
    if not username or not password or not captcha then
        return false
    end

    if type(username) ~= 'string' or
       type(password) ~= 'string' or
       type(captcha) ~= 'string' or
       type(cellphone) ~= 'string' or
       type(cellphoneCaptcha) ~= 'string' then
        return false
    end

    local params = {
        username = username,
        password = password,
        key = self.captchaKey,
        captcha = captcha
    }

    if #cellphone == 11 then
        params = {
            username = username,
            password = password,
            cellphone = cellphone,
            captcha = cellphoneCaptcha
        }
    end

    KeepworkService:Request(
        '/users/register',
        'POST',
        params,
        nil,
        function (data, err)
            if type(callback) == 'function' then
                callback(data)
            end
        end,
        { 400 }
    )
end

function KeepworkServiceSession:FetchCaptcha(callback)
    KeepworkService:Request(
        '/keepworks/svg_captcha?png=true',
        "GET",
        nil,
        nil,
        function (data, err)
            if err == 200 and type(data) == 'table' then
                self.captchaKey = data.key

                if type(callback) == 'function' then
                    callback()
                end
            end
        end
    )
end

function KeepworkServiceSession:GetCaptcha()
    if not self.captchaKey or type(self.captchaKey) ~= 'string' then
        return ''
    end

    return KeepworkService:GetCoreApi() .. '/keepworks/captcha/' .. self.captchaKey
end

function KeepworkServiceSession:GetPhoneCaptcha(phone)
    if not phone or type(phone) ~= 'string' then
        return false
    end

    KeepworkService:Request(
        '/users/cellphone_captcha?cellphone=' .. phone,
        'GET',
        nil,
        nil,
        function (data, err)
            -- echo(data, true)
        end
    )
end

function KeepworkServiceSession:BindPhone(cellphone, captcha, callback)
    if not cellphone or type(cellphone) ~= 'string' or not captcha or type(captcha) ~= 'string' then
        return false
    end

    KeepworkService:Request(
        '/users/cellphone_captcha',
        'POST',
        {
            cellphone = cellphone,
            captcha = captcha,
            isBind = true
        },
        KeepworkService:GetHeaders(),
        callback
    )
end

function KeepworkServiceSession:GetEmailCaptcha(email)
    if not email or type(email) ~= 'string' then
        return false
    end

    KeepworkService:Request(
        '/users/email_captcha?email=' .. email,
        'GET',
        nil,
        nil,
        function (data, err)
            -- echo(data, true)
            -- echo(err, true)
        end
    )
end

function KeepworkServiceSession:BindEmail(email, captcha, callback)
    if not email or type(email) ~= 'string' or not captcha or type(captcha) ~= 'string' then
        return false
    end

    KeepworkService:Request(
        '/users/email_captcha',
        'POST',
        {
            email = email,
            captcha = captcha,
            isBind = true
        },
        KeepworkService:GetHeaders(),
        callback
    )
end