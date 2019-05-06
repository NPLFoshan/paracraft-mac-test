--[[
    Title: Statistics
    Author(s): Cellfy
    Date Created: Sep 20, 2016
    Date Updated: Sep 20, 2016
    Desc: Statistics module on client side
    Usage: 
    ------------------------------------------------------------
    NPL.load("(gl)script/truckparts/statistics/Statistics.lua");
    local Statistics = commonlib.gettable("truckparts.statistics.Statistics");
    ------------------------------------------------------------
]]

NPL.load("(gl)script/ide/STL.lua");
NPL.load("(gl)script/truckparts/statistics/StatisticsData.lua");

local StatisticsData = commonlib.gettable("truckparts.statistics.StatisticsData");
local StatisticsDataKeyValue = commonlib.gettable("truckparts.statistics.StatisticsDataKeyValue");
local StatisticsDataKeyValueWithinDomain = commonlib.gettable("truckparts.statistics.StatisticsDataKeyValueWithinDomain");
local StatisticsAPI = nil;

local Statistics = commonlib.gettable("truckparts.statistics.Statistics");

local instant_forward;
local data_queue;
local schedule_timer;

local StatisticsSend;
local StatisticsSchedule;
Statistics.Inited = false;

--@param platform: one of "Taomee", "Log", ... (more are coming... )
function Statistics.Init(platform, bQueued)
    if platform=="Taomee" then
        NPL.load("(gl)script/truckparts/statistics/StatisticsAPI_Taomee.lua");
        StatisticsAPI = commonlib.gettable("truckparts.statistics.StatisticsAPI_Taomee");
    elseif platform=="Log" then
        NPL.load("(gl)script/truckparts/statistics/StatisticsAPI_Log.lua");
        StatisticsAPI = commonlib.gettable("truckparts.statistics.StatisticsAPI_Log");
    elseif platform=="Paraworld" then
        NPL.load("(gl)script/truckparts/statistics/StatisticsAPI_Paraworld.lua");
        StatisticsAPI = commonlib.gettable("truckparts.statistics.StatisticsAPI_Paraworld");
    elseif platform=="QGame" then
        NPL.load("(gl)script/truckparts/statistics/StatisticsAPI_QGame.lua");
        StatisticsAPI = commonlib.gettable("truckparts.statistics.StatisticsAPI_QGame");
    else
        LOG.std(nil, "error", "truckparts.statistics", "trying to initialize invalid statistics api");
    end
    if StatisticsAPI and StatisticsAPI.Init then
        StatisticsAPI.Init();

        Statistics.InstantForwardMode(not bQueued);

        Statistics.TempStatus = {}; --for users to add temporary statistics related status
        Statistics.Inited = true;
    end
end

function Statistics.Finish()
    Statistics.Flush();
    LOG.std(nil, "debug", "truckparts.statistics", "statistics finished");
end

function Statistics.InstantForwardMode(bOn)
    if bOn then
        --send all data left first
        StatisticsSchedule(nil, true);
        if schedule_timer then
            schedule_timer:Change();
            schedule_timer = nil;
        end
        data_queue = nil;
        instant_forward = true;
        LOG.std(nil, "debug", "truckparts.statistics", "statistics: instant forward mode on");
    else
        data_queue = commonlib.Queue:new();
        schedule_timer = commonlib.Timer:new({callbackFunc = StatisticsSchedule});
        schedule_timer:Change(1000, 500);
        instant_forward = false;
        LOG.std(nil, "debug", "truckparts.statistics", "statistics: instant forward mode off");
    end
end

function Statistics.SendKeyValue(str_key, str_value)
    local new_data = StatisticsDataKeyValue:new();
    new_data:SetData(tostring(str_key), tostring(str_value));
    Statistics.Send(new_data);
end

function Statistics.SendKey(str_key)
    Statistics.SendKeyValue(str_key, "");
end

function Statistics.SendKeyValueWithinDomain(str_key, str_value, str_domain)
    local new_data = StatisticsDataKeyValueWithinDomain:new();
    new_data:SetData(tostring(str_key), tostring(str_value), tostring(str_domain));
    Statistics.Send(new_data);
end

function Statistics.Send(statistic_data)
    if statistic_data and statistic_data:isa(StatisticsData) then
        if Statistics.Inited then
            if instant_forward then
                StatisticsSend(statistic_data);
            else
                data_queue:push(statistic_data);
            end
        end
    else
        LOG.std(nil, "error", "truckparts.statistics", "Statistics: invalid data");
    end
end

function Statistics.Flush()
    LOG.std(nil, "debug", "truckparts.statistics", "statistics flush requested");
    StatisticsSchedule(nil, true);
end
--------------------------------------------------------------------------------
-- local functions
--------------------------------------------------------------------------------
function StatisticsSend(statistic_data)
    if Statistics.Inited then
        StatisticsAPI.Send(statistic_data);
    end
end

--@param placeHolder: when called by the timer, it will be the timer itself; if called manually, ignore it
--@param bSendAll: whether all data should be sent on this schedule time. Only meaningful when called manually
function StatisticsSchedule(placeHolder, bSendAll)
    --critical section here
    if data_queue then
        local send_count = 1;
        if bSendAll then
            send_count = data_queue:size();
        end
        local current_data;
        while send_count>0 do
            if data_queue:empty() then
                break;
            end
            current_data = data_queue:pop();
            StatisticsSend(current_data);
            send_count = send_count-1;
        end
    end
end
