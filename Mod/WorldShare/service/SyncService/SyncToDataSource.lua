--[[
Title: SyncToDataSource
Author(s):  big
Date:  2018.6.20
Desc: 
use the lib:
------------------------------------------------------------
local SyncToDataSource = NPL.load("(gl)Mod/WorldShare/cellar/Sync/SyncToDataSource.lua")
------------------------------------------------------------
]]
local Progress = NPL.load("(gl)Mod/WorldShare/cellar/Sync/Progress/Progress.lua")
local GitService = NPL.load("(gl)Mod/WorldShare/service/GitService.lua")
local LocalService = NPL.load("(gl)Mod/WorldShare/service/LocalService.lua")
local KeepworkService = NPL.load("(gl)Mod/WorldShare/service/KeepworkService.lua")
local KeepworkServiceProject = NPL.load("(gl)Mod/WorldShare/service/KeepworkService/Project.lua")
local WorldList = NPL.load("(gl)Mod/WorldShare/cellar/UserConsole/WorldList.lua")
local KeepworkGen = NPL.load("(gl)Mod/WorldShare/helper/KeepworkGen.lua")

local SyncToDataSource = NPL.export()

local UPDATE = "UPDATE"
local UPLOAD = "UPLOAD"
local DELETE = "DELETE"

function SyncToDataSource:Init(callback)
    if type(callback) ~= 'function' then
        return false
    end

    self.foldername = Mod.WorldShare.Store:Get("world/foldername")

    local currentWorld = Mod.WorldShare.Store:Get('world/currentWorld')
    self.currentWorld = currentWorld

    self.callback = callback

    if not self.currentWorld.worldpath or self.currentWorld.worldpath == "" then
        callback(false, L"上传失败，将使用离线模式，原因：上传目录为空")
        return false
    end

    -- 加载进度UI界面
    -- // TODO: move to UI file
    Progress:Init(self)

    self:SetFinish(false)
    self:SetBroke(false)

    self:IsProjectExist(
        function(beExisted)
            if beExisted then
                -- update world
                KeepworkServiceProject:GetProjectIdByWorldName(self.currentWorld.foldername, function()
                    currentWorld = Mod.WorldShare.Store:Get('world/currentWorld') 

                    if currentWorld and currentWorld.kpProjectId then
                        local tag = LocalService:GetTag(currentWorld.worldpath)

                        if type(tag) == 'table' then
                            tag.kpProjectId = currentWorld.kpProjectId
                            LocalService:SetTag(currentWorld.worldpath, tag)
                        end
                    end

                    self:Start()
                end)
            else
                KeepworkServiceProject:CreateProject(
                    self.currentWorld.foldername,
                    function(data, err)
                        if err ~= 200 or not data or not data.id then
                            callback(false, L"创建仓库失败，请确认可分享世界的数量")
                            Progress:ClosePage()
                            return false
                        end

                        currentWorld.kpProjectId = data.id

                        if currentWorld and currentWorld.kpProjectId then
                            local tag = LocalService:GetTag(currentWorld.worldpath)

                            if type(tag) == 'table' then
                                tag.kpProjectId = currentWorld.kpProjectId

                                LocalService:SetTag(currentWorld.worldpath, tag)
                            end
                        end

                        Mod.WorldShare.Store:Set("world/currentWorld", currentWorld)
                        self:Start()
                    end
                )
            end
        end
    )
end

function SyncToDataSource:IsProjectExist(callback)
    KeepworkServiceProject:GetProjectByWorldName(
        self.currentWorld.foldername,
        function(data)
            if type(callback) ~= "function" then
                return false
            end

            if type(data) == 'table' then
                callback(true)
            else
                callback(false)
            end
        end
    )
end

function SyncToDataSource:Start()
    self.compareListIndex = 1
    self.compareListTotal = 0

    Progress:UpdateDataBar(0, 0, L"正在对比文件列表...")

    local function Handle(data, err)
        if type(data) ~= 'table' then
            return false
        end

        self.dataSourceFiles = data
        self.localFiles = commonlib.vector:new()
        self.localFiles:AddAll(LocalService:LoadFiles(self.currentWorld.worldpath)) --再次获取本地文件，保证上传的内容为最新

        self:IgnoreFiles()
        self:CheckReadmeFile()
        self:GetCompareList()
        self:HandleCompareList()
    end

    GitService:GetTree(self.currentWorld.foldername, nil, Handle)
