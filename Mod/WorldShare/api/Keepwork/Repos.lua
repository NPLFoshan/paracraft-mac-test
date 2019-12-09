--[[
Title: Keepwork Repos API
Author(s):  big
Date:  2019.11.8
Place: Foshan
use the lib:
------------------------------------------------------------
local KeepworkReposApi = NPL.load("(gl)Mod/WorldShare/api/Keepwork/Repos.lua")
------------------------------------------------------------
]]

local KeepworkReposApi = NPL.export()

-- url: /repos/:repoPath/download
-- method: GET
-- params:
--[[
    repoPath string 必须 仓库路径	
    ref string 必须 commid
]]
-- return: object
function KeepworkReposApi:Download()
end

-- url: /repos/:repoPath/tree
-- method: GET
-- params:
--[[
    repoPath string 必须 仓库路径	
    ref string 必须 commid
]]
-- return: object
function KeepworkReposApi:Tree()
end

-- url: /repos/:repoPath/files/:filePath/info
-- method: GET
-- params:
--[[
    repoPath string 必须 仓库路径	
    filePath string 必须 文件路径
]]
-- return: object
function KeepworkReposApi:Info()
end

-- url: /repos/:repoPath/files/:filePath/raw
-- method: GET
-- params:
--[[
    repoPath string 必须 仓库路径	
    filePath string 必须 文件路径
]]
-- return: object
function KeepworkReposApi:Raw()
end

-- url: /repos/:repoPath/files/:filePath/history
-- method: GET
-- params:
--[[
    repoPath string 必须 仓库路径	
    filePath string 必须 文件路径
]]
-- return: object
function KeepworkReposApi:History()
end

-- url: /repos/:repoPath/files/:filePath
-- method: GET
-- params:
--[[
    repoPath string 必须 仓库路径	
    filePath string 必须 文件路径
]]
-- return: object
function KeepworkReposApi:UpdateFile()
end

-- url: /repos/:repoPath/files/:filePath
-- method: POST
-- params:
--[[
    repoPath string 必须 仓库路径	
    filePath string 必须 文件路径
]]
-- return: object
function KeepworkReposApi:CreateFile()
end

-- url: /repos/:repoPath/files/:filePath
-- method: DELETE
-- params:
--[[
    repoPath string 必须 仓库路径	
    filePath string 必须 文件路径
]]
-- return: object
function KeepworkReposApi:RemoveFile()
end

-- url: /repos/:repoPath/files/:filePath
-- method: DELETE
-- params:
--[[
    repoPath string 必须 仓库路径	
    filePath string 必须 文件路径
]]
-- return: object
function KeepworkReposApi:MoveFile()
end

-- url: /repos/:repoPath/folders/:folderPath
-- method: POST
-- params:
--[[
    repoPath string 必须 仓库路径	
    filePath string 必须 文件路径
]]
-- return: object
function KeepworkReposApi:NewFolder()
end

-- url: /repos/:repoPath/folders/:folderPath
-- method: DELETE
-- params:
--[[
    repoPath string 必须 仓库路径	
    filePath string 必须 文件路径
]]
-- return: object
function KeepworkReposApi:RemoveFolder()
end

-- url: /repos/:repoPath/folders/:folderPath/rename
-- method: POST 
-- params:
--[[
    repoPath string 必须 仓库路径	
    filePath string 必须 文件路径
]]
-- return: object
function KeepworkReposApi:MoveFolder()
end