--[[
Title: GitService
Author(s):  big
Date:  2018.6.20
Place: Foshan
use the lib:
------------------------------------------------------------
local GitService = NPL.load("(gl)Mod/WorldShare/service/GitService.lua")
------------------------------------------------------------
]]

local GitKeepworkService = NPL.load("./GitService/GitKeepworkService.lua")

local GitService = NPL.export()

local KEEPWORK = "KEEPWORK"

function GitService:GetDataSourceInfo()
    return Mod.WorldShare.Store:Get("user/dataSourceInfo")
end

function GitService:GetDataSourceType()
    return KEEPWORK
end

function GitService:GetSingleProject(...)
    if self:GetDataSourceType() == KEEPWORK then

    end
end

function GitService:Create(...)
    if self:GetDataSourceType() == KEEPWORK then

    end
end

function GitService:GetContent(...)
    if self:GetDataSourceType() == KEEPWORK then

    end
end

function GitService:GetContentWithRaw(...)
    if self:GetDataSourceType() == KEEPWORK then

    end
end

function GitService:Upload(...)
    if self:GetDataSourceType() == KEEPWORK then

    end
end

function GitService:Update(projectName, path, content, sha, callback)
    if self:GetDataSourceType() == KEEPWORK then

    end
end

function GitService:DeleteFile(projectName, path, sha, callback)
    if self:GetDataSourceType() == KEEPWORK then

    end
end

function GitService:DownloadZIP(...)
    if self:GetDataSourceType() == KEEPWORK then

    end
end

function GitService:GetTree(...)
    if self:GetDataSourceType() == KEEPWORK then

    end
end

function GitService:GetCommits(...)
    if self:GetDataSourceType() == KEEPWORK then

    end
end

function GitService:GetWorldRevision(...)
    if self:GetDataSourceType() == KEEPWORK then

    end
end

function GitService:GetProjectIdByName(...)
    if self:GetDataSourceType() == KEEPWORK then

    end
end

function GitService:DeleteResp(...)
    if self:GetDataSourceType() == KEEPWORK then

    end
end