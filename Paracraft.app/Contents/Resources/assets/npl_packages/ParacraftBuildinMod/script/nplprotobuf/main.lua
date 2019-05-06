--[[
    Title: main.lua
    Author(s): Cellfy
    Date Created: Jul 26, 2018
    Date Updated: Jul 26, 2018
    Desc: 
    Usage:
    ------------------------------------------------------------
    NPL.load("(gl)script/nplprotobuf/main.lua");
    or simply
    NPL.load("npl_packages/nplprotobuf/");
    ------------------------------------------------------------
]]
local function Initialize()
    NPL.load("npl_packages/truckparts/");

    NPL.load("(gl)script/nplprotobuf/packets/PacketPbHelper.lua");
    NPL.load("(gl)script/nplprotobuf/protoluas/cs_msgheader_pb.lua");
    
    LOG.std(nil, "debug", "nplprotobuf", "package npl protobuf initialized");
end

Initialize();
