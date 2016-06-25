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

local mockScore = 27
local currentChallenge = nil

local function printChallengeTable( tbl )
    for k, v in pairs( tbl ) do
        print('[SceneChallengeMenu] challenge  k = ' .. tostring(k) .. '  v = ' .. tostring(v))
    end
    return true
end

local function onChallengesGameCenterEvent(e)
    print( '[SceneChallengeMenu] onChallengesGameCenterEvent event.name = ' .. e.name )
    print( '[SceneChallengeMenu] onChallengesGameCenterEvent event.type = ' .. e.type )
    if(e.type == "error") then
        print( '[SceneChallengeMenu] onChallengesGameCenterEvent event.errorCode = ' .. e.errorCode )
        print( '[SceneChallengeMenu] onChallengesGameCenterEvent event.errorDescription = ' .. e.errorDescription )
    elseif(e.type == "success") then
        print( '[SceneChallengeMenu] onChallengesGameCenterEvent e.successDescription = ' .. e.successDescription )
    elseif(e.type == "challengeSent") then
        print( '[SceneChallengeMenu] onChallengesGameCenterEvent event.playersCount = ' .. tostring(e.playersCount) )
        for i = 1, e.playersCount do
            print('[SceneChallengeMenu] player ' .. tostring(i) .. ' playerID = ' .. e.players[i].playerID )
        end
    elseif(e.type == "challengeList") then
        print( '[SceneChallengeMenu] onChallengesGameCenterEvent event.challengesCount = ' .. tostring(e.challengesCount) )
        currentChallenge = e.challenges[1]
        for i = 1, e.challengesCount do
            print('[SceneChallengeMenu] challenge ' .. tostring(i) .. ' challengeType = ' 
            .. e.challenges[i].challengeType )
            print('[SceneChallengeMenu] challenge ' .. tostring(i) .. ' issueDate = ' 
            .. e.challenges[i].issueDate )
            print('[SceneChallengeMenu] challenge ' .. tostring(i) .. ' issuingPlayerID = ' 
            .. e.challenges[i].issuingPlayerID )
            print('[SceneChallengeMenu] challenge ' .. tostring(i) .. ' receivingPlayerID = ' 
            .. e.challenges[i].receivingPlayerID )
            print('[SceneChallengeMenu] challenge ' .. tostring(i) .. ' message = ' 
            .. e.challenges[i].message )
            print('[SceneChallengeMenu] challenge ' .. tostring(i) .. ' state = ' 
            .. tostring(e.challenges[i].state) )
            print('[SceneChallengeMenu] challenge ' .. tostring(i) .. ' completionDate = ' 
            .. e.challenges[i].completionDate )
        end
    elseif(e.type == "challengeAccepted") then
    	print( '[SceneChallengeMenu] onChallengesGameCenterEvent challengeAccepted')
    	printChallengeTable(e.challenge)
    elseif(e.type == "challengeReceived") then
    	print( '[SceneChallengeMenu] onChallengesGameCenterEvent challengeReceived')
    	printChallengeTable(e.challenge)
    elseif(e.type == "challengeCompleted") then
    	print( '[SceneChallengeMenu] onChallengesGameCenterEvent challengeCompleted')
    	printChallengeTable(e.challenge)
    elseif(e.type == "issuedChallengeCompleted") then
    	print( '[SceneChallengeMenu] onChallengesGameCenterEvent issuedChallengeCompleted')
    	printChallengeTable(e.challenge)
    end
end

