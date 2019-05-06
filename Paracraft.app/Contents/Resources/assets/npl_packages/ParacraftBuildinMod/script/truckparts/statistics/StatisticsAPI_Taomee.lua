--[[
    Title: StatisticsAPI_Taomee
    Author(s): Cellfy
    Date Created: Sep 20, 2016
    Date Updated: Sep 20, 2016
    Desc: API adaption for taomee statistics platform
    Usage:
    ------------------------------------------------------------
    NPL.load("(gl)script/truckparts/statistics/StatisticsAPI_Taomee.lua");
    local StatisticsAPI = commonlib.gettable("truckparts.statistics.StatisticsAPI_Taomee");
    ------------------------------------------------------------
]]

NPL.load("(gl)script/Truck/Network/YcProfile.lua");
NPL.load("(gl)script/truckparts/statistics/StatisticsData.lua");

local CommonUtility = commonlib.gettable("Mod.Truck.Utility.CommonUtility");
local YcProfile = commonlib.gettable("Mod.Truck.Network.YcProfile");
local StatisticsData = commonlib.gettable("truckparts.statistics.StatisticsData");
local StatisticsDataKeyValue = commonlib.gettable("truckparts.statistics.StatisticsDataKeyValue");

local StatisticsAPI_Taomee = commonlib.gettable("truckparts.statistics.StatisticsAPI_Taomee");

function StatisticsAPI_Taomee.Init()
    StatisticsAPI_Taomee.gameid_release = 35; --game id on taomee platform
    StatisticsAPI_Taomee.gameid_dev = 662;    --game id for dev team
    if CommonUtility.IsDevVersion() then
        StatisticsAPI_Taomee.gameid = StatisticsAPI_Taomee.gameid_dev;
    else
        StatisticsAPI_Taomee.gameid = StatisticsAPI_Taomee.gameid_release;
    end
    StatisticsAPI_Taomee.taomee_statistic_url = "http://newmisc.block.taomee.block.com.block/misc.js";
    LOG.std(nil, "debug", "truckstar", "statistics taomee inited: statistic data will be sent to taomee platform");
end

function StatisticsAPI_Taomee.Send(statistic_data)
    if statistic_data and statistic_data:isa(StatisticsDataKeyValue) then
        local stid, sstid, remains;
        remains = statistic_data.Key;
        if string.len(statistic_data.Value)>0 then
            remains = remains.."."..statistic_data.Value;
        end
        stid, remains = string.match(remains, "([%w_]+)(.*)");
        sstid, remains = string.match(remains, "([%w_]+)(.*)");
        local uid = YcProfile.GetUID() or 0;
        local item = string.match(remains, "%.*([%w_%.]+)");
        if stid and sstid then
            local dataForm = {
                "gameid",
                StatisticsAPI_Taomee.gameid,
                "stid",
                stid,
                "sstid",
                sstid,
                "uid",
                uid,
            };
            -- dataForm.gameid = StatisticsAPI_Taomee.gameid;
            -- dataForm.uid = uid;
            -- dataForm.stid = stid;
            -- dataForm.sstid = sstid;
            if item then
                table.insert(dataForm, "item");
                table.insert(dataForm, item);
                --dataForm.item = item;
            end
            NPL.AppendURLRequest(
                StatisticsAPI_Taomee.taomee_statistic_url,
                "truckparts.statistics.StatisticsAPI_Taomee.TaomeeStatisticsCallback()",
                dataForm,
                "r");
        else
            LOG.std(nil, "debug", "truckstar", "StatisticsAPI:Taomee: key invalid, at least two fields are required");
        end
    else
        LOG.std(nil, "debug", "truckstar", "StatisticsAPI:Taomee: Taomee api can only handle key-value pairs data");
    end
end

function StatisticsAPI_Taomee.TaomeeStatisticsCallback()
    if msg.rcode~=200 then
        LOG.std(nil, "debug", "truckstar", "statistics data sent to taomee failed");
    end
end
