--[[
    Title: StatisticsAPI_Paraworld
    Author(s): Cellfy
    Date Created: Sep 20, 2016
    Date Updated: Sep 20, 2016
    Desc: API adaption for forwarding statistics data to paraworld
    Usage:
    ------------------------------------------------------------
    NPL.load("(gl)script/truckparts/statistics/StatisticsAPI_Paraworld.lua");
    local StatisticsAPI = commonlib.gettable("truckparts.statistics.StatisticsAPI_Paraworld");
    ------------------------------------------------------------
]]

NPL.load("(gl)script/Truck/Network/YcProfile.lua");
NPL.load("(gl)script/truckparts/statistics/StatisticsData.lua");

local StatisticsData = commonlib.gettable("truckparts.statistics.StatisticsData");
local StatisticsDataKeyValue = commonlib.gettable("truckparts.statistics.StatisticsDataKeyValue");

local StatisticsAPI_Paraworld = commonlib.gettable("truckparts.statistics.StatisticsAPI_Paraworld");

function StatisticsAPI_Paraworld.Init()
    LOG.std(nil, "debug", "truckparts.statistics", "statistics paraworld inited: statistic data will be sent to paraworld");
end

function StatisticsAPI_Paraworld.Send(statistic_data)
    if statistic_data and statistic_data:isa(StatisticsDataKeyValue) then
        GameLogic.platformConnector:SendMessage({
                command="g2p_statistics_data",
                data = {
                    key = statistic_data.Key,
                    value = statistic_data.Value,
                },
        });
    else
        LOG.std(nil, "debug", "truckparts.statistics", "StatisticsAPI:Paraworld: Paraworld api can only handle key-value pairs data");
    end
end

function StatisticsAPI_Paraworld.ParaworldStatisticsCallback(ret_msg)
    if ret_msg.rcode~=200 then
        LOG.std(nil, "debug", "truckparts.statistics", "statistics data sent to paraworld failed");
    end
end
