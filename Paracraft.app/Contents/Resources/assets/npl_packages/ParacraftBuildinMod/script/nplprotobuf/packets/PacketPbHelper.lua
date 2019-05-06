--[[
desc: wrap sending and receiving 
use the lib:
----------------------------------------------------------
NPL.load("(gl)script/nplprotobuf/packets/PacketPbHelper.lua");
local PacketPbHelper = commonlib.gettable("nplprotobuf.packets.PacketPbHelper");
----------------------------------------------------------
]]

NPL.load("(gl)script/nplprotobuf/packets/PacketPb.lua");

local UtilityTable = commonlib.gettable("truckparts.utilities.UtilityTable");
local PacketPb = commonlib.gettable("nplprotobuf.packets.PacketPb");

local PacketPbHelper = commonlib.gettable("nplprotobuf.packets.PacketPbHelper");

LOG.std(nil, "debug", "nplprotobuf", "PacketPbHelper loaded");

-- receive callbacks
local callbacks = {};
-- receive proto module
packetMap = {};
-- seq num
local seqMap = {};
local seqNumber = 10000;

local gatewaySession = nil;
local connectionNid = nil;
local messageSender = nil;

local statistics = {}

local function DEBUG_LOG(str, ...)
	LOG.std(nil, "debug", "PacketPbHelper", str, ...);
end

function PacketPbHelper.registerMemberFunc(packetName, receiver, cb)
	PacketPbHelper.registerFunc(packetName,
	function(header, body)
		cb(receiver,header, body)
	end );
end

function PacketPbHelper.registerFunc(packetName, cb)
	if (callbacks[packetName]) then
		DEBUG_LOG("warning: %s is already registered.", packetName)
	end
	callbacks[packetName] = cb;
end

function PacketPbHelper.unregisterFunc(packetName)
	callbacks[packetName] = nil;
end

function PacketPbHelper.registerPacket(packetname, proto)
	packetMap[packetname] = proto;
end

function PacketPbHelper.getProto(packetname)
	return packetMap[packetname];
end

function PacketPbHelper.setGatewaySession(gs)
	gatewaySession = gs;
end

function PacketPbHelper.setNid(nid)
	connectionNid = nid;
end

function PacketPbHelper.setMessageSender(sender_func)
	messageSender = sender_func;
end

function PacketPbHelper.checkMessageSender()
	if messageSender and type(messageSender)=="function" then
		return true;
	else
		return false;
	end
end

local gettime = ParaGlobal.timeGetTime;

function PacketPbHelper.send(name, data, callback, errCallback)
	--default target
	PacketPbHelper.sendTo({nid = connectionNid, gatewaySession = gatewaySession}, {name, data}, callback, errCallback)
end

function PacketPbHelper.sendTo(target, msg, callback, errCallback)
	local seqnum = 0;
	if (callback) then
		DEBUG_LOG("protocol: send    %s with seq: %s", msg[1], seqNumber)

		seqnum = seqNumber;
		seqMap[seqNumber] = {callback = callback, errCallback = errCallback, timestamp =  gettime()};
		seqNumber = seqNumber + 1;

	end

	local packet = PacketPb:new();
	packet:init(
	{
		{msg_name = msg[1], seq_num = seqnum, gateway_session = target.gatewaySession},
		msg[2] or {}
	});

	local send_result = false;
	if PacketPbHelper.checkMessageSender() then
		send_result = messageSender(target.nid, packet);
	else
		DEBUG_LOG("error: invalid message sender");
	end

	return send_result;
end

local function callbackDefault(h,b)
	DEBUG_LOG("error: %s with seq %s has no processor",h.msg_name , h.seq_num)
	echo(b)
end

local function errCallbackDefault(h,b)
	DEBUG_LOG("warning: uncatched protocol error (errcode: %s )", h.errcode);
end
function PacketPbHelper.process( msgheader, msgbody)
	local seq = msgheader.seq_num;
	if (seq and seq ~= 0) then
		local item = seqMap[seq];
		statistics[msgheader.msg_name] = (statistics[msgheader.msg_name] or 0) + 1;
		local lag = gettime() - (item or {timestamp = gettime()}).timestamp
		DEBUG_LOG("protocol: receive %s(%sms, %s), header : %s", msgheader.msg_name , lag, statistics[msgheader.msg_name], commonlib.serialize(msgheader) )
		if (not item) then
			DEBUG_LOG("error: %s with seq %s has no callback", msgheader.msg_name , seq);
			echo(msgbody)
		else
			local callback;
			local errcode = msgheader.errcode ;
			if (errcode and errcode ~= 0) then
				callback = item.errCallback or errCallbackDefault;
			else
				callback = item.callback or callbackDefault;
			end
			callback(msgheader, msgbody);
			seqMap[seq] = nil
			return;
		end
	end

	local cb = callbacks[msgheader.msg_name];
	if (not cb) then
		DEBUG_LOG("warning: packet %s doesnot register callback" ,msgheader.msg_name);
		echo(msgbody)
		return
	end
	cb(msgheader, msgbody)
end

function PacketPbHelper.cacheSend(message,reqData,successCallback,failedCallback)
	PacketPbHelper.mSendCache=PacketPbHelper.mSendCache or {};
	local send_cache_key={mMessage=message,mRequestData=reqData};
	local find_send_cache_index_func=function()
		for i,test_send_cache in ipairs(PacketPbHelper.mSendCache) do
			if UtilityTable.IsTableEqual(test_send_cache.mKey,send_cache_key) then
				return i;
			end
		end
	end
	local send_cache=find_send_cache_index_func();
	if send_cache then
		send_cache=PacketPbHelper.mSendCache[send_cache];
		send_cache.mSuccessCallbacks[#send_cache.mSuccessCallbacks+1]=successCallback;
		send_cache.mFailedCallbacks[#send_cache.mFailedCallbacks+1]=failedCallback;
	else
		send_cache={mKey=send_cache_key,mSuccessCallbacks={successCallback},mFailedCallbacks={failedCallback}};
		local send_cache_index=#PacketPbHelper.mSendCache+1;
		PacketPbHelper.mSendCache[send_cache_index]=send_cache;
		PacketPbHelper.send(message,reqData,
			function(h,b)
				local send_cache2=PacketPbHelper.mSendCache[send_cache_index];
				PacketPbHelper.mSendCache[send_cache_index]=nil;
				for i=1,#send_cache2.mSuccessCallbacks do
					local success_callback=send_cache2.mSuccessCallbacks[i];
					success_callback(h,b);
				end
			end,
			function()
				local send_cache2=PacketPbHelper.mSendCache[send_cache_index];
				PacketPbHelper.mSendCache[send_cache_index]=nil;
				for i=1,#send_cache2.mSuccessCallbacks do
					local success_callback=send_cache2.mSuccessCallbacks[i];
					failedCallback(h,b);
				end
			end);
	end
end
