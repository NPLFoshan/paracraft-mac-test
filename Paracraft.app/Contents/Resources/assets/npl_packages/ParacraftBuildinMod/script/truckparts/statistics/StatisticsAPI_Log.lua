--[[
    Title: StatisticsAPI_Log
    Author(s): Cellfy
    Date Created: Sep 21, 2016
    Date Updated: Sep 21, 2016
    Desc: write statistics data into local log
    Usage:
    ------------------------------------------------------------
    NPL.load("(gl)script/truckparts/statistics/StatisticsAPI_Log.lua");
    local StatisticsAPI = commonlib.gettable("truckparts.statistics.StatisticsAPI_Log");
    ------------------------------------------------------------
]]

NPL.load("(gl)script/truckparts/statistics/StatisticsData.lua");

local StatisticsData = commonlib.gettable("truckparts.statistics.StatisticsData");

local StatisticsAPI_Log = commonlib.gettable("truckparts.statistics.StatisticsAPI_Log");

function StatisticsAPI_Log.Init()
    LOG.std(nil, "debug", "truckparts.statistics", "statistics log inited: statistic data will be written into the local log file");
end

function StatisticsAPI_Log.Send(statistic_data)
    if statistic_data and statistic_data:isa(StatisticsData) then
        LOG.std(nil, "debug", "statistic", "----------------------------------begin statistic data node----------------------------------");
        echotable(statistic_data);
        LOG.std(nil, "debug", "statistic", "----------------------------------end statistic data node----------------------------------");
    else
        LOG.std(nil, "debug", "truckparts.statistics", "StatisticsAPI:Log: data invalid");
    end
end
