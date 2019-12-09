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
local WorldShare = commonlib.gettable("Mod.WorldShare")
local Encoding = commonlib.gettable("commonlib.Encoding")

local HttpRequest = NPL.load("./HttpRequest.lua")
local GitService = NPL.load("./GitService.lua")
local GitGatewayService = NPL.load("./GitGatewayService.lua")
local LocalService = NPL.load("./LocalService.lua")
local Store = NPL.load("(gl)Mod/WorldShare/store/Store.lua")
local Utils = NPL.load("(gl)Mod/WorldShare/helper/Utils.lua")
local UserConsole = NPL.load("(gl)Mod/WorldShare/cellar/UserConsole/Main.lua")
local WorldList = NPL.load("(gl)Mod/WorldShare/cellar/UserConsole/WorldList.lua")
local Config = NPL.load("(gl)Mod/WorldShare/config/Config.lua")
local KeepworkUsersApi = NPL.load("(gl)Mod/WorldShare/api/Keepwork/Users.lua")

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

function KeepworkService:GetApi(url)
    if type(url) ~= "string" then
        return ""
    end

    return format("%s%s", self:GetCoreApi(), url)
end

function KeepworkService:GetHeaders(selfDefined, notTokenRequest)
    local headers = {}

    if type(selfDefined) == "table" then
        headers = selfDefined
    end

    local token = Mod.WorldShare.Store:Get("user/token")

    if (token and not notTokenRequest and not headers["Authorization"]) then
        headers["Authorization"] = format("Bearer %s", token)
    end

    return headers
end

function KeepworkService:Request(url, method, params, headers, callback, noTryStatus)
    local params = {
        method = method or "GET",
        url = self:GetApi(url),
        json = true,
        headers = headers or {},
        form = params or {}
    }

    HttpRequest:GetUrl(params, callback, noTryStatus)
end

function KeepworkService:IsSignedIn()
    local token = Mod.WorldShare.Store:Get("user/token")

    return token ~= nil
end

function KeepworkService:GetToken()
    local token = Mod.WorldShare.Store:Get('user/token')

    return token or ''
end

-- This api will create a keepwork paracraft project and associated with paracraft world.
function KeepworkService:CreateProject(worldName, callback)
    if not self:IsSignedIn() or not worldName then
        return false
    end

    local headers = self:GetHeaders()

    local params = {
        name = worldName,
        siteId = 1,
        visibility = 0,
        privilege = 165,
        type = 1,
        description = "no desc",
        tags = "paracraft",
        extra = {}
    }

    self:Request("/projects", "POST", params, headers, callback)
end

function KeepworkService:UpdateProject(pid, params, callback)
    if not self:IsSignedIn() or
       not pid or
       type(pid) ~= 'number' or
       type(params) ~= 'table' then
        return false
    end

    local headers = self:GetHeaders()

    self:Request(format("/projects/%d", pid), "PUT", params, headers, callback)
end

function KeepworkService:GetProject(pid, callback, noTryStatus)
    if type(pid) ~= 'number' or pid == 0 then
        return false
    end

    local headers = self:GetHeaders()

    self:Request(
        format("/projects/%d/detail", pid),
        "GET",
        nil,
        headers,
        function(data, err)
            if type(callback) ~= 'function' then
                return false
            end

            if err ~= 200 or not data or not data.world then
                callback()
                return false
            end

            callback(data, err)
        end,
        noTryStatus
    )
end

function KeepworkService:GetWorldsList(callback)
    if (not self:IsSignedIn()) then
        return false
    end

    local headers = self:GetHeaders()

    self:Request("/worlds", 'GET', {}, headers, callback)
end

function KeepworkService:GetProjectIdByWorldName(worldName, callback)
    if not self:IsSignedIn() then
        return false
    end

    local headers = self:GetHeaders()

    self:Request(
        format("/worlds?worldName=%s", Encoding.url_encode(worldName or '')),
        'GET',
        nil,
        headers,
        function(data)
            if not data or #data ~= 1 or type(data[1]) ~= 'table' or not data[1].projectId then
                if type(callback) == 'function' then
                    callback()
                end

                return false
            end

            local currentWorld = Mod.WorldShare.Store:Get('world/currentWorld')
            currentWorld.kpProjectId = data[1].projectId
            Mod.WorldShare.Store:Set('world/currentWorld', currentWorld)

            if type(callback) == 'function' then
                callback(data[1].projectId)
            end
        end
    )
end

function KeepworkService:GetWorldByProjectId(pid, callback)
    if type(pid) ~= 'number' or pid == 0 then
        return false
    end

    local headers = self:GetHeaders()

    self:Request(
        format("/projects/%d/detail", pid),
        "GET",
        nil,
        headers,
        function(data, err)
            if type(callback) ~= 'function' then
                return false
            end

            if err ~= 200 or not data or not data.world then
                callback(nil, err)
                return false
            end

            callback(data.world, err)
        end
    )
end

function KeepworkService:GetWorld(worldName, callback)
    if (type(worldName) ~= 'string' or not self:IsSignedIn()) then
        return false
    end

    local headers = self:GetHeaders()

    self:Request(
        format("/worlds?worldName=%s", worldName or ''),
        "GET",
        nil,
        headers,
        function(data, err)
            if type(callback) ~= 'function' then
                return false
            end

            if err ~= 200 or #data == 0 then
                return false
            end

            callback(data[1])
        end
    )
end

function KeepworkService:PushWorld(params, callback)
    if type(params) ~= 'table' or not self:IsSignedIn() then
        return false
    end

    local headers = self:GetHeaders()

    self:GetWorld(
        Encoding.url_encode(params.worldName or ''),
        function(world)
            local worldId = world and world.id or false

            if not worldId then
                return false
            end

            self:Request(
                format("/worlds/%s", worldId),
                "PUT",
                params,
                headers,
                callback
            )
        end
    )
end

function KeepworkService:DeleteWorld(kpProjectId, callback)
    if not kpProjectId then
        return false
    end

    if not self:IsSignedIn() then
        return false
    end

    local url = format("/projects/%d", kpProjectId)
    local headers = self:GetHeaders()

    self:Request(url, "DELETE", {}, headers, callback)
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

        Mod.WorldShare.Store:Set("world/localFiles", localFiles)

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

            self:GetProject(
                currentWorld.kpProjectId,
                function(data)
                    local extra = data and data.extra or {}

                    if Mod.WorldShare.Store:Get('world/isPreviewUpdated') and
                        currentWorld.local_tagname and
                        currentWorld.local_tagname ~= foldername.utf8 then

                        extra.imageUrl = preview
                        extra.worldTagName = currentWorld.local_tagname

                        self:UpdateProject(
                            currentWorld.kpProjectId,
                            {
                                extra = extra
                            }
                        )
                    elseif Mod.WorldShare.Store:Get('world/isPreviewUpdated') then
                        extra.imageUrl = preview

                        self:UpdateProject(
                            currentWorld.kpProjectId,
                            {
                                extra = extra
                            }
                        )
                    elseif currentWorld.local_tagname and
                           currentWorld.local_tagname ~= foldername.utf8 then
                        extra.worldTagName = currentWorld.local_tagname

                        self:UpdateProject(
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

    WorldShare:SetWorldData("revision", {id = commitId}, saveUrl)
    ParaIO.CreateDirectory(saveUrl)
    WorldShare:SaveWorldData(saveUrl)
end