--[[
Title: PacketPb
Author(s): leio
Date: 2015/8/25
Desc: 
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/nplprotobuf/packets/PacketPb.lua");
local PacketPb = commonlib.gettable("nplprotobuf.packets.PacketPb");
-------------------------------------------------------
]]

NPL.load("(gl)script/nplprotobuf/packets/PacketPbHelper.lua");

local ZZBase64 = commonlib.gettable("truckparts.utilities.ZZBase64");
local PacketPbHelper = commonlib.gettable("nplprotobuf.packets.PacketPbHelper");

local PacketPb = commonlib.inherit(nil, commonlib.gettable("nplprotobuf.packets.PacketPb"));

PacketPb.isChunkDataPacket = nil;

local function getProto(name)
	local proto = PacketPbHelper.getProto(name);
	if(not proto) then
		commonlib.log("error: unregistered packet "..name.."\n");
		return nil
	end
	return proto[name]();
end

function PacketPb:ctor()
end

local function serializePacket(container, data)
	local key, value;
	for key, value in pairs(data) do
		if (type(value) == "table") then
			local c = container[key];
			if (not c) then
				commonlib.log("error: packet needs member: ".. key.."\n");
			else
				if (#value == 0) then
					serializePacket(c, value);
				else
					-- array
					local _, v;
					v = value[1];
					if (type(v) == "table") then
						--structure
						for _,v in ipairs(value) do
							local item = c:add();
							serializePacket(item, v);
						end
					else
						--base type
						for _,v in ipairs(value) do
							c:append(v);
						end
					end

				end
			end
		else
			container[key] = value;
		end
	end
end

local function  unserializePacket( packet)
	local output = {}
	local key, value;
	for key, value in packet:ListFields() do
		if(type(value) == "table" ) then
			--repeated
			if ( #value ~= 0) then
				local tbl = {};
				if (key.type == 11) then -- structure
					for _,v in ipairs(value) do
						tbl[#tbl + 1] = unserializePacket(v);
					end
				else -- base type
					for k,v in ipairs(value) do 
						tbl[#tbl + 1] = value[k];
					end
				end
				output[key.name] = tbl;
			else
				local tbl = unserializePacket(value) ;
				output[key.name] = tbl;
			end
		else
			output[key.name] = value;
		end
	end
	return output;
end

local function encode(pb)
	local s = pb:SerializeToString();
	return ZZBase64.encode(s);
end

-- pb: output
-- data: input
local function decode(pb, data)
	local d = ZZBase64.decode(data);
	if (d) then
		pb:ParseFromString(d);
	end
end

function PacketPb:WritePacket()
	return self:serialize();
end
--[[
	{
		{msg header table} : msg_name is neccessery
		{msg body table}
	}
]]
function PacketPb:init(args)
	if (not args[1] or not args[1].msg_name) then
		commonlib.log("error: invalid packet args\n")
		echo(args)
		return;
	end

	self.headerRaw = args[1];
	self.bodyRaw = args[2];
	--delay serializing
end

function PacketPb:unserialize(msg)
	local header = cs_msgheader_pb.CSMessageHeader();
	decode(header, msg.h);
	self.headerRaw = unserializePacket(header);

	local body = getProto(self.headerRaw.msg_name);
	decode(body, msg.b);
	self.bodyRaw = unserializePacket(body)

	--self.pb_header = header;
	--self.pb_body	= body;
end

function PacketPb:serialize()
	local header = cs_msgheader_pb.CSMessageHeader();
	local msgname = self.headerRaw.msg_name;
	local body = getProto(self.headerRaw.msg_name);

	serializePacket(header,self.headerRaw);
	serializePacket(body, self.bodyRaw)

	return {h = encode(header),b = encode(body)};
end

