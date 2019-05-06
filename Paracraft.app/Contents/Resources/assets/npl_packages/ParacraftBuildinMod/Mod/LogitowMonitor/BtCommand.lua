--[[
Title: BtCommand
Author(s):  
Date: 
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/LogitowMonitor/BtCommand.lua");
local BtCommand = commonlib.gettable("Mod.LogitowMonitor.BtCommand");
------------------------------------------------------------
]]
local Commands = commonlib.gettable("MyCompany.Aries.Game.Commands");
local CommandManager = commonlib.gettable("MyCompany.Aries.Game.CommandManager");

local BlockEngine = commonlib.gettable("MyCompany.Aries.Game.BlockEngine");

local BtCommand = commonlib.inherit(nil,commonlib.gettable("Mod.LogitowMonitor.BtCommand"));

function BtCommand:ctor()
end

function BtCommand:init()
	LOG.std(nil, "info", "BtCommand", "init");
	self:InstallCommand();
end

function BtCommand:InstallCommand()
	
	Commands["initLogitowBlueTooth"] = {
		name="initLogitowBlueTooth", 
		quick_ref="/initLogitowBlueTooth ", 
		desc=[[]], 
		handler = function(cmd_name, cmd_text, cmd_params, fromEntity)
			local logitowMonitor = commonlib.gettable("Mod.LogitowMonitor.LogitowMonitor");
			logitowMonitor.initWork();
		end,
	};
	
	Commands["processLogitowBlueTooth"] = {
		name="processLogitowBlueTooth", 
		quick_ref="/processLogitowBlueTooth ", 
		desc=[[]], 
		handler = function(cmd_name, cmd_text, cmd_params, fromEntity)
			local CmdParser = commonlib.gettable("MyCompany.Aries.Game.CmdParser");
			local box_id, box_face, child_id, cmd_text = CmdParser.ParsePos(cmd_text, playerEntity);
			NPL.load("(gl)Mod/LogitowMonitor/BuildBlock.lua");
			local BuildBlock = commonlib.gettable("Mod.LogitowMonitor.BuildBlock");
			if BuildBlock.root == nil then
				BuildBlock.Clear()
				
				local function onEnd()
					BuildBlock.Clear();
					nowBuildTask = nil;
				end
				
				NPL.load("(gl)Mod/LogitowMonitor/BtBaseBuildTask.lua");
				local BtBaseBuildTask = commonlib.gettable("Mod.LogitowMonitor.BtBaseBuildTask");				
				local buildTask = BtBaseBuildTask:new({onEndFunc = onEnd});
				buildTask:Run();
				nowBuildTask = buildTask;
	
			end	
			BuildBlock.ProcessCommand(box_id, box_face, child_id);
		end,
	};	
	
	Commands["showBluePage"] = {
		name="showBluePage", 
		quick_ref="/showBluePage ", 
		desc=[[]], 
		handler = function(cmd_name, cmd_text, cmd_params, fromEntity)
			NPL.load("(gl)Mod/LogitowMonitor/BlueToothSearchPage.lua");
			local BlueToothSearchPage = commonlib.gettable("MyCompany.Aries.Game.GUI.BlueToothSearchPage");
			
			if BlueToothSearchPage.page then
				BlueToothSearchPage.OnClose();
			else
				BlueToothSearchPage.OnShowPage();
			end
		end,
	};	

end
