--[[
 The MIT License (MIT)
 
 Copyright (c) 2016 Warren Fuller, animonger.com
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ]]

local composerM = require('composer')
local scene = composerM.newScene()
local widget = require( "widget" )

local achievementImage = nil

local function onCallback(e)
    for k, v in pairs( e ) do
        print('[SceneAchieveChallengeMenu] onCallback k = ' .. tostring(k) .. '  v = ' .. tostring(v))
    end
    return true
end

local function onGameCenterAchievementProgressCallback(e)
    print( '[SceneAchieveChallengeMenu] onGameCenterAchievementProgressCallback e.name = ' .. e.name )
    print( '[SceneAchieveChallengeMenu] onGameCenterAchievementProgressCallback e.type = ' .. e.type )
    if(e.type == "error") then
        print( '[SceneAchieveChallengeMenu] onGameCenterAchievementProgressCallback e.errorCode = ' .. e.errorCode )
        print( '[SceneAchieveChallengeMenu] onGameCenterAchievementProgressCallback e.errorDescription = ' .. 
        e.errorDescription )
    elseif(e.type == "achievementProgress") then
        print( '[SceneAchieveChallengeMenu] onGameCenterAchievementProgressCallback e.achievementsCount = ' .. 
        tostring(e.achievementsCount) )
        for i = 1, e.achievementsCount do
            print('[SceneAchieveChallengeMenu] achievement ' .. tostring(i) .. ' playerID = ' .. 
            e.achievements[i].playerID )
            print('[SceneAchieveChallengeMenu] achievement ' .. tostring(i) .. ' achievementID = ' .. 
            e.achievements[i].achievementID )
            print('[SceneAchieveChallengeMenu] achievement ' .. tostring(i) .. ' isCompleted = ' .. 
            tostring(e.achievements[i].isCompleted) )
            print('[SceneAchieveChallengeMenu] achievement ' .. tostring(i) .. ' percentComplete = ' .. 
            tostring(e.achievements[i].percentComplete) )
            print('[SceneAchieveChallengeMenu] achievement ' .. tostring(i) .. ' showsCompletionBanner = ' .. 
            tostring(e.achievements[i].showsCompletionBanner) )
            print('[SceneAchieveChallengeMenu] achievement ' .. tostring(i) .. ' lastReportedDate = ' .. 
            e.achievements[i].lastReportedDate )
        end
    end
    return true
end

local function onGameCenterAchievementDescriptionsCallback(e)
    print( '[SceneAchieveChallengeMenu] onGameCenterAchievementDescriptionsCallback e.name = ' .. e.name )
    print( '[SceneAchieveChallengeMenu] onGameCenterAchievementDescriptionsCallback e.type = ' .. e.type )
    if(e.type == "error") then
        print( '[SceneAchieveChallengeMenu] onGameCenterAchievementDescriptionsCallback e.errorCode = ' .. e.errorCode )
        print( '[SceneAchieveChallengeMenu] onGameCenterAchievementDescriptionsCallback e.errorDescription = ' .. 
        e.errorDescription )
    elseif(e.type == "achievementDescriptions") then
        print( '[SceneAchieveChallengeMenu] onGameCenterAchievementDescriptionsCallback e.descriptionsCount = ' .. 
        tostring(e.descriptionsCount) )
        for i = 1, e.descriptionsCount do
            print('[SceneAchieveChallengeMenu] description ' .. tostring(i) .. ' title = ' .. e.descriptions[i].title )
            print('[SceneAchieveChallengeMenu] description ' .. tostring(i) .. ' achievementID = ' .. 
            e.descriptions[i].achievementID )
            print('[SceneAchieveChallengeMenu] description ' .. tostring(i) .. ' groupIdentifier = ' .. 
            e.descriptions[i].groupIdentifier )
            print('[SceneAchieveChallengeMenu] description ' .. tostring(i) .. ' unachievedDescription = ' .. 
            e.descriptions[i].unachievedDescription )
            print('[SceneAchieveChallengeMenu] description ' .. tostring(i) .. ' achievedDescription = ' .. 
            e.descriptions[i].achievedDescription )
            print('[SceneAchieveChallengeMenu] description ' .. tostring(i) .. ' maximumPoints = ' .. 
            tostring(e.descriptions[i].maximumPoints) )
            print('[SceneAchieveChallengeMenu] description ' .. tostring(i) .. ' isHidden = ' .. 
            tostring(e.descriptions[i].isHidden) )
            print('[SceneAchieveChallengeMenu] description ' .. tostring(i) .. ' isReplayable = ' .. 
            tostring(e.descriptions[i].isReplayable) )
        end
    end
    return true
