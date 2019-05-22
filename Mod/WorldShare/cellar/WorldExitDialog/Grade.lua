--[[
Title: Grade
Author(s):  big
Date: 2019.01.16
place: Foshan
Desc: 
use the lib:
------------------------------------------------------------
local Grade = NPL.load("(gl)Mod/WorldShare/cellar/WorldExitDialog/Grade.lua")
------------------------------------------------------------
]]

local TeacherAgent = commonlib.gettable("MyCompany.Aries.Creator.Game.Teacher.TeacherAgent")
local WorldCommon = commonlib.gettable("MyCompany.Aries.Creator.WorldCommon")

local LoginModal = NPL.load("(gl)Mod/WorldShare/cellar/LoginModal/LoginModal.lua")
local Utils = NPL.load('(gl)Mod/WorldShare/helper/Utils.lua')
local Store = NPL.load("(gl)Mod/WorldShare/store/Store.lua")
local KeepworkServiceRate = NPL.load("(gl)Mod/WorldShare/service/KeepworkService/Rate.lua")
local KeepworkServiceProject = NPL.load("(gl)Mod/WorldShare/service/KeepworkService/Project.lua")
local GradeLocalData = NPL.load("(gl)Mod/WorldShare/database/GradeLocalData.lua")

local Grade = NPL.export()

Grade.score = 0
Grade.starTable = {{selected = false}, {selected = false}, {selected = false}, {selected = false}, {selected = false}}

function Grade:Init()
    Grade.score = 0
    Grade.starTable = {{selected = false}, {selected = false}, {selected = false}, {selected = false}, {selected = false}}
end

function Grade:UpdateScore(score, callback)
    local username = Store:Get('user/username')

    if not KeepworkServiceProject:GetProjectId() then
        return false
    end

    if not username then
        return false
    end

    if not score or score == 0 then
        return false
    end

    local rate = score * 20

    KeepworkServiceRate:SetRatedProject(
        KeepworkServiceProject:GetProjectId(),
        rate,
        function(data, err)
            if err == 200 then
                -- GradeLocalData:RecordProjectId(KeepworkServiceProject:GetProjectId(), username)
            end
        end
    )

    self:ClosePage()
end

function Grade:GetScoreFromKeepwork(callback)
    KeepworkServiceRate:GetRatedProject(
        KeepworkServiceProject:GetProjectId(),
        function(data, err)
            echo(data, true)
        end
    )
end

function Grade:GetScoreTable()
    return self.starTable
end