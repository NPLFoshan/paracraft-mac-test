--[[
Title: Keepwork Projects API
Author(s):  big
Date:  2019.11.8
Place: Foshan
use the lib:
------------------------------------------------------------
local KeepworkProjectsApi = NPL.load("(gl)Mod/WorldShare/api/Keepwork/Projects.lua")
------------------------------------------------------------
]]

local KeepworkBaseApi = NPL.load('./BaseApi.lua')
local GitEncoding = NPL.load("(gl)Mod/WorldShare/helper/GitEncoding.lua")

local KeepworkProjectsApi = NPL.export()

-- url: /projects
-- method: POST
-- params:
--[[
]]
-- return: object
function KeepworkProjectsApi:CreateProject(worldName, success, error)
    local url = '/projects'

    local params = {
        name = GitEncoding:Base32(worldName or ''),
        siteId = 1,
        visibility = 0,
        privilege = 165,
        type = 1,
        description = "no desc",
        tags = "paracraft",
        extra = {}
    }

    KeepworkBaseApi:Post(url, params, nil, success, error)
end

-- url: /projects/%d
-- method: PUT
-- params:
--[[
]]
-- return: object
function KeepworkProjectsApi:UpdateProject(pid, params, success, error)
    if type(pid) ~= 'number' or type(params) ~= 'table' then
        return false
    end

    local url = format("/projects/%d", pid)

    KeepworkBaseApi:Put(url, params, nil, success, error)
end

-- url: /projects/%d/detail
-- method: GET
-- params:
--[[
]]
-- return: object
function KeepworkProjectsApi:GetProject(pid, success, error, noTryStatus)
    if type(pid) ~= 'number' or pid == 0 then
        return false
    end

    local url = format("/projects/%d/detail", pid)

    KeepworkBaseApi:Get(url, nil, nil, success, error, noTryStatus)
end

-- url: /projects/%d/visit
-- method: GET
-- params:
--[[
]]
-- return: object
function KeepworkProjectsApi:Visit(pid, callback)
    if type(pid) ~= 'number' or pid == 0 then
        return false
    end

    local url = format("/projects/%d/visit", pid)

    KeepworkBaseApi:Get(url, nil, nil, callback)
end

-- url: /projects/searchForParacraft
-- method: POST
-- params:
--[[
    tagIds	integer [] 必须 标签的ID	
    item 类型: integer
    sortTag	integer	非必须 要排序的标签ID	
    projectId	integer	非必须 要搜索的项目ID
]]
-- return: object
function KeepworkProjectsApi:SearchForParacraft(xPerPage, xPage, params, success, error)
    local url = '/projects/searchForParacraft'

    if type(xPerPage) == 'number' then
        url = url .. '?x-per-page=' .. xPerPage

        if type(xPerPage) == 'number' then
            url = url .. '&x-page=' .. xPage
        end
    end

    KeepworkBaseApi:Post(url, params, nil, success, error)
end

-- url: /projects/%d
-- method: DELTE
-- return: object
function KeepworkProjectsApi:RemoveProject(kpProjectId, success, error)
    if type(kpProjectId) ~= 'number' then
        return false
    end

    local url = format("/projects/%d", kpProjectId)

    KeepworkBaseApi:Delete(url, nil, nil ,success, error)
end