--[[
Title: ParaWorldMessageHandler
Author(s): Cellfy, refactored by LiXizhi
Date Created: Aug 17, 2018
Date Updated: Dev 4, 2018
Desc: 
Usage:
------------------------------------------------------------
local ParaWorldMessageHandler = NPL.load("./ParaWorldMessageHandler.lua"");
NPL.activate("npl_mod/ParaWorldClient/ParaWorldMessageHandler.lua")
------------------------------------------------------------
]]
local ParaWorldMessageHandler = NPL.export();

local connector; 
local function GetConnector()
    if(connector == nil) then
        local ParaWorldClient = NPL.load("./ParaWorldClient.lua")
        connector = ParaWorldClient:GetConnector();
    end
    return connector;
end

-- npl message receiver
-- l2c stands for "lua to cpp"
-- c2l stands for "cpp to lua"
-- p2g stands for "paraworld to game"
-- g2p stands for "game to paraworld"
local function activate()
    local platformConnector = GetConnector()
    --LOG.std(nil, "debug", "truckstar", "paraworld message receiver");
    if (msg.command == "p2g_heartbeat") then
        --LOG.std(nil, "debug", "truckstar", "paraworld heartbeat received");
        platformConnector:SendMessage({command="g2p_heartbeat_response"});
    elseif (msg.command == "p2g_quitgame") then
        LOG.std(nil, "info", "ParaWorldClient", "paraworld asked this game to quit");
        platformConnector:SendMessage({command="g2p_quitgame_response"});
        ParaEngine.GetAttributeObject():CallField("BringWindowToTop");
        _guihelper.MessageBox(L"上层平台要求强制退出本游戏，是否退出？（任何未保存的进度可能会丢失）",
            function(res)
                if res then
                    if res == _guihelper.DialogResult.Yes then
                        platformConnector:SendMessage({command="g2p_quitgame_result", result="completed"});
                        local Desktop = commonlib.gettable("MyCompany.Aries.Creator.Game.Desktop");
                        Desktop.ForceExit();
                    elseif res == _guihelper.DialogResult.No then
                        platformConnector:SendMessage({command="g2p_quitgame_result", result="user_canceled"});
                    end
                end
            end, _guihelper.MessageBoxButtons.YesNo);
    elseif (msg.command == "p2g_bring_window_to_top") then
        ParaEngine.GetAttributeObject():CallField("BringWindowToTop");
    elseif (msg.command == "p2g_show_window") then
        local b_show = false;
        if msg.param == "show" then
            b_show = true;
        end
        -- NPL.ShowWindow(b_show);
    end
end
NPL.this(activate)
