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

local inputTxtField = nil
local leaderboardImage = nil

local function onCallback( event )
    for k, v in pairs( event ) do
        print('[SceneScoreLeaderboardMenu] onCallback k = ' .. tostring(k) .. '  v = ' .. tostring(v))
    end
    return true
end

local function onGameCenterLeaderboardsCallback(e)
    print( '[SceneScoreLeaderboardMenu] onGameCenterLeaderboardsCallback event.name = ' .. e.name )
    print( '[SceneScoreLeaderboardMenu] onGameCenterLeaderboardsCallback event.type = ' .. e.type )
    if(e.type == "error") then
        print( '[SceneScoreLeaderboardMenu] onGameCenterLeaderboardsCallback event.errorCode = ' .. e.errorCode )
        print( '[SceneScoreLeaderboardMenu] onGameCenterLeaderboardsCallback event.errorDescription = ' .. e.errorDescription )
    elseif(e.type == "leaderboardList") then
        print( '[SceneScoreLeaderboardMenu] onGameCenterLeaderboardsCallback event.leaderboardsCount = ' .. tostring(e.leaderboardsCount) )
        for i = 1, e.leaderboardsCount do
            print('[SceneScoreLeaderboardMenu] leaderboard ' .. tostring(i) .. ' title = ' .. e.leaderboards[i].title )
            print('[SceneScoreLeaderboardMenu] leaderboard ' .. tostring(i) .. ' leaderboardID = ' .. e.leaderboards[i].leaderboardID )
            print('[SceneScoreLeaderboardMenu] leaderboard ' .. tostring(i) .. ' groupIdentifier = ' .. e.leaderboards[i].groupIdentifier )
        end
    elseif(e.type == "leaderboardSetList") then
        print( '[SceneScoreLeaderboardMenu] onGameCenterLeaderboardsCallback event.leaderboardSetsCount = ' .. tostring(e.leaderboardSetsCount) )
        for i = 1, e.leaderboardSetsCount do
            print('[SceneScoreLeaderboardMenu] leaderboardSet ' .. tostring(i) .. ' title = ' .. e.leaderboardSets[i].title )
            print('[SceneScoreLeaderboardMenu] leaderboardSet ' .. tostring(i) .. ' leaderboardID = ' .. e.leaderboardSets[i].leaderboardID )
            print('[SceneScoreLeaderboardMenu] leaderboardSet ' .. tostring(i) .. ' groupIdentifier = ' .. e.leaderboardSets[i].groupIdentifier )
        end
    end
end

local function onGameCenterLeaderboardImageCallback(e)
    print( '[SceneScoreLeaderboardMenu] onGameCenterLeaderboardImageCallback e.name = ' .. e.name )
    print( '[SceneScoreLeaderboardMenu] onGameCenterLeaderboardImageCallback e.type = ' .. e.type )
    if(e.type == "error") then
        print( '[SceneScoreLeaderboardMenu] onGameCenterLeaderboardImageCallback e.errorCode = ' .. e.errorCode )
        print( '[SceneScoreLeaderboardMenu] onGameCenterLeaderboardImageCallback e.errorDescription = ' .. 
        e.errorDescription )
    elseif(e.type == "leaderboardImage") then
    print('[SceneScoreLeaderboardMenu] leaderboardID = ' .. e.leaderboardID )
    	leaderboardImage = e.image
    	leaderboardImage.x = composerM.contentCenterX
    	leaderboardImage.y = 600
    	scene.view:insert(leaderboardImage)
    end
end

local function onGameCenterScoresCallback(e)
    print( '[SceneScoreLeaderboardMenu] onGameCenterScoresCallback e.name = ' .. e.name )
    print( '[SceneScoreLeaderboardMenu] onGameCenterScoresCallback e.type = ' .. e.type )
    if(e.type == "error") then
        print( '[SceneScoreLeaderboardMenu] onGameCenterScoresCallback e.errorCode = ' .. e.errorCode )
        print( '[SceneScoreLeaderboardMenu] onGameCenterScoresCallback e.errorDescription = ' .. 
        e.errorDescription )
    elseif(e.type == "scoreList") then
    	print( '[SceneScoreLeaderboardMenu] onGameCenterScoresCallback event.scoresCount = ' .. tostring(e.scoresCount) )
        for i = 1, e.scoresCount do
            print('[SceneScoreLeaderboardMenu] score ' .. tostring(i) .. ' playerID = ' .. e.scores[i].playerID )
            print('[SceneScoreLeaderboardMenu] score ' .. tostring(i) .. ' leaderboardID = ' .. e.scores[i].leaderboardID )
            print('[SceneScoreLeaderboardMenu] score ' .. tostring(i) .. ' rank = ' .. tostring(e.scores[i].rank) )
            print('[SceneScoreLeaderboardMenu] score ' .. tostring(i) .. ' formattedValue = ' .. e.scores[i].formattedValue )
            print('[SceneScoreLeaderboardMenu] score ' .. tostring(i) .. ' value = ' .. tostring(e.scores[i].value) )
            print('[SceneScoreLeaderboardMenu] score ' .. tostring(i) .. ' context = ' .. tostring(e.scores[i].context) )
            print('[SceneScoreLeaderboardMenu] score ' .. tostring(i) .. ' date = ' .. e.scores[i].date )
        end
    end
end

local function onReleaseShowGameCenterLeaderboardsUI_Btn(e)
    print( "[SceneScoreLeaderboardMenu] Show Game Center Leaderboards Button Released" )
    if( composerM.isGameCenterEnabled == true ) then
        composerM.gameKit.show( "gameCenterLeaderboardsUI", { leaderboardID=composerM.defaultLeaderboardID } )
    else
        print( "[SceneAchieveChallengeMenu] Can not show because isGameCenterEnabled = false" )
    end
    return true
end

local function onUserInputTxtField(e)
	if ( e.phase == "began" ) then
        native.setKeyboardFocus( e.target )
        --print( "[SceneScoreLeaderboardMenu] Input Text = began" )
    end
    return true
end

local function onReleaseCancelTextInputBtn(e)
    print( "[SceneScoreLeaderboardMenu] Cancel Text Input Button Released" )
    native.setKeyboardFocus(nil)
    inputTxtField.text = ""
    return true
end

local function onReleaseSendGameCenterScoreBtn(e)
    print( "[SceneScoreLeaderboardMenu] Send Game Center Score Button Released" )
    native.setKeyboardFocus(nil)
    local score = tonumber( inputTxtField.text )
    print( "[SceneScoreLeaderboardMenu] score = " .. tostring(score) )
    if( composerM.isGameCenterEnabled == true ) then
        if( score ~= nil ) then
            composerM.gameKit.send( "score", { leaderboardID=composerM.defaultLeaderboardID, value=score, context=42, 
            listener=onCallback }  )
        end
    else
        print( "[SceneScoreLeaderboardMenu] Can not send because isGameCenterEnabled = false" )
    end
    inputTxtField.text = ""
    return true
end

local function onReleaseGetGameCenterLeaderboardsBtn(e)
    print( "[SceneScoreLeaderboardMenu] Get Game Center Leaderboards Button Released" )
    if( composerM.isGameCenterEnabled == true ) then
        composerM.gameKit.get( "leaderboards", { listener=onGameCenterLeaderboardsCallback }  )
    else
        print( "[SceneScoreLeaderboardMenu] Can not get because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseGetGameCenterLeaderboardSetsBtn(e)
    print( "[SceneScoreLeaderboardMenu] Get Game Center Leaderboard Sets Button Released" )
    if( composerM.isGameCenterEnabled == true ) then
        composerM.gameKit.get( "leaderboardSets", { listener=onGameCenterLeaderboardsCallback }  )
    else
        print( "[SceneScoreLeaderboardMenu] Can not get because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseGetGameCenterDefaultLeaderboardIDBtn(e)
    print( "[SceneScoreLeaderboardMenu] Get Game Center Default LeaderboardID Button Released" )
    if( composerM.isGameCenterEnabled == true ) then
        composerM.gameKit.get( "defaultLeaderboardID", { listener=onCallback }  )
    else
        print( "[SceneScoreLeaderboardMenu] Can not get because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseSetGameCenterDefaultLeaderboardIDBtn(e)
    print( "[SceneScoreLeaderboardMenu] Set Game Center Default LeaderboardID Button Released" )
    if( composerM.isGameCenterEnabled == true ) then
        --composerM.gameKit.request( "setDefaultLeaderboardID", { leaderboardID=composerM.secondLeaderboardID, 
--        listener=onCallback }  )
	composerM.gameKit.request( "setDefaultLeaderboardID", { leaderboardID=composerM.defaultLeaderboardID, 
        listener=onCallback }  )
    else
        print( "[SceneScoreLeaderboardMenu] Can not set because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseGetGameCenterLeaderboardImageBtn(e)
    print( "[SceneScoreLeaderboardMenu] Get Game Center Leaderboard Image Button Released" )
    if( composerM.isGameCenterEnabled == true ) then
		composerM.gameKit.get( "leaderboardImage", { leaderboardID=composerM.secondLeaderboardID, 
        listener=onGameCenterLeaderboardImageCallback }  )
    else
        print( "[SceneScoreLeaderboardMenu] Can not get because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseGetGameCenterScoresBtn(e)
    print( "[SceneScoreLeaderboardMenu] Get Game Center Scores Button Released" )
    if( composerM.isGameCenterEnabled == true ) then
    -- playerScope = "Global" or "FriendsOnly"  |    timeScope = "Today" or "Week" or "AllTime"
	composerM.gameKit.get( "scores", { leaderboardID=composerM.defaultLeaderboardID, playerScope="Global", 
	timeScope="AllTime", range={1,5}, listener=onGameCenterScoresCallback }  )
    else
        print( "[SceneScoreLeaderboardMenu] Can not get because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseGetGameCenterScoresWithPlayersBtn(e)
    print( "[SceneScoreLeaderboardMenu] Get Game Center Scores With Players Button Released" )
    if( composerM.isGameCenterEnabled == true ) then
    	if(composerM.friends ~= nil) then
            composerM.gameKit.get( "scoresWithPlayers", { leaderboardID=composerM.defaultLeaderboardID, 
            playerIDs={composerM.localPlayerID, composerM.friends[1].playerID}, timeScope="AllTime", 
            listener=onGameCenterScoresCallback }  )
        else
                print( "[SceneScoreLeaderboardMenu] Can not get because friends = nil" )
        end
    else
        print( "[SceneScoreLeaderboardMenu] Can not get because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseBackBtn(e)
    print( "[SceneScoreLeaderboardMenu] Back Button Released" )
    composerM.gotoScene('SceneMainMenu', {effect = 'fade', time = 500})
    return true
end

function scene:create(e)
    local sceneGroup = self.view
    
    local showGameCenterLeaderboardsUI_Btn = widget.newButton {
        label = "Show Game Center Leaderboards UI",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseShowGameCenterLeaderboardsUI_Btn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    showGameCenterLeaderboardsUI_Btn.x = composerM.contentCenterX
    showGameCenterLeaderboardsUI_Btn.y = 48
    sceneGroup:insert(showGameCenterLeaderboardsUI_Btn)
    
    local textBg = display.newRoundedRect( composerM.contentCenterX, 124, 600, 56, 12 )
    textBg.strokeWidth = 3
    textBg:setFillColor( 1, 1, 1 )
    textBg:setStrokeColor( 0.8, 0.8, 0.8 )
    sceneGroup:insert(textBg)
    
    local cancelTextInputBtn = widget.newButton {
        label = "Cancel Text Input",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseCancelTextInputBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 2,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    cancelTextInputBtn.x = composerM.contentCenterX
    cancelTextInputBtn.y = 200
    sceneGroup:insert(cancelTextInputBtn)
    
    local sendGameCenterScoreBtn = widget.newButton {
        label = "Send Game Center Score",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseSendGameCenterScoreBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    sendGameCenterScoreBtn.x = composerM.contentCenterX
    sendGameCenterScoreBtn.y = 276
    sceneGroup:insert(sendGameCenterScoreBtn)
    
    local getGameCenterLeaderboardsBtn = widget.newButton {
        label = "Get Game Center Leaderboards",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseGetGameCenterLeaderboardsBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    getGameCenterLeaderboardsBtn.x = composerM.contentCenterX
    getGameCenterLeaderboardsBtn.y = 352
    sceneGroup:insert(getGameCenterLeaderboardsBtn)
    
    local getGameCenterLeaderboardSetsBtn = widget.newButton {
        label = "Get Game Center Leaderboard Sets",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseGetGameCenterLeaderboardSetsBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    getGameCenterLeaderboardSetsBtn.x = composerM.contentCenterX
    getGameCenterLeaderboardSetsBtn.y = 428
    sceneGroup:insert(getGameCenterLeaderboardSetsBtn)
    
    local getGameCenterDefaultLeaderboardID_Btn = widget.newButton {
        label = "Get GC Default LeaderboardID",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseGetGameCenterDefaultLeaderboardIDBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    getGameCenterDefaultLeaderboardID_Btn.x = composerM.contentCenterX
    getGameCenterDefaultLeaderboardID_Btn.y = 504
    sceneGroup:insert(getGameCenterDefaultLeaderboardID_Btn)
    
    local setGameCenterDefaultLeaderboardID_Btn = widget.newButton {
        label = "Set GC Default LeaderboardID",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseSetGameCenterDefaultLeaderboardIDBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    setGameCenterDefaultLeaderboardID_Btn.x = composerM.contentCenterX
    setGameCenterDefaultLeaderboardID_Btn.y = 580
    sceneGroup:insert(setGameCenterDefaultLeaderboardID_Btn)
    
    local getGameCenterLeaderboardImageBtn = widget.newButton {
        label = "Get Game Center Leaderboard Image",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseGetGameCenterLeaderboardImageBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    getGameCenterLeaderboardImageBtn.x = composerM.contentCenterX
    getGameCenterLeaderboardImageBtn.y = 656
    sceneGroup:insert(getGameCenterLeaderboardImageBtn)
    
    local getGameCenterScoresBtn = widget.newButton {
        label = "Get Game Center Scores",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseGetGameCenterScoresBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    getGameCenterScoresBtn.x = composerM.contentCenterX
    getGameCenterScoresBtn.y = 732
    sceneGroup:insert(getGameCenterScoresBtn)
    
    local getGameCenterScoresWithPlayersBtn = widget.newButton {
        label = "Get GC Scores With Players",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseGetGameCenterScoresWithPlayersBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    getGameCenterScoresWithPlayersBtn.x = composerM.contentCenterX
    getGameCenterScoresWithPlayersBtn.y = 808
    sceneGroup:insert(getGameCenterScoresWithPlayersBtn)
    
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
        inputTxtField = native.newTextField( composerM.contentCenterX, 124, 580, 56 )
        inputTxtField.font = native.newFont(native.systemFont, 30)
        inputTxtField:setTextColor(0, 0, 0)
        inputTxtField.align = 'left'
        inputTxtField.hasBackground = false
        inputTxtField.placeholder = "Input mock score data"
        inputTxtField:addEventListener( "userInput", onUserInputTxtField )
    end
end

function scene:hide(e)
    if (e.phase == 'will') then
    	inputTxtField:removeEventListener( "userInput", onUserInputTxtField )
        inputTxtField:removeSelf()
        inputTxtField = nil
        if(leaderboardImage ~= nil) then
       		leaderboardImage:removeSelf()
       		leaderboardImage = nil
       end
    elseif (e.phase == 'did' ) then
        -- Called immediately after scene goes off screen.
    end
end

function scene:destroy(e)
    print('[SceneScoreLeaderboardMenu] !!!!!!!!!!! destroy called !!!!!!!!!!!')
end

-- Scene Listener setup
scene:addEventListener('create', scene)
scene:addEventListener('show', scene)
scene:addEventListener('hide', scene)
scene:addEventListener('destroy', scene)

return scene