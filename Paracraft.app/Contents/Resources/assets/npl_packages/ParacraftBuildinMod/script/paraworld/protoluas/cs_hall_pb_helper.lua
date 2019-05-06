--[[
    Title: cs_hall_pb_helper
    Author(s): Cellfy
    Date Created: Aug 8, 2018
    Date Updated: Aug 8, 2018
    Desc: 
    Usage:
    ------------------------------------------------------------
    NPL.load("(gl)script/paraworld/protoluas/cs_hall_pb_helper.lua");
    ------------------------------------------------------------
]]
NPL.load("(gl)script/paraworld/protoluas/cs_hall_pb.lua");

local PacketPbHelper = commonlib.gettable("nplprotobuf.packets.PacketPbHelper");

function PacketPbHelper.sendCSLoginHallReq(openid, openkey, pf, succ_callback, err_callback)
    local msg = {
        openid = openid,
        openkey = openkey,
        pf = pf,
        userip = "1.2.3.4",
    };
    PacketPbHelper.send("CSLoginHallReq", msg, succ_callback, err_callback);
end