end

function SyncToDataSource:IgnoreFiles()
    local fileList = { "mod/" }

    for LKey, LItem in ipairs(self.localFiles) do
        for FKey, FItem in ipairs(fileList) do
            if string.find(LItem.filename, FItem) then
                self.localFiles:remove(LKey)
            end
        end
    end
end

function SyncToDataSource:CheckReadmeFile()
    if not self.localFiles then
        return false
    end

    local hasReadme = false

    for key, value in ipairs(self.localFiles) do
        if string.upper(value.filename) == "README.MD" then
            if (value.filename == "README.md") then
                hasReadme = true
            else
                LocalService:Delete(self.foldername.default, value.filename)
                hasReadme = false
            end
        end
    end

    if not hasReadme then
        local filePath = format("%s/README.md", self.currentWorld.worldpath)
        local file = ParaIO.open(filePath, "w")
        local content = KeepworkGen:GetReadmeFile()

        file:write(content, #content)
        file:close()

        local readMeFiles = {
            filename = "README.md",
            file_path = filePath,
            file_content_t = content
        }

        self.localFiles:push_back(readMeFiles)
    end
end

function SyncToDataSource:GetCompareList()
    self.compareList = commonlib.vector:new()

    for LKey, LItem in ipairs(self.localFiles) do
        local bIsExisted = false

        for IKey, IItem in ipairs(self.dataSourceFiles) do
            if LItem.filename == IItem.path then
                bIsExisted = true
                break
            end
        end

        local currentItem = {
            file = LItem.filename,
            status = bIsExisted and UPDATE or UPLOAD
        }

        self.compareList:push_back(currentItem)
    end

    for IKey, IItem in ipairs(self.dataSourceFiles) do
        local bIsExisted = false

        for LKey, LItem in ipairs(self.localFiles) do
            if IItem.path == LItem.filename then
                bIsExisted = true
                break
            end
        end

        if not bIsExisted then
            local currentItem = {
                file = IItem.path,
                status = DELETE
            }

            self.compareList:push_back(currentItem)
        end
    end

    -- handle revision in last
    for CKey, CItem in ipairs(self.compareList) do
        if string.lower(CItem.file) == "revision.xml" then
            self.compareList:push_back(CItem)
            self.compareList:remove(CKey)
        end
    end

    self.compareListTotal = #self.compareList
end

function SyncToDataSource:RefreshList()
    KeepworkService:UpdateRecord(
        function()
            Progress:SetFinish(true)
            Progress:Refresh()

            Mod.WorldShare.Store:Set(
                "world/CloseProgress",
                function()
                    if type(self.callback) == 'function' then
                        self.callback(true, nil, function(noRefresh)
                            if not noRefresh then
                                WorldList:RefreshCurrentServerList()
                            end
                        end)
                        self.callback = nil

                        return false
                    end

                    WorldList:RefreshCurrentServerList()
                end
            )
        end
    )
end

function SyncToDataSource:HandleCompareList()
    if self.compareListTotal < self.compareListIndex then
        -- sync finish
        self:SetFinish(true)

        self:RefreshList()

        self.compareListIndex = 1
        return false
    end

    if self.broke then
        self:SetFinish(true)
        LOG.std("SyncToDataSource", "debug", "SyncToDataSource", "上传被中断")
        return false
    end

    local currentItem = self.compareList[self.compareListIndex]

    local function Retry()
        Progress:UpdateDataBar(
            self.compareListIndex,
            self.compareListTotal,
            format(L"%s 处理完成", currentItem.file),
            self.finish
        )

        self.compareListIndex = self.compareListIndex + 1
        self:HandleCompareList()
    end

    if currentItem.status == UPDATE then
        self:UpdateOne(currentItem.file, Retry)
    end

    if currentItem.status == UPLOAD then
        self:UploadOne(currentItem.file, Retry)
    end

    if currentItem.status == DELETE then
        self:DeleteOne(currentItem.file, Retry)
    end
end

function SyncToDataSource:GetLocalFileByFilename(filename)
    for key, item in ipairs(self.localFiles) do
        if item.filename == filename then
            return item
        end
    end
end

function SyncToDataSource:GetRemoteFileByPath(path)
    for key, item in ipairs(self.dataSourceFiles) do
        if item.path == path then
            return item
        end
    end
end

function SyncToDataSource:SetBroke(value)
    self.broke = value
end

function SyncToDataSource:SetFinish(value)
    self.finish = value
end

-- 上传新文件
function SyncToDataSource:UploadOne(file, callback)
    local currentLocalItem = self:GetLocalFileByFilename(file)

    -- These line give a feedback on update record method
    if string.lower(currentLocalItem.filename) == 'preview.jpg' then
        Mod.WorldShare.Store:Set('world/isPreviewUpdated', true)
    end

    Progress:UpdateDataBar(
        self.compareListIndex,
        self.compareListTotal,
        format(L"%s （%s） 上传中", currentLocalItem.filename, Mod.WorldShare.Utils.FormatFileSize(currentLocalItem.filesize, "KB"))
    )

    GitService:Upload(
        self.currentWorld.foldername,
        currentLocalItem.filename,
        currentLocalItem.file_content_t,
        function(bIsUpload)
            if bIsUpload then
                if type(callback) == "function" then
                    callback()
                end
            else
                self.callback(false, format(L"%s上传失败", currentLocalItem.filename))
                self:SetBroke(true)

                Progress:UpdateDataBar(
                    self.compareListIndex,
                    self.compareListTotal,
                    format(L"%s 上传失败", currentLocalItem.filename)
                )
            end
        end
    )
end

-- 更新数据源文件
function SyncToDataSource:UpdateOne(file, callback)
    local currentLocalItem = self:GetLocalFileByFilename(file)
    local currentRemoteItem = self:GetRemoteFileByPath(file)

    Progress:UpdateDataBar(
        self.compareListIndex,
        self.compareListTotal,
        format(L"%s （%s） 对比中", currentLocalItem.filename, Mod.WorldShare.Utils.FormatFileSize(currentLocalItem.filesize, "KB"))
    )

    -- These line give a feedback on update record method
    if string.lower(currentLocalItem.filename) == 'preview.jpg' then
        if currentLocalItem.sha1 == currentRemoteItem.id then
            Mod.WorldShare.Store:Set('world/isPreviewUpdated', false)
        else
            Mod.WorldShare.Store:Set('world/isPreviewUpdated', true)
        end
    end

    if currentLocalItem.sha1 == currentRemoteItem.id and string.lower(currentLocalItem.filename) ~= "revision.xml" then
        if type(callback) == "function" then
            Progress:UpdateDataBar(
                self.compareListIndex,
                self.compareListTotal,
                format(L"%s （%s） 文件一致，跳过", currentLocalItem.filename, Mod.WorldShare.Utils.FormatFileSize(currentLocalItem.filesize, "KB"))
            )

            Mod.WorldShare.Utils.SetTimeOut(callback)
        end

        return false
    end

    Progress:UpdateDataBar(
        self.compareListIndex,
        self.compareListTotal,
        format(L"%s （%s） 更新中", currentLocalItem.filename, Mod.WorldShare.Utils.FormatFileSize(currentLocalItem.filesize, "KB"))
    )

    GitService:Update(
        self.currentWorld.foldername,
        currentLocalItem.filename,
        currentLocalItem.file_content_t,
        function(bIsUpdate)
            if bIsUpdate then
                if type(callback) == "function" then
                    callback()
                end
            else
                self.callback(false, L"更新失败")
                self:SetBroke(true)

                Progress:UpdateDataBar(
                    self.compareListIndex,
                    self.compareListTotal,
                    format(L"%s 更新失败", currentLocalItem.filename)
                )
            end
        end
    )
end

-- 删除数据源文件
function SyncToDataSource:DeleteOne(file, callback)
    local currentRemoteItem = self:GetRemoteFileByPath(file)

    -- These line give a feedback on update record method
    if string.lower(currentRemoteItem.name) == 'preview.jpg' then
        Mod.WorldShare.Store:Set('world/isPreviewUpdated', false)
    end

    Progress:UpdateDataBar(
        self.compareListIndex,
        self.compareListTotal,
        format(L"%s 删除中", currentRemoteItem.path)
    )

    GitService:DeleteFile(
        self.currentWorld.foldername,
        currentRemoteItem.path,
        function(bIsDelete)
            if (bIsDelete) then
                if (type(callback) == "function") then
                    callback()
                end
            else
                self.callback(false, L"删除失败")
                self:SetBroke(true)

                Progress:UpdateDataBar(
                    self.compareListIndex,
                    self.compareListTotal,
                    format(L"%s 删除失败", currentRemoteItem.name)
                )
            end
        end
    )
end