local function onReleaseRegisterChallengesListenerBtn(e)
    print( "[SceneChallengeMenu] Register Challenges Listener Button Released" )
    if(composerM.isGameCenterEnabled == true) then
        composerM.gameKit.request( "registerChallengesListener", { listener=onChallengesGameCenterEvent } )
    else
        print( "[SceneChallengeMenu] Can not register because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseShowGameCenterChallengesUI_Btn(e)
    print( "[SceneChallengeMenu] Show Game Center Challenges UI Button Released" )
    if( composerM.isGameCenterEnabled == true ) then
        composerM.gameKit.show( "gameCenterChallengesUI" )
    else
        print( "[SceneChallengeMenu] Can not show because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseShowGameCenterAchievementChallengeUI_Btn(e)
    print( "[SceneChallengeMenu] Show Game Center Achievement Challenge UI Button Released" )
    if( composerM.isGameCenterEnabled == true ) then
    	if(composerM.friends ~= nil) then
            composerM.gameKit.show( "gameCenterAchievementChallengeUI", { achievementID=composerM.achievement40pointsID, 
            message="Think you can beat them apples?", playerIDs={ composerM.friends[1].playerID } } )
        else
            print( "[SceneChallengeMenu] Can not show because friends = nil" )
        end
    else
        print( "[SceneChallengeMenu] Can not show because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseGetGameCenterReceivedChallengesBtn(e)
    print( "[SceneChallengeMenu] Get Game Center Received Challenges Button Released" )
    if( composerM.isGameCenterEnabled == true ) then
        composerM.gameKit.get( "receivedChallenges" )
    else
        print( "[SceneChallengeMenu] Can not show because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseSendGameCenterAchievementForAchievementChallengeBtn(e)
    print( "[SceneChallengeMenu] Send Game Center Achievement For Achievement Challenge Button Released" )
    if( composerM.isGameCenterEnabled == true ) then
        print( "[SceneChallengeMenu] Send Game Center Achievement For AchievementChallenge Button Released" )
        composerM.gameKit.send( "achievementForAchievementChallenge", { achievementID=composerM.achievement40pointsID, 
        percentComplete=100.0, showsCompletionBanner=true }  )
    else
        print( "[SceneChallengeMenu] Can not send because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseShowGameCenterScoreChallengeUI_Btn(e)
    print( "[SceneChallengeMenu] Show Game Center Score Challenge UI Button Released" )
    if( composerM.isGameCenterEnabled == true ) then
    	if(composerM.friends ~= nil) then
            composerM.gameKit.show( "gameCenterScoreChallengeUI", { leaderboardID=composerM.defaultLeaderboardID,
            message="Think you can beat that?!", playerIDs={ composerM.friends[1].playerID } } )
         else
            print( "[SceneChallengeMenu] Can not show because friends = nil" )
         end
    else
        print( "[SceneChallengeMenu] Can not show because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseSendGameCenterScoreForScoreChallengeBtn(e)
    print( "[SceneChallengeMenu] Send Game Center Score For Score Challenge Button Released" )
    if( composerM.isGameCenterEnabled == true ) then
        if( mockScore ~= nil ) then
            composerM.gameKit.send( "scoreForScoreChallenge", { leaderboardID=composerM.defaultLeaderboardID, value=mockScore, 
            context=42 }  )
        end
    else
        print( "[SceneChallengeMenu] Can not send because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseDeclineGameCenterChallengeBtn(e)
    print( "[SceneChallengeMenu] Decline Game Center Challenge Button Released" )
    if( composerM.isGameCenterEnabled == true ) then
    	if( currentChallenge ~= nil ) then
            composerM.gameKit.request( "declineChallenge", { challengeType=currentChallenge.challengeType, 
            issueDate=currentChallenge.issueDate, issuingPlayerID=currentChallenge.issuingPlayerID }  )
        else
            print( "[SceneChallengeMenu] Can not show because currentChallenge = nil" )
        end
    else
        print( "[SceneChallengeMenu] Can not decline because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseBackBtn(e)
    print( "[SceneChallengeMenu] Back Button Released" )
    composerM.gotoScene('SceneMainMenu', {effect = 'fade', time = 500})
    return true
end

function scene:create(e)
    local sceneGroup = self.view
    
    local registerChallengesListenerBtn = widget.newButton {
        label = "Register Challenges Listener",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseRegisterChallengesListenerBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    registerChallengesListenerBtn.x = composerM.contentCenterX
    registerChallengesListenerBtn.y = 48
    sceneGroup:insert(registerChallengesListenerBtn)
    
    local showGameCenterChallengesUI_Btn = widget.newButton {
        label = "Show Game Center Challenges UI",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseShowGameCenterChallengesUI_Btn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    showGameCenterChallengesUI_Btn.x = composerM.contentCenterX
    showGameCenterChallengesUI_Btn.y = 124
    sceneGroup:insert(showGameCenterChallengesUI_Btn)
    
    local showGameCenterAchievementChallengeUI_Btn = widget.newButton {
        label = "Show GC Achievement Challenge UI",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseShowGameCenterAchievementChallengeUI_Btn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    showGameCenterAchievementChallengeUI_Btn.x = composerM.contentCenterX
    showGameCenterAchievementChallengeUI_Btn.y = 200
    sceneGroup:insert(showGameCenterAchievementChallengeUI_Btn)
    
    local getGameCenterReceivedChallengesBtn = widget.newButton {
        label = "Get GC Received Challenges",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseGetGameCenterReceivedChallengesBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    getGameCenterReceivedChallengesBtn.x = composerM.contentCenterX
    getGameCenterReceivedChallengesBtn.y = 276
    sceneGroup:insert(getGameCenterReceivedChallengesBtn)
    
    local sendGameCenterAchievementForAchievementChallengeBtn = widget.newButton {
        label = "Send GC Achievement for Challenge",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseSendGameCenterAchievementForAchievementChallengeBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    sendGameCenterAchievementForAchievementChallengeBtn.x = composerM.contentCenterX
    sendGameCenterAchievementForAchievementChallengeBtn.y = 352
    sceneGroup:insert(sendGameCenterAchievementForAchievementChallengeBtn)
    
    local showGameCenterScoreChallengeUI_Btn = widget.newButton {
        label = "Show GC Score Challenge UI",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseShowGameCenterScoreChallengeUI_Btn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    showGameCenterScoreChallengeUI_Btn.x = composerM.contentCenterX
    showGameCenterScoreChallengeUI_Btn.y = 428
    sceneGroup:insert(showGameCenterScoreChallengeUI_Btn)
    
    local sendGameCenterScoreForScoreChallengeBtn = widget.newButton {
        label = "Send GC Score for Challenge",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseSendGameCenterScoreForScoreChallengeBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    sendGameCenterScoreForScoreChallengeBtn.x = composerM.contentCenterX
    sendGameCenterScoreForScoreChallengeBtn.y = 504
    sceneGroup:insert(sendGameCenterScoreForScoreChallengeBtn)
    
    local declineGameCenterChallengeBtn = widget.newButton {
        label = "Decline Game Center Challenge",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseDeclineGameCenterChallengeBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    declineGameCenterChallengeBtn.x = composerM.contentCenterX
    declineGameCenterChallengeBtn.y = 580
    sceneGroup:insert(declineGameCenterChallengeBtn)
    
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
    	
    elseif (e.phase == 'did' ) then
        -- Called immediately after scene goes off screen.
    end
end

function scene:destroy(e)
    print('[SceneChallengeMenu] !!!!!!!!!!! destroy called !!!!!!!!!!!')
end

-- Scene Listener setup
scene:addEventListener('create', scene)
scene:addEventListener('show', scene)
scene:addEventListener('hide', scene)
scene:addEventListener('destroy', scene)

return scene