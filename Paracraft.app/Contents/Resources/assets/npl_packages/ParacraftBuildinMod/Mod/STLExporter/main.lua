--[[
Title: bmax exporter
Author(s): leio, refactored LiXizhi
Date: 2015/11/25
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/STLExporter/main.lua");
local STLExporter = commonlib.gettable("Mod.STLExporter");
local exporter = STLExporter:new();
exporter:Export("test/default.bmax",nil,true);
------------------------------------------------------------
]]
local CmdParser = commonlib.gettable("MyCompany.Aries.Game.CmdParser");	
NPL.load("(gl)script/ide/System/Encoding/base64.lua");
NPL.load("(gl)script/ide/TooltipHelper.lua");
local Encoding = commonlib.gettable("System.Encoding");
local BroadcastHelper = commonlib.gettable("CommonCtrl.BroadcastHelper");
local STLExporter = commonlib.inherit(commonlib.gettable("Mod.ModBase"),commonlib.gettable("Mod.STLExporter"));

function STLExporter:ctor()
end

-- virtual function get mod name
function STLExporter:GetName()
	return "STLExporter"
end

-- virtual function get mod description 
function STLExporter:GetDesc()
	return "STLExporter is a plugin in paracraft"
end

function STLExporter:init()
	LOG.std(nil, "info", "STLExporter", "plugin initialized");

	self:RegisterCommand();
	self:RegisterExporter();
end

function STLExporter:OnLogin()
end
-- called when a new world is loaded. 

function STLExporter:OnWorldLoad()
end
-- called when a world is unloaded. 

function STLExporter:OnLeaveWorld()
end

function STLExporter:OnDestroy()
end

