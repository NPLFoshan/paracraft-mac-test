--[[
NPL.load("(gl)script/Truck/Network/Connection.lua");
local Connection = commonlib.gettable("Mod.Truck.Network.Connection");
]]

local Connection = commonlib.inherit(nil, commonlib.gettable("Mod.Truck.Network.Connection"));


function Connection:init(nid, handler, remote_file)
	self.nid = nid;
	self.handler = handler;
	self.connected = false;
	self.remote_file = remote_file or "remote file"; --dummy id if not specified, completely meaningless
	return self;
end

function Connection:connect(msg, remote_file)
	if self:trySend(msg, remote_file) then
		return;
	end

	local intervals = {100, 300,500, 1000, 1000, 1000, 1000}; -- intervals to try
	local try_count = 0;
		
	local mytimer = commonlib.Timer:new({callbackFunc = function(timer)
		commonlib.log("try to connect " .. tostring(try_count + 1).. " count\n");
		try_count = try_count + 1;
		if not self:trySend(msg, remote_file)  then
			if(intervals[try_count]) then
				timer:Change(intervals[try_count], nil);
			else
				-- timed out. 
				self:onError("ConnectionNotEstablished");
				LOG.std(nil, "warn", "Connection", "unable to send to %s.", self.nid);
			end	
		else
			-- connected 
			self.connected = true;
		end
	end})
	mytimer:Change(10, nil);
end

function Connection:disconnect(reason)
	NPL.reject({["nid"]=self.nid, ["reason"]=reason});
	self.connected = false;
	self.nid = nil;
end

function Connection:send(msg, remote_file)
	if self.connected then 
		if self:trySend(msg, remote_file) then 
			return true;
		else
			self:onError(string.format("unable to send to %s", self.nid));
		end
	else
		self:connect(msg);
	end
end

function Connection:trySend(msg, remote_file)
	if not remote_file then
		remote_file = self.remote_file;
	end
	local address = string.format("(gl)%s:%s", self.nid, remote_file);
	return NPL.activate(address, msg) == 0 ;
end


function Connection:isConnected()
	return self.connected;
end

function Connection:onReceive(msg)
	self.handler:handleMsg(msg);
end

function Connection:onError(reason)
	if self.handler and self.handler.handleErrorMessage then 
		self.handler:handleErrorMessage(reason, self.nid);
	end
end