end

local function onGameCenterAchievementImageCallback(e)
    print( '[SceneAchieveChallengeMenu] onGameCenterAchievementImageCallback e.name = ' .. e.name )
    print( '[SceneAchieveChallengeMenu] onGameCenterAchievementImageCallback e.type = ' .. e.type )
    if(e.type == "error") then
        print( '[SceneAchieveChallengeMenu] onGameCenterAchievementImageCallback e.errorCode = ' .. e.errorCode )
        print( '[SceneAchieveChallengeMenu] onGameCenterAchievementImageCallback e.errorDescription = ' .. 
        e.errorDescription )
    elseif(e.type == "achievementImage") then
    print('[SceneAchieveChallengeMenu] achievementID = ' .. e.achievementID )
    	achievementImage = e.image
    	achievementImage.x = composerM.contentCenterX
    	achievementImage.y = 600
    	scene.view:insert(achievementImage)
    end
    return true
end

local function onReleaseShowGameCenterAchievementsUI_Btn(e)
    print( "[SceneAchieveChallengeMenu] Show Game Center Achievements UI Button Released" )
    if( composerM.isGameCenterEnabled == true ) then
        composerM.gameKit.show( "gameCenterAchievementsUI" )
    else
        print( "[SceneAchieveChallengeMenu] Can not show because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseGetGameCenterAchievementProgressBtn(e)
    print( "[SceneAchieveChallengeMenu] Get Game Center Achievement Progress Button Released" )
    if( composerM.isGameCenterEnabled == true ) then
        composerM.gameKit.get( "achievementProgress", { listener=onGameCenterAchievementProgressCallback } )
    else
        print( "[SceneAchieveChallengeMenu] Can not get because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseGetGameCenterAchievementDescriptionsBtn(e)
    print( "[SceneAchieveChallengeMenu] Get Game Center Achievement Descriptions Button Released" )
    if( composerM.isGameCenterEnabled == true ) then
        composerM.gameKit.get( "achievementDescriptions", { listener=onGameCenterAchievementDescriptionsCallback } )
    else
        print( "[SceneAchieveChallengeMenu] Can not get because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseGetGameCenterAchievementImageBtn(e)
    print( "[SceneAchieveChallengeMenu] Get Game Center Achievement Image Button Released" )
    if( composerM.isGameCenterEnabled == true ) then
        --composerM.gameKit.get( "achievementImage", { achievementID=composerM.achievement40pointsID, 
--        listener=onGameCenterAchievementImageCallback } )
        composerM.gameKit.get( "achievementImage", { achievementID=composerM.achievement60pointsID, 
        listener=onGameCenterAchievementImageCallback } )
    else
        print( "[SceneAchieveChallengeMenu] Can not get because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseSendGameCenter40PointsAchievementProgressBtn(e)
    print( "[SceneAchieveChallengeMenu] Send Game Center 40 Points Achievement Progress Button Released" )
    if( composerM.isGameCenterEnabled == true ) then
        composerM.gameKit.send( "achievementProgress", { achievementID=composerM.achievement40pointsID, percentComplete=100.0, 
        showsCompletionBanner=true, listener=onCallback }  )
    else
        print( "[SceneAchieveChallengeMenu] Can not send because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseSendGameCenter60PointsAchievementProgressBtn(e)
    print( "[SceneAchieveChallengeMenu] Send Game Center 60 Points Achievement Progress Button Released" )
    if( composerM.isGameCenterEnabled == true ) then
        composerM.gameKit.send( "achievementProgress", { achievementID=composerM.achievement60pointsID, percentComplete=100.0, 
        showsCompletionBanner=true, listener=onCallback }  )
    else
        print( "[SceneAchieveChallengeMenu] Can not send because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseResetGameCenterAchievementsBtn(e)
    print( "[SceneAchieveChallengeMenu] Reset Game Center Achievements Button Released" )
    if( composerM.isGameCenterEnabled == true ) then
        composerM.gameKit.request( "resetAchievements", { listener=onCallback } )
    else
        print( "[SceneAchieveChallengeMenu] Can not reset because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseBackBtn(e)
    print( "[SceneAchieveChallengeMenu] Back Button Released" )
    composerM.gotoScene('SceneMainMenu', {effect = 'fade', time = 500})
    return true
end

function scene:create(e)
    local sceneGroup = self.view
    
    local showGameCenterAchievementsUI_Btn = widget.newButton {
        label = "Show Game Center Achievements UI",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseShowGameCenterAchievementsUI_Btn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    showGameCenterAchievementsUI_Btn.x = composerM.contentCenterX
    showGameCenterAchievementsUI_Btn.y = 48
    sceneGroup:insert(showGameCenterAchievementsUI_Btn)
    
    local getGameCenterAchievementProgress = widget.newButton {
        label = "Get GC Achievement Progress",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseGetGameCenterAchievementProgressBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    getGameCenterAchievementProgress.x = composerM.contentCenterX
    getGameCenterAchievementProgress.y = 124
    sceneGroup:insert(getGameCenterAchievementProgress)
    
    local getGameCenterAchievementDescriptions = widget.newButton {
        label = "Get GC Achievement Descriptions",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseGetGameCenterAchievementDescriptionsBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    getGameCenterAchievementDescriptions.x = composerM.contentCenterX
    getGameCenterAchievementDescriptions.y = 200
    sceneGroup:insert(getGameCenterAchievementDescriptions)
    
    local getGameCenterAchievementImage = widget.newButton {
        label = "Get GC Achievement Image",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseGetGameCenterAchievementImageBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    getGameCenterAchievementImage.x = composerM.contentCenterX
    getGameCenterAchievementImage.y = 276
    sceneGroup:insert(getGameCenterAchievementImage)
    
    local sendGameCenter40PointAchievementProgressBtn = widget.newButton {
        label = "Send GC 40P Achievement Progress",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseSendGameCenter40PointsAchievementProgressBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    sendGameCenter40PointAchievementProgressBtn.x = composerM.contentCenterX
    sendGameCenter40PointAchievementProgressBtn.y = 352
    sceneGroup:insert(sendGameCenter40PointAchievementProgressBtn)
    
    local sendGameCenter60PointAchievementProgressBtn = widget.newButton {
        label = "Send GC 60P Achievement Progress",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseSendGameCenter60PointsAchievementProgressBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    sendGameCenter60PointAchievementProgressBtn.x = composerM.contentCenterX
    sendGameCenter60PointAchievementProgressBtn.y = 428
    sceneGroup:insert(sendGameCenter60PointAchievementProgressBtn)
    
    local resetGameCenterAchievementsBtn = widget.newButton {
        label = "Reset Game Center Achievements",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseResetGameCenterAchievementsBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    resetGameCenterAchievementsBtn.x = composerM.contentCenterX
    resetGameCenterAchievementsBtn.y = 504
    sceneGroup:insert(resetGameCenterAchievementsBtn)
    
    local backBtn = widget.newButton {
        label = "<  Back",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseBackBtn,
        shape="roundedRect",
        width = 160,
        height = 56,
        cornerRadius = 2,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    backBtn.x = 100
    backBtn.y = 912
    sceneGroup:insert(backBtn)
    
end

function scene:show(e)
    if(e.phase == 'will') then
        -- Called when the scene is still off screen but is about to come on screen.
        -- Populate text fields, etc.
    elseif(e.phase == 'did') then
        -- Called when the scene is now on screen.
        -- Insert code here to make the scene come alive.
        -- Example: start listeners, start timers, begin animation, play audio, etc.
    end
end

function scene:hide(e)
    if (e.phase == 'will') then
    	if(achievementImage ~= nil) then
       		achievementImage:removeSelf()
       		achievementImage = nil
       end
    elseif (e.phase == 'did' ) then
        -- Called immediately after scene goes off screen.
    end
end

function scene:destroy(e)
    print('[SceneAchieveChallengeMenu] !!!!!!!!!!! destroy called !!!!!!!!!!!')
end

-- Scene Listener setup
scene:addEventListener('create', scene)
scene:addEventListener('show', scene)
scene:addEventListener('hide', scene)
scene:addEventListener('destroy', scene)

return scene