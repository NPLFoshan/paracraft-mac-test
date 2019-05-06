--[[
    Title: GameMessageHandler
    Author(s): Cellfy
    Date Created: Aug 17, 2018
    Date Updated: Aug 17, 2018
    Desc: 
    Usage:
    ------------------------------------------------------------
    NPL.load("(gl)script/paraworld/network/GameMessageHandler.lua");
    local GameMessageHandler = commonlib.gettable("paraworld.network.GameMessageHandler");
    ------------------------------------------------------------
]]

local GameMessageHandler = commonlib.gettable("paraworld.network.GameMessageHandler");
local Lobby = commonlib.gettable("paraworld.lobby.Lobby");

GameMessageHandler.current_nid = nil;

--------------------------------------------------------------------------------
-- npl message receiver
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- npl message receiver
-- l2c stands for "lua to cpp"
-- c2l stands for "cpp to lua"
-- p2g stands for "paraworld to game"
-- g2p stands for "game to paraworld"
--------------------------------------------------------------------------------
function GameMessageHandler.handleMessage(msg)
    --LOG.std(nil, "debug", "paraworld", "game message receiver");
    --echo(msg);
    if not msg.nid then
        local client_nid = "gameclient_"..tostring(msg.tid);
        LOG.std(nil, "debug", "paraworld", "new game client connected: %s", client_nid);
        msg.nid = client_nid;
        NPL.accept(msg.tid, msg.nid);
        GameMessageHandler.UpdateNID(msg.nid);
    end

    if (msg.command == "g2p_heartbeat_response") then
        --LOG.std(nil, "debug", "paraworld", "game heartbeat response received");
        Lobby.HeartbeatCounterDecrease();
        
    elseif (msg.command == "g2p_game_started_up") then
        LOG.std(nil, "debug", "paraworld", "game started-up received");
        Lobby.ChangeStatus("StateGameRunning");
    elseif (msg.command == "g2p_quitgame_response") then
        LOG.std(nil, "debug", "paraworld", "game quitgame response received");
    elseif (msg.command == "g2p_quitgame_result") then
        LOG.std(nil, "debug", "paraworld", "game quitgame result received with result : %s", msg.result);
        if msg.result == "completed" then
            Lobby.ChangeStatus("StateLoggedIn");
        elseif msg.result == "user_canceled" then
            Lobby.ChangeStatus("StateGameRunning");
        end
    elseif (msg.command == "g2p_game_exiting") then
        LOG.std(nil, "debug", "paraworld", "game exiting received");
        Lobby.ChangeStatus("StateLoggedIn");
    elseif (msg.command == "g2p_statistics_data") then
        LOG.std(nil, "debug", "paraworld", "game g2p_statistics_data received");
        echo(msg);
        Statistics.SendKeyValueWithinDomain(msg.data.key, msg.data.value, Lobby.GetRunningGame() or "unknown_game");
    end
end

function GameMessageHandler.UpdateNID(new_nid)
    GameMessageHandler.current_nid = new_nid;
end

local function activate()
    local msg = msg;
    GameMessageHandler.handleMessage(msg)
end

NPL.this(activate)
