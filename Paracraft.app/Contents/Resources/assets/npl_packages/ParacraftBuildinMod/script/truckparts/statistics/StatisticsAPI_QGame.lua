--[[
    Title: StatisticsAPI_QGame
    Author(s): Cellfy
    Date Created: Sep 20, 2016
    Date Updated: Sep 20, 2016
    Desc: API adaption for qgame statistics platform
    Usage:
    ------------------------------------------------------------
    NPL.load("(gl)script/truckparts/statistics/StatisticsAPI_QGame.lua");
    local StatisticsAPI = commonlib.gettable("truckparts.statistics.StatisticsAPI_QGame");
    ------------------------------------------------------------
]]

NPL.load("(gl)script/ide/Json.lua");
NPL.load("(gl)script/truckparts/statistics/StatisticsData.lua");

local User = commonlib.gettable("paraworld.lobby.User");
local Lobby = commonlib.gettable("paraworld.lobby.Lobby");

local StatisticsData = commonlib.gettable("truckparts.statistics.StatisticsData");
local StatisticsDataKeyValue = commonlib.gettable("truckparts.statistics.StatisticsDataKeyValue");

local StatisticsAPI_QGame = commonlib.gettable("truckparts.statistics.StatisticsAPI_QGame");

function StatisticsAPI_QGame.Init()
    StatisticsAPI_QGame.statistic_url_report = "http://tencentlog.com/stat/report.php?";
    StatisticsAPI_QGame.statistic_url_login = "http://tencentlog.com/stat/report_login.php?";
    StatisticsAPI_QGame.statistic_url_register = "http://tencentlog.com/stat/report_register.php?";
    StatisticsAPI_QGame.statistic_url_quit = "http://tencentlog.com/stat/report_quit.php?";
    LOG.std(nil, "debug", "truckparts.statistics", "statistics qgame inited: statistic data will be sent to qgame platform");
end

function StatisticsAPI_QGame.Send(statistic_data)
    echo(statistic_data);
    if statistic_data and statistic_data:isa(StatisticsDataKeyValue) then
        local cur_time = ParaGlobal.GetSysDateTime();
        local unix_time = (commonlib.timehelp.makedaynum(2008,1,1) - commonlib.timehelp.makedaynum(1970,1,1)) * commonlib.timehelp.GetDaySeconds() + cur_time;

        local dataForm = {
            domain = 10,
            appid = 1107807360,
            version = 3200,
            -- optype = 5,
            -- actionid = 1001,
            worldid = 1,
            time = unix_time,
            userip = 0,
            svrip = 0,
        };
        -- dataForm.gameid = StatisticsAPI_QGame.gameid;
        -- dataForm.uid = uid;
        -- dataForm.stid = stid;
        -- dataForm.sstid = sstid;
        dataForm.opuid = User.user_id;
        dataForm.opopenid = User.user_id;

        local url_request;
        if statistic_data.Key == "InServersStead.Login" then
            url_request = StatisticsAPI_QGame.statistic_url_login;
        elseif statistic_data.Key == "InServersStead.Register" then
            url_request = StatisticsAPI_QGame.statistic_url_register;
        elseif statistic_data.Key == "InServersStead.Quit" then
            url_request = StatisticsAPI_QGame.statistic_url_quit;
            dataForm.onlinetime = statistic_data.Value;
        else
            url_request = StatisticsAPI_QGame.statistic_url_report;
            dataForm.optype = 5;
            dataForm.actionid = 1001;
            dataForm.reserve_5 = statistic_data.Domain.."__"..statistic_data.Key.."__"..statistic_data.Value;
        end

        for k,v in pairs(dataForm) do
            url_request = url_request..k.."="..v.."&";
        end
        LOG.std(nil, "debug", "paraworld", "statistics url generated as below ...");
        echo(url_request);
        NPL.AppendURLRequest(
            url_request,
            "truckparts.statistics.StatisticsAPI_QGame.QGameStatisticsCallback()",
            nil,
            "r");
    else
        LOG.std(nil, "debug", "truckparts.statistics", "StatisticsAPI:QGame: QGame api can only handle key-value pairs data");
    end
end

function StatisticsAPI_QGame.QGameStatisticsCallback()
    if msg.rcode~=200 then
        LOG.std(nil, "debug", "truckparts.statistics", "statistics data sent to qgame failed");
    else
        local msg_data = commonlib.Json.Decode(msg.data);
        echo(msg_data);
        if msg_data.ret ~= 0 then
            LOG.std(nil, "debug", "truckparts.statistics", "statistics data sent to qgame returned with error: %s", msg_data.msg);
        else
            LOG.std(nil, "debug", "truckparts.statistics", "statistics data sent to qgame succeeded: %s", msg_data.msg);
        end
    end
end
