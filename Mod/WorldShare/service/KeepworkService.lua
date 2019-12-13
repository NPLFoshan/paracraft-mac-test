--[[
Title: KeepworkService
Author(s):  big
Date:  2018.06.21
Place: Foshan
use the lib:
------------------------------------------------------------
local KeepworkService = NPL.load("(gl)Mod/WorldShare/service/KeepworkService.lua")
------------------------------------------------------------
]]
local Encoding = commonlib.gettable("commonlib.Encoding")

local GitService = NPL.load("./GitService.lua")
local GitGatewayService = NPL.load("./GitGatewayService.lua")
local LocalService = NPL.load("./LocalService.lua")
local UserConsole = NPL.load("(gl)Mod/WorldShare/cellar/UserConsole/Main.lua")
local WorldList = NPL.load("(gl)Mod/WorldShare/cellar/UserConsole/WorldList.lua")
local KeepworkServiceProject = NPL.load('./KeepworkService/Project.lua')
local Config = NPL.load("(gl)Mod/WorldShare/config/Config.lua")

local KeepworkService = NPL.export()

function KeepworkService:GetEnv()
    for key, item in pairs(Config.env) do
        if key == Config.defaultEnv then
            return Config.defaultEnv
        end
    end

	return Config.env.ONLINE
end

function KeepworkService:GetKeepworkUrl()
	local env = self:GetEnv()

	return Config.keepworkList[env]
end

function KeepworkService:GetCoreApi()
    local env = self:GetEnv()

    return Config.keepworkServerList[env]
end

function KeepworkService:GetLessonApi()
    local env = self:GetEnv()

    return Config.lessonList[env]
end

function KeepworkService:GetServerList()
    if (LOG.level == "debug") then
        return {
            {value = Config.env.ONLINE, name = Config.env.ONLINE, text = L"使用KEEPWORK登录", selected = true},
            {value = Config.env.STAGE, name = Config.env.STAGE, text = L"使用STAGE登录"},
            {value = Config.env.RELEASE, name = Config.env.RELEASE, text = L"使用RELEASE登录"},
            {value = Config.env.LOCAL, name = Config.env.LOCAL, text = L"使用本地服务登录"}
        }
    else
        return {
            {value = Config.env.ONLINE, name = Config.env.ONLINE, text = L"使用KEEPWORK登录", selected = true}
        }
    end
end

function KeepworkService:IsSignedIn()
    local token = Mod.WorldShare.Store:Get("user/token")

    return token ~= nil
end

function KeepworkService:GetToken()
    local token = Mod.WorldShare.Store:Get('user/token')

    return token or ''
end

-- get keepwork project url
function KeepworkService:GetShareUrl()
    local env = self:GetEnv()
    local currentWorld = Mod.WorldShare.Store:Get("world/currentWorld")

    if not currentWorld or not currentWorld.kpProjectId then
        return ''
    end

    local baseUrl = Config.keepworkList[env]
    local foldername = Mod.WorldShare.Store:Get("world/foldername")
    local username = Mod.WorldShare.Store:Get("user/username")

    return format("%s/pbl/project/%d/", baseUrl, currentWorld.kpProjectId)
end

