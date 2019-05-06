--[[
    Title: StatisticsData
    Author(s): Cellfy
    Date Created: Sep 20, 2016
    Date Updated: Sep 20, 2016
    Desc: Basic data structure for statistics usage
    Usage:
    ------------------------------------------------------------
    NPL.load("(gl)script/truckparts/statistics/StatisticsData.lua");
    local StatisticsData = commonlib.gettable("truckparts.statistics.StatisticsData");
    local StatisticsDataKeyValue = commonlib.gettable("truckparts.statistics.StatisticsDataKeyValue");
    ------------------------------------------------------------
]]

--------------------------------------------------------------------------------
-- Basic Data Type
--------------------------------------------------------------------------------
local StatisticsData = commonlib.inherit(nil, commonlib.gettable("truckparts.statistics.StatisticsData"));

function StatisticsData:ctor()
    self.DataType = "Base";
end

function StatisticsData:Type()
    return self.DataType;
end

--------------------------------------------------------------------------------
-- Key-Value Data Type
--------------------------------------------------------------------------------
local StatisticsDataKeyValue = commonlib.inherit(StatisticsData, commonlib.gettable("truckparts.statistics.StatisticsDataKeyValue"));

function StatisticsDataKeyValue:ctor()
    self.DataType = "KeyValue";
end

function StatisticsDataKeyValue:SetData(str_key, str_value)
    local check_ok = true;
    if type(str_key)~="string" then
        LOG.std(nil, "error", "truckparts.statistics", "StatisticsDataKeyValue: invalid key");
        check_ok = false;
    end
    if type(str_value)~="string" then
        LOG.std(nil, "error", "truckparts.statistics", "StatisticsDataKeyValue: invalid value");
        check_ok = false;
    end
    if check_ok then
        self.Key = str_key;
        self.Value = str_value;
    end
end

--------------------------------------------------------------------------------
-- Key-Value-in-Domain Data Type
--------------------------------------------------------------------------------
local StatisticsDataKeyValueWithinDomain = commonlib.inherit(StatisticsDataKeyValue, commonlib.gettable("truckparts.statistics.StatisticsDataKeyValueWithinDomain"));

function StatisticsDataKeyValueWithinDomain:ctor()
    self.DataType = "KeyValueWithinDomain";
end

function StatisticsDataKeyValueWithinDomain:SetData(str_key, str_value, str_domain)
    local check_ok = true;
    if type(str_key)~="string" then
        LOG.std(nil, "error", "truckparts.statistics", "StatisticsDataKeyValueWithinDomain: invalid key");
        check_ok = false;
    end
    if type(str_value)~="string" then
        LOG.std(nil, "error", "truckparts.statistics", "StatisticsDataKeyValueWithinDomain: invalid value");
        check_ok = false;
    end
    if type(str_domain)~="string" then
        LOG.std(nil, "error", "truckparts.statistics", "StatisticsDataKeyValueWithinDomain: invalid domain");
        check_ok = false;
    end
    if check_ok then
        self.Key = str_key;
        self.Value = str_value;
        self.Domain = str_domain;
    end
end

