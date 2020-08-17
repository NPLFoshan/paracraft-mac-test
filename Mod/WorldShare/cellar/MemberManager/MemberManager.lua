--[[
Title: Member Manager
Author: big  
Date: 2020.8.17
place: Foshan
Desc: 
use the lib:
------------------------------------------------------------
local MemberManager = NPL.load("(gl)Mod/WorldShare/cellar/MemberManager/MemberManager.lua")
------------------------------------------------------------
]]

--- service
local KeepworkServiceProject = NPL.load("(gl)Mod/WorldShare/service/KeepworkService/Project.lua")

local MemberManager = NPL.export()

MemberManager.memberList = {}
MemberManager.applyList = {}
MemberManager.sel = 1

function MemberManager:Show()
    Mod.WorldShare.Utils.ShowWindow(500, 320, "(ws)MemberManager", "Mod.WorldShare.MemberManager")

    self:GetApplyList()
    self:GetMembers()
end

function MemberManager:ShowApply()
    Mod.WorldShare.Utils.ShowWindow(400, 260, "(ws)MemberManager/Apply.html", "Mod.WorldShare.MemberManager.Apply")
end

function MemberManager:GetApplyList()
    local currentWorld = Mod.WorldShare.Store:Get("world/currentWorld")

    if not currentWorld or not currentWorld.kpProjectId then
        return false
    end
    
    KeepworkServiceProject:GetApplyList(currentWorld.kpProjectId, function(data, err)
        if type(data) ~= 'table' then
            return false
        end

        local applyList = {}

        for key, item in ipairs(data) do
            if item and item.object and item.object.username and item.state and item.state == 0 then
                applyList[#applyList + 1] = {
                    username = item.object.username,
                    message = item.legend or "",
                    date = os.date("%Y/%m/%d", Mod.WorldShare.Utils:UnifiedTimestampFormat(item.updatedAt or "")),
                    id = item.id
                }
            end
        end

        self.applyList = applyList

        local MemberManagerPage = Mod.WorldShare.Store:Get('page/Mod.WorldShare.MemberManager')

        if MemberManagerPage then
            MemberManagerPage:Rebuild()
        end
    end)
end

function MemberManager:GetMembers()
    local currentWorld = Mod.WorldShare.Store:Get("world/currentWorld")

    if not currentWorld or not currentWorld.kpProjectId then
        return false
    end

    KeepworkServiceProject:GetMembers(currentWorld.kpProjectId, function(data, err)
        if type(data) ~= 'table' then
            return false
        end

        local memberList = {}
        local username = Mod.WorldShare.Store:Get("user/username")

        for key, item in ipairs(data) do
            if username ~= item.username then
                memberList[#memberList + 1] = {
                    username = item.username,
                    id = item.id,
                    date = os.date("%Y/%m/%d", Mod.WorldShare.Utils:UnifiedTimestampFormat(item.createdAt or "")),
                }
            end
        end

        self.memberList = memberList

        local MemberManagerPage = Mod.WorldShare.Store:Get('page/Mod.WorldShare.MemberManager')

        if MemberManagerPage then
            MemberManagerPage:Rebuild()
        end
    end)
end

function MemberManager:HandleApply(id, isAllow)
    KeepworkServiceProject:HandleApply(id, isAllow, function(data, err)
        GameLogic.AddBBS(nil, L"操作成功", 3000, "0 255 0")

        self:GetApplyList()
    end)
end

function MemberManager:RemoveUser(id)
    KeepworkServiceProject:RemoveUserFromMember(id, function(data, err)
        GameLogic.AddBBS(nil, L"删除成功", 3000, "0 255 0")

        self:GetMembers()
    end)
end
