--[[
Title: GitlabService
Author(s):  big
Date:  2019.12.10
Desc: 
use the lib:
------------------------------------------------------------
local GitKeepworkService = NPL.load("(gl)Mod/WorldShare/service/GitKeepworkService.lua")
------------------------------------------------------------
]]

local KeepworkReposApi = NPL.load("(gl)Mod/WorldShare/api/Keepwork/Repos.lua")
local KeepworkProjectsApi = NPL.load("(gl)Mod/WorldShare/api/Keepwork/Projects.lua")

local GitKeepworkService = NPL.export()

function GitKeepworkService:Create(foldername, callback)
    
end

function GitKeepworkService:GetContent(foldername, path, commitId, callback)
    
end

function GitKeepworkService:GetContentWithRaw(foldername, path, commitId, callback)
    
end

function GitKeepworkService:Upload(foldername, path, content, callback)
    KeepworkReposApi:CreateFile(
        foldername,
        path,
        content,
        function()
            if type(callback) == 'function' then
                callback(true)
            end
        end,
        function()
            if type(callback) == 'function' then
                callback(false)
            end
        end
    )
end

function GitKeepworkService:Update(foldername, path, content, callback)
    KeepworkReposApi:UpdateFile(
        foldername,
        path,
        content,
        function()
            if type(callback) == 'function' then
                callback(true)
            end
        end,
        function()
            if type(callback) == 'function' then
                callback(false)
            end
        end
    )
end

function GitKeepworkService:DeleteFile(foldername, path, sha, callback)
    
end

function GitKeepworkService:DownloadZIP(foldername, commitId, callback)
    
end

function GitKeepworkService:GetTree(foldername, commitId, callback)
    KeepworkReposApi:Tree(foldername, commitId, callback)
end

function GitKeepworkService:GetCommits(foldername, isGetAll, callback, commits, pageSize, commitPage)
    
end

function GitKeepworkService:GetWorldRevision(kpProjectId, isGetMine, callback)
    KeepworkProjectsApi:GetProject(
        kpProjectId,
        function(data, err)
            if isGetMine then
                if type(data) ~= 'table' or not data.id or tonumber(data.id) ~= tonumber(kpProjectId) then
                    if type(callback) == 'function' then
                        callback()
                    end
                    return false
                end
            end

            if type(data) ~= 'table' or not data.name or not data.world then
                return false
            end

            KeepworkReposApi:Raw(
                data.name, 'revision.xml', data.world.commitId,
                function(data, err)
                    if type(callback) == 'function' then
                        callback(tonumber(data) or 0, err)
                    end
                end,
                function()
                    if type(callback) == 'function' then
                        callback(0, err)
                    end
                end)
        end
    )
end

function GitKeepworkService:GetProjectIdByName(name, callback)
    
end

function GitKeepworkService:DeleteResp(foldername, authToken, callback)
    
end