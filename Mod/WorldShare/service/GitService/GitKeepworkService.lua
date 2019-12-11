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

local GitKeepworkService = NPL.export()

function GitKeepworkService:Create(projectName, callback)
    
end

function GitKeepworkService:GetContent(projectName, path, commitId, callback)
    
end

function GitKeepworkService:GetContentWithRaw(foldername, path, commitId, callback)
    
end

function GitKeepworkService:Upload(projectName, path, content, callback)
    
end

function GitKeepworkService:Update(projectName, path, content, sha, callback)
    
end

function GitKeepworkService:DeleteFile(projectName, path, sha, callback)
    
end

function GitKeepworkService:DownloadZIP(foldername, commitId, callback)
    
end

function GitKeepworkService:GetTree(projectName, commitId, callback)
    
end

function GitKeepworkService:GetCommits(projectName, isGetAll, callback, commits, pageSize, commitPage)
    
end

function GitKeepworkService:GetWorldRevision(projectId, isGetMine, callback)
    
end

function GitKeepworkService:GetProjectIdByName(name, callback)
    
end

function GitKeepworkService:DeleteResp(foldername, authToken, callback)
    
end