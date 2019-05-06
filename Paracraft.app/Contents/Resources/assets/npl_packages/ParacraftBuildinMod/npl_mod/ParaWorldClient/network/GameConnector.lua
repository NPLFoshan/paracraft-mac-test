--[[
    Title: GameConnector
    Author(s): Cellfy
    Date Created: Aug 23, 2018
    Date Updated: Aug 23, 2018
    Desc: 
    Usage:
    ------------------------------------------------------------
    NPL.load("(gl)script/paraworld/network/GameConnector.lua");
    local GameConnector = commonlib.gettable("paraworld.network.GameConnector");
    ------------------------------------------------------------
]]

NPL.load("(gl)script/paraworld/network/NetworkClient.lua");
NPL.load("(gl)script/paraworld/network/GameMessageHandler.lua");

local NetworkClient = commonlib.gettable("paraworld.network.NetworkClient");
local GameMessageHandler = commonlib.gettable("paraworld.network.GameMessageHandler");
local GameConfig = commonlib.gettable("paraworld.games.GameConfig");

local GameConnector = commonlib.gettable("paraworld.network.GameConnector");

GameConnector.game_id = nil;
GameConnector.nid = nil;
GameConnector.inited = false;
GameConnector.message_handler = nil;

function GameConnector.Init(game_id)
    LOG.std(nil, "debug", "truckstar", "initing game connecter");

    GameConnector.game_id = game_id;
    GameConnector.nid = GameMessageHandler.current_nid;
    
    local game_config = GameConfig.Games[game_id];
    GameConnector.message_handler = game_config.message_handler;
    GameConnector.inited = true;
end

function GameConnector.AddPublicFile()
    NPL.AddPublicFile("script/paraworld/network/GameMessageHandler.lua", 501);
end

function GameConnector.SendMessage(msg)
    --LOG.std(nil, "debug", "paraworld", "game message sender");
    --echo(msg);
    --echo(GameConnector.nid);
    if GameConnector.inited and msg and msg.command then
        NPL.activate(GameConnector.nid..":"..GameConnector.message_handler, msg);
    end
end

function GameConnector.Reset()
    GameConnector.game_id = nil;
    GameConnector.nid = nil;
    GameConnector.inited = false;
    GameConnector.message_handler = nil;
    GameMessageHandler.UpdateNID(nil);
end
