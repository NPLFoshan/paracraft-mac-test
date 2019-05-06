--[[
    Title: 
    Author(s): Cellfy
    Date Created: Jul 25, 2018
    Date Updated: Jul 25, 2018
    Desc: 
    Usage:
    ------------------------------------------------------------
    NPL.load("(gl)script/truckparts/utilities/UtilityTable.lua");
    local UtilityTable = commonlib.gettable("truckparts.utilities.UtilityTable");
    ------------------------------------------------------------
]]

local UtilityTable = commonlib.gettable("truckparts.utilities.UtilityTable");

function UtilityTable.IsTableEqual(table1, table2)
    local test_func=function(t1,t2)
        for key,value in pairs(t1) do
            local test_value=t2[key];
            if not test_value or type(test_value)~=type(value) then
                return;
            end
            if type(value)==type({}) and not UtilityTable.IsTableEqual(value,test_value) then
                return;
            end
            if type(value)~=type({}) and value~=test_value then
                return;
            end
        end
        return true;
    end;
    if type(table1)==type(table2) and type(table1)==type({}) then
        if test_func(table1,table2) and test_func(table2,table1) then
            return true;
        end
    end
end