-- add plugin integration points with the IDE
function STLExporter:RegisterExporter()
	GameLogic.GetFilters():add_filter("GetExporters", function(exporters)
		exporters[#exporters+1] = {id="STL", title=L"导出STL", desc=L"导出STL文件,方便3D打印"}
		return exporters;
	end);

	GameLogic.GetFilters():add_filter("select_exporter", function(id)
		if(id == "STL") then
			id = nil; -- prevent other exporters
			self:OnClickExport();
		end
		return id;
	end);
end

function STLExporter:RegisterCommand2()
	local Commands = commonlib.gettable("MyCompany.Aries.Game.Commands");
	Commands["stlexporter"] = {
		name="stlexporter", 
		quick_ref="/stlexporter [-b|binary] [-native|cpp] [filename]", 
		desc=[[export a bmax file or current selection to stl file
@param -b: export as binary STL file
@param -native: use C++ exporter, instead of NPL.
/stlexporter test.stl			export current selection to test.stl file
/stlexporter -b test.bmax		convert test.bmax file to test.stl file
]], 
		handler = function(cmd_name, cmd_text, cmd_params, fromEntity)
			local file_name, options;
			options, cmd_text = CmdParser.ParseOptions(cmd_text);
			file_name,cmd_text = CmdParser.ParseString(cmd_text);

			local save_as_binary = options.b~=nil or options.binary~=nil;
			local use_cpp_native = options.native~=nil or options.cpp~=nil;
			self:Export(file_name,nil, save_as_binary, use_cpp_native);
		end,
	};
end
function STLExporter:RegisterCommand()
	local Commands = commonlib.gettable("MyCompany.Aries.Game.Commands");
	Commands["stlexporter"] = {
		name="stlexporter", 
		quick_ref="/stlexporter [-b|binary] [-native|cpp] [filename] [unit_value] [bUpload]", 
		desc=[[export a bmax file or current selection to stl file
@param -b: export as binary STL file
@param -native: use C++ exporter, instead of NPL.
/stlexporter test.stl			export current selection to test.stl file
/stlexporter -b test.bmax		convert test.bmax file to test.stl file
]], 
		handler = function(cmd_name, cmd_text, cmd_params, fromEntity)
			local file_name, options;
			options, cmd_text = CmdParser.ParseOptions(cmd_text);
			file_name,cmd_text = CmdParser.ParseString(cmd_text);
			unit_value,cmd_text = CmdParser.ParseString(cmd_text);
			bUpload,cmd_text = CmdParser.ParseBool(cmd_text);
			unit_value = tonumber(unit_value)
			local save_as_binary = options.b~=nil or options.binary~=nil;
			local use_cpp_native = options.native~=nil or options.cpp~=nil;
			self:Export(file_name,nil, save_as_binary, use_cpp_native,unit_value,bUpload);
		end,
	};
end
function STLExporter:OnClickExport()
	NPL.load("(gl)Mod/STLExporter/SaveSTLDialog.lua");
	local SaveSTLDialog = commonlib.gettable("Mod.STLExporter.SaveSTLDialog");
	SaveSTLDialog.ShowPage(L"请输入文件名:", function(result)
		if(result and result.filename and result.filename ~= "") then
			STLExporter.last_filename = result.filename;
			local filename = GameLogic.GetWorldDirectory()..result.filename;
			LOG.std(nil, "info", "STLExporter", "exporting to %s", filename);
			GameLogic.RunCommand("stlexporter", string.format("%s %f %s",filename,result.unit,tostring(result.bUpload)));
		end
	end, STLExporter.last_filename or "test", nil, "stl");
end

-- @param input_file_name: file name. if it is *.bmax, we will convert this file and save output to *.stl file.
-- if it is not, we will convert current selection to *.stl files. 
-- @param output_file_name: this should be nil, unless you explicitly specify an output name. 
-- @param -binary: export as binary STL file
-- @param -native: use C++ exporter, instead of NPL.
-- @param unit_value:1 block = unit_value(um,mm,cm,in,ft,m) only valid in NPL exporter now.
-- @param bUpload:if bUpload = ture, it will upload stl file to "www.geekrit.com/api/file/upload3DFile"
--        details info please see:https://github.com/LiXizhi/STLExporter/wiki/3DPrintingAPI
function STLExporter:Export(input_file_name,output_file_name,binary,native,unit_value,bUpload)
	input_file_name = input_file_name or "default.stl";
	binary = binary == true;

	local name, extension = string.match(input_file_name,"(.+)%.(%w+)$");

	if(not output_file_name)then
		if(extension == "bmax") then
			output_file_name = name .. ".stl";
		elseif(extension == "stl") then
			output_file_name = name .. ".stl";
		else
			output_file_name = input_file_name..".stl";
		end
	end
	LOG.std(nil, "info", "STLExporter", "exporting from %s to %s", input_file_name, output_file_name);
	
	local res;
	if(native and ParaScene.BmaxExportToSTL)then
		-- use the C++ ParaEngine, functions may be limited. 
		res = ParaScene.BmaxExportToSTL(input_file_name,output_file_name, binary);
	else
		NPL.load("(gl)Mod/STLExporter/BMaxModel.lua");
		local BMaxModel = commonlib.gettable("Mod.STLExporter.BMaxModel");
		NPL.load("(gl)Mod/STLExporter/STLWriter.lua");
		local STLWriter = commonlib.gettable("Mod.STLExporter.STLWriter");

		local model = BMaxModel:new();
		model:SetUnit(unit_value);
		if(extension == "bmax") then
			model:Load(input_file_name);
		else
			-- load from current selection
			local blocks = Game.SelectionManager:GetSelectedBlocks();
			if(blocks) then
				model:LoadFromBlocks(blocks);
			end
		end
		
		local writer = STLWriter:new();
		-- STL file uses Z up
		writer:SetYAxisUp(false);
		writer:LoadModel(model);

		if(binary)then
			res = writer:SaveAsBinary(output_file_name);
		else
			res = writer:SaveAsText(output_file_name);
		end
		if(bUpload)then
			STLExporter:Upload(output_file_name);
			return
		end
	end
	if(res)then
		_guihelper.MessageBox(format(L"文件成功保存在%s,现在打开吗?", commonlib.Encoding.DefaultToUtf8(output_file_name)), function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
				ParaGlobal.ShellExecute("open", ParaIO.GetCurDirectory(0)..output_file_name, "", "", 1);
			end
		end, _guihelper.MessageBoxButtons.YesNo);
	end
end
function STLExporter:Upload(filename)
	if(not ParaIO.DoesFileExist(filename))then
		return
	end
	local file = ParaIO.open(filename, "r");
	if(file:IsValid()) then
		local stl_data = file:GetText(0,-1);
		file:close();
		local base_url = "http://share.tatfook.com";
		local url = base_url.."/api/file/upload3DFile"
		local params = {	url = url,
							headers = { 
								Referer = base_url.."/client/upload3D" ,
								Expect = "",
							},
							form = { file = { file=filename, type = "text/stl", data = stl_data } },
						}
		BroadcastHelper.PushLabel({id="UplaodSTL", label = L"上传中,请稍等......", max_duration=5000, color = "0 255 0", scaling=1.1, bold=true, shadow=true,});
		LOG.std(nil, "info", "STLExporter upload stl params", params);
		System.os.GetUrl(params, 
		function(err, msg, data)		
			LOG.std(nil, "info", "STLExporter err", err);
			LOG.std(nil, "info", "STLExporter msg", msg);
			LOG.std(nil, "info", "STLExporter data", data);
			if(data and data.data and data.data.file_id)then
				local s = string.format(base_url.."/client/upload3D?fileId=%s",tostring(data.data.file_id));
				ParaGlobal.ShellExecute("open", "iexplore.exe", s, "", 1);
			else
				BroadcastHelper.PushLabel({id="UplaodSTL", label = L"上传stl文件失败.", max_duration=5000, color = "255 0 0", scaling=1.1, bold=true, shadow=true,});
			end
		end);
	end

end