-- update world info
function KeepworkService:UpdateRecord(callback)
    local username = Mod.WorldShare.Store:Get("user/username")
    local foldername = Mod.WorldShare.Store:Get("world/foldername")
    local currentWorld = Mod.WorldShare.Store:Get('world/currentWorld')

    if not currentWorld then
        return false
    end

    local function Handle(data, err)
        if type(data) ~= "table" or #data == 0 then
            _guihelper.MessageBox(L"获取Commit列表失败")
            return false
        end

        local lastCommits = data[1]
        local lastCommitFile = lastCommits.title:gsub("paracraft commit: ", "")
        local lastCommitSha = lastCommits.id

        if (string.lower(lastCommitFile) ~= "revision.xml") then
            _guihelper.MessageBox(L"上一次同步到数据源同步失败，请重新同步世界到数据源")
            return false
        end

        local dataSourceInfo = Mod.WorldShare.Store:Get("user/dataSourceInfo")
        local localFiles = LocalService:LoadFiles(currentWorld.worldpath)

        self:SetCurrentCommidId(lastCommitSha)

        local filesTotals = currentWorld.size or 0

        local function HandleGetWorld(data)
            local oldWorldInfo = data or false

            if not oldWorldInfo then
                return false
            end

            local commitIds = {}

            if oldWorldInfo.extra and oldWorldInfo.extra.commitIds then
                commitIds = oldWorldInfo.extra.commitIds
            end

            commitIds[#commitIds + 1] = {
                commitId = lastCommitSha,
                revision = Mod.WorldShare.Store:Get("world/currentRevision"),
                date = os.date("%Y%m%d", os.time())
            }

            local worldInfo = {}
    
            worldInfo.worldName = foldername.utf8
            worldInfo.revision = Mod.WorldShare.Store:Get("world/currentRevision")
            worldInfo.fileSize = filesTotals
            worldInfo.commitId = lastCommitSha
            worldInfo.username = username
            worldInfo.archiveUrl =
                format(
                "%s/%s/%s/repository/archive.zip?ref=%s",
                dataSourceInfo.rawBaseUrl,
                dataSourceInfo.dataSourceUsername,
                foldername.base32,
                worldInfo.commitId
            )

            local preview = format(
                "%s/%s/%s/raw/master/preview.jpg?ref=%s",
                dataSourceInfo.rawBaseUrl,
                dataSourceInfo.dataSourceUsername,
                foldername.base32,
                worldInfo.commitId
            )

            worldInfo.extra = {
                coverUrl = preview,
                commitIds = commitIds
            }

            if currentWorld.local_tagname and currentWorld.local_tagname ~= foldername.utf8 then
                worldInfo.extra.worldTagName = currentWorld.local_tagname
            end

            WorldList.SetRefreshing(true)

            self:PushWorld(
                worldInfo,
                function(data, err)
                    if (err ~= 200) then
                        _guihelper.MessageBox(L"更新服务器列表失败")
                        return false
                    end
    
                    if type(callback) == 'function' then
                        callback()
                    end
                end
            )

            KeepworkServiceProject:GetProject(
                currentWorld.kpProjectId,
                function(data)
                    local extra = data and data.extra or {}

                    if Mod.WorldShare.Store:Get('world/isPreviewUpdated') and
                        currentWorld.local_tagname and
                        currentWorld.local_tagname ~= foldername.utf8 then

                        extra.imageUrl = preview
                        extra.worldTagName = currentWorld.local_tagname

                        KeepworkServiceProject:UpdateProject(
                            currentWorld.kpProjectId,
                            {
                                extra = extra
                            }
                        )
                    elseif Mod.WorldShare.Store:Get('world/isPreviewUpdated') then
                        extra.imageUrl = preview

                        KeepworkServiceProject:UpdateProject(
                            currentWorld.kpProjectId,
                            {
                                extra = extra
                            }
                        )
                    elseif currentWorld.local_tagname and
                           currentWorld.local_tagname ~= foldername.utf8 then
                        extra.worldTagName = currentWorld.local_tagname

                        KeepworkServiceProject:UpdateProject(
                            currentWorld.kpProjectId,
                            {
                                extra = extra
                            }
                        )
                    end

                    Mod.WorldShare.Store:Remove('world/isPreviewUpdated')
                end
            )
        end

        self:GetWorld(Encoding.url_encode(foldername.utf8 or ''), HandleGetWorld)
    end

    GitService:GetCommits(foldername.base32, false, Handle)
end

function KeepworkService:SetCurrentCommidId(commitId)
    local currentWorld = Mod.WorldShare.Store:Get("world/currentWorld")

    if not currentWorld or not currentWorld.worldpath then
        return false
    end

    local saveUrl = currentWorld.worldpath

    Mod.WorldShare:SetWorldData("revision", {id = commitId}, saveUrl)
    ParaIO.CreateDirectory(saveUrl)
    Mod.WorldShare:SaveWorldData(saveUrl)
end