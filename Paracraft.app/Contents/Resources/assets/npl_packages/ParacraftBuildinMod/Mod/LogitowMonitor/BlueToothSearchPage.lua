--[[
NPL.load("(gl)Mod/LogitowMonitor/BlueToothSearchPage.lua");
local BlueToothSearchPage = commonlib.gettable("MyCompany.Aries.Game.GUI.BlueToothSearchPage");
]]

local BlueToothSearchPage = commonlib.gettable("MyCompany.Aries.Game.GUI.BlueToothSearchPage");
local LogitowMonitor = commonlib.gettable("Mod.LogitowMonitor.LogitowMonitor");

local lesson_worlds = {
	{
		displayname = L"创意几何", 
		title = L"进入“创意几何”世界", 
		icon = "Mod/LogitowMonitor/textures/icon_world_min.png",
		tooltip = L"",
	},
	{
		displayname = L"更多应用", 
		title = L"查看更多应用网页", 
		icon = "Mod/LogitowMonitor/textures/icon_more_min.png",
		tooltip = L"",
	},
	{
		displayname = L"客户支持", 
		title = L"查看客户支持网页", 
		icon = "Mod/LogitowMonitor/textures/icon_sup_min.png",
		tooltip = L"",
	},
};

function BlueToothSearchPage.LessonWorldsDs(index)
	if(not index) then
		return #lesson_worlds
	else
		return BlueToothSearchPage.GetLessonByIndex(index);
	end
end

function BlueToothSearchPage.GetLessonByIndex(index)
	return lesson_worlds[index];
end

function BlueToothSearchPage.GetTootipByIndex(index)
	--return "page://script/apps/Aries/Creator/Game/Login/ParaWorldLessonTooltip.html?index="..tostring(index);
	return L"index:" .. index;
end

function BlueToothSearchPage.OnClickWorld(index)
	if(index == 1)then
		BlueToothSearchPage.ChangeNarrowWide();
		
		local filename = "https://git.keepwork.com/gitlab_rls_hetter1/world_base32_mn4wu2brgeyte/repository/archive.zip";
		
		NPL.load("(gl)script/apps/Aries/Creator/Game/Login/DownloadWorld.lua");
		local DownloadWorld = commonlib.gettable("MyCompany.Aries.Game.MainLogin.DownloadWorld")
		NPL.load("(gl)script/apps/Aries/Creator/Game/Login/RemoteWorld.lua");
		local RemoteWorld = commonlib.gettable("MyCompany.Aries.Creator.Game.Login.RemoteWorld");
		
		local world;
		local function LoadWorld_(world, refreshMode)
			if(world) then
				local mytimer = commonlib.Timer:new({callbackFunc = function(timer)
					NPL.load("(gl)script/apps/Aries/Creator/Game/Login/InternetLoadWorld.lua");

					local InternetLoadWorld = commonlib.gettable("MyCompany.Aries.Creator.Game.Login.InternetLoadWorld");
					InternetLoadWorld.LoadWorld(world, nil, refreshMode or "auto", function(bSucceed, localWorldPath)
						DownloadWorld.Close();
					end);
				end});
				-- prevent recursive calls.
				mytimer:Change(1,nil);
			else
				_guihelper.MessageBox(L"无效的世界文件");
			end
		end
		
		local RemoteWorld = commonlib.gettable("MyCompany.Aries.Creator.Game.Login.RemoteWorld");
		world = RemoteWorld.LoadFromHref(filename, "self");
		DownloadWorld.ShowPage(filename);
		LoadWorld_(world, "auto");
	elseif(index == 2) then
		ParaGlobal.ShellExecute("open", "https://keepwork.com/official/bluetooth/index", "", "", 1);
	elseif(index == 3) then
		ParaGlobal.ShellExecute("open", "https://keepwork.com/official/bluetooth/support", "", "", 1);
	end
end


function BlueToothSearchPage.OnInit(isNarrow)
	BlueToothSearchPage.isNarrowMode = isNarrow;
	BlueToothSearchPage.page = document:GetPageCtrl();
end

function BlueToothSearchPage.OnDragBegin()
	if BlueToothSearchPage.page and BlueToothSearchPage.isNarrowMode then
		local dragContainer = BlueToothSearchPage.page:FindControl("narrow_mode")
		local x,y = dragContainer:GetAbsPosition();
		BlueToothSearchPage.dx1 = x;
		BlueToothSearchPage.dy1 = y;
	end	
end	

function BlueToothSearchPage.OnDragEnd()
	if BlueToothSearchPage.page and BlueToothSearchPage.isNarrowMode then
		local dragContainer = BlueToothSearchPage.page:FindControl("narrow_mode")
		local x,y = dragContainer:GetAbsPosition();
		
		BlueToothSearchPage.narrowX = BlueToothSearchPage.narrowX + (BlueToothSearchPage.dx2 - BlueToothSearchPage.dx1);
		BlueToothSearchPage.narrowY = BlueToothSearchPage.narrowY + (BlueToothSearchPage.dy2 - BlueToothSearchPage.dy1);
	end	
end	

function BlueToothSearchPage.OnDragMove()
	if BlueToothSearchPage.page and BlueToothSearchPage.isNarrowMode then
		local dragContainer = BlueToothSearchPage.page:FindControl("narrow_mode")
		local x,y = dragContainer:GetAbsPosition();
		BlueToothSearchPage.dx2 = x;
		BlueToothSearchPage.dy2 = y;
		
		local Page = BlueToothSearchPage.page
		local x, y, width, height = Page:FindControl("narrow_mode"):GetAbsPosition();
		local wnd = Page:GetWindow():GetWindowFrame():GetWindowUIObject();
		if(wnd) then
			wnd:Reposition("_lt", x, y, width, height)
		end			
	end	
end	

function BlueToothSearchPage.OnClose()

	if BlueToothSearchPage.page then
		BlueToothSearchPage.page:CloseWindow();
		BlueToothSearchPage.page = nil;
	end
end

function BlueToothSearchPage._ShowPageWide()
	local params = {
			url = "Mod/LogitowMonitor/BlueToothSearchPage_wide.html", 
			name = "PC.BlueToothSearchPage_wide", 
			isShowTitleBar = false,
			DestroyOnClose = true,
			bToggleShowHide=false, 
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = false,
			enable_esc_key = false,
			bShow = true,
			--isTopLevel = true,
			zorder = 999,
			click_through = false, 
			cancelShowAnimation = true,
			directPosition = true,
				align = "_fi",
				x = 0,
				y = 0,
				width = 0,
				height = 0,
			};
		
	System.App.Commands.Call("File.MCMLWindowFrame", params);
end


function BlueToothSearchPage._ShowPageNarrow()
	if BlueToothSearchPage.narrowX == nil or BlueToothSearchPage.narrowY == nil then
		BlueToothSearchPage.narrowX = -200;
		BlueToothSearchPage.narrowY = 0;
	end
	local params = {
			url = "Mod/LogitowMonitor/BlueToothSearchPage_narrow.html", 
			name = "PC.BlueToothSearchPage_narrow", 
			isShowTitleBar = false,
			DestroyOnClose = true,
			bToggleShowHide=false, 
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = true,
			enable_esc_key = false,
			bShow = true,
			--isTopLevel = true,
			zorder = 999,
			click_through = false, 
			cancelShowAnimation = true,
			directPosition = true,
				align = "_rt",
				x = BlueToothSearchPage.narrowX, 
				y = BlueToothSearchPage.narrowY,
				width = 200,
				height = 200,
			};
		
	System.App.Commands.Call("File.MCMLWindowFrame", params);
end

BlueToothSearchPage.isNarrowMode = false;
function BlueToothSearchPage.OnShowPage()
	if not BlueToothSearchPage.page then
		if(BlueToothSearchPage.isNarrowMode) then
			BlueToothSearchPage._ShowPageNarrow()
		else	
			BlueToothSearchPage._ShowPageWide()
		end
	end	
	BlueToothSearchPage.SetBlueTips();	
end	

function BlueToothSearchPage.ChangeNarrowWide()
	BlueToothSearchPage.OnClose();	
	BlueToothSearchPage.isNarrowMode = not BlueToothSearchPage.isNarrowMode;
	BlueToothSearchPage.OnShowPage();
end

function BlueToothSearchPage.SetBlueTips()
	local isBlueConnect = LogitowMonitor.isConnect;
	if BlueToothSearchPage.page then
		if isBlueConnect then
			if BlueToothSearchPage.searchTimer then
				BlueToothSearchPage.searchTimer:Change();
				BlueToothSearchPage.searchTimer = nil;
			end	
			
			
			local blv = math.floor(LogitowMonitor.blueBattery or 0);
			
			BlueToothSearchPage.page:SetValue("txt_battery", string.format("%d%%", blv));	
			BlueToothSearchPage.page:SetValue("progressbar_battery", blv);
			local mcmlNode = BlueToothSearchPage.page:GetNode("lense");
			mcmlNode:SetAttribute("visible", "false");
		else	
			BlueToothSearchPage.page:SetValue("txt_battery", "--");
			BlueToothSearchPage.page:SetValue("progressbar_battery", 0);
			--local mcmlNode = BlueToothSearchPage.page:GetNode("lense");
			--mcmlNode:SetAttribute("visible", "true");
			
			BlueToothSearchPage.doSearchAnim();
		end	
		BlueToothSearchPage.page:Refresh(0.01);
	end
end	

function BlueToothSearchPage.RefreshOnLoadWorldFinshed()
	if BlueToothSearchPage.page then
		BlueToothSearchPage.OnClose();
		BlueToothSearchPage.OnShowPage();
	else
		BlueToothSearchPage.OnShowPage();
	end
end

function BlueToothSearchPage.doSearchAnim()
	if(not BlueToothSearchPage.searchTimer) then
		if LogitowMonitor.isConnect then
			return;
		end
	
		BlueToothSearchPage.searchTimer = commonlib.Timer:new({callbackFunc = function(timer)
			if BlueToothSearchPage.page then
				local mcmlNode = BlueToothSearchPage.page:GetNode("lense");
				if mcmlNode then
					local visible = mcmlNode:GetAttributeWithCode("visible", nil, true);
					visible = tostring(visible);			
					if(visible and visible == "false")then
						mcmlNode:SetAttribute("visible", "true");
					else
						mcmlNode:SetAttribute("visible", "false");
					end	
					BlueToothSearchPage.page:Refresh(0.01);
				end
			end
		end})
		
		--BlueToothSearchPage.searchTimer:Change(500, 500);
	end
end