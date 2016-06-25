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


local function onSendGameCenterNotificationBannerCallback( event )
    for k, v in pairs( event ) do
        print('[SceneMainMenu] onSendGameCenterNotificationBannerCallback k = ' .. tostring(k) .. '  v = ' .. tostring(v))
    end
    return true
end

local function onReleaseShowGameCenterSignInUI_Btn(e)
    print( "[SceneMainMenu] Show Game Center Sign In UI Button Released!!" )
    composerM.gameKit.show( "gameCenterSignInUI" )
    return true
end

local function onReleaseAchievementsMenuBtn(e)
    print( "[SceneMainMenu] Achievements Menu Button Released" )
    composerM.gotoScene('SceneAchievementsMenu', {effect = 'fade', time = 500})
    return true
end

local function onReleaseChallengesMenuBtn(e)
    print( "[SceneMainMenu] Challenges Menu Button Released" )
    composerM.gotoScene('SceneChallengesMenu', {effect = 'fade', time = 500})
    return true
end

local function onReleaseScoreLeaderboardMenuBtn(e)
    print( "[SceneMainMenu] Scores and Leaderboards Menu Button Released" )
    composerM.gotoScene('SceneScoreLeaderboardMenu', {effect = 'fade', time = 500})
    return true
end

local function onReleasePlayersMenuBtn(e)
    print( "[SceneMainMenu] Players Menu Button Released" )
    composerM.gotoScene('ScenePlayersMenu', {effect = 'fade', time = 500})
    return true
end

local function onReleaseRealTimeGameMenuBtn(e)
    print( "[SceneMainMenu] Real-Time Game Menu Button Released" )
    composerM.gotoScene('SceneRealTimeGameMenu', {effect = 'fade', time = 500})
    return true
end

local function onReleaseTurnBasedGameMenuBtn(e)
    print( "[SceneMainMenu] Turn-Based Game Menu Button Released" )
    composerM.gotoScene('SceneTurnBasedGameMenu', {effect = 'fade', time = 500})
    return true
end

local function onReleaseSendGameCenterNotificationBannerBtn(e)
    print( "[SceneScoreLeaderboardMenu] Send Game Center Notification Banner Button Released" )
    if( composerM.isGameCenterEnabled == true ) then
        composerM.gameKit.send( "gameCenterNotificationBanner", { title="Game Test Notification", 
        message="Yay, this is a game test notification!", duration=10.50, 
        listener=onSendGameCenterNotificationBannerCallback } )
    else
        print( "[SceneScoreLeaderboardMenu] Can not send because isGameCenterEnabled = false" )
    end
    return true
end


function scene:create(e)
    local sceneGroup = self.view
    
    local showGameCenterSignInUI_Btn = widget.newButton {
        label = "Show Game Center Sign In UI",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseShowGameCenterSignInUI_Btn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 2,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    showGameCenterSignInUI_Btn.x = composerM.contentCenterX
    showGameCenterSignInUI_Btn.y = 68
    sceneGroup:insert(showGameCenterSignInUI_Btn)
    
    local achievementsMenuBtn = widget.newButton {
        label = "Achievements Menu",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseAchievementsMenuBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 2,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    achievementsMenuBtn.x = composerM.contentCenterX
    achievementsMenuBtn.y = 164
    sceneGroup:insert(achievementsMenuBtn)
    
    local challengesMenuBtn = widget.newButton {
        label = "Challenges Menu",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseChallengesMenuBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 2,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    challengesMenuBtn.x = composerM.contentCenterX
    challengesMenuBtn.y = 260
    sceneGroup:insert(challengesMenuBtn)
    
    local scoreLeaderboardMenuBtn = widget.newButton {
        label = "Scores and Leaderboards Menu",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseScoreLeaderboardMenuBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 2,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    scoreLeaderboardMenuBtn.x = composerM.contentCenterX
    scoreLeaderboardMenuBtn.y = 356
    sceneGroup:insert(scoreLeaderboardMenuBtn)
    
    local playersMenuBtn = widget.newButton {
        label = "Players Menu",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleasePlayersMenuBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 2,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    playersMenuBtn.x = composerM.contentCenterX
    playersMenuBtn.y = 452
    sceneGroup:insert(playersMenuBtn)
    
    local realTimeGameMenuBtn = widget.newButton {
        label = "Real-Time Game Menu",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseRealTimeGameMenuBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 2,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    realTimeGameMenuBtn.x = composerM.contentCenterX
    realTimeGameMenuBtn.y = 548
    sceneGroup:insert(realTimeGameMenuBtn)
    
    local turnBasedGameMenuBtn = widget.newButton {
        label = "Turn-Based Game Menu",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseTurnBasedGameMenuBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 2,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    turnBasedGameMenuBtn.x = composerM.contentCenterX
    turnBasedGameMenuBtn.y = 644
    sceneGroup:insert(turnBasedGameMenuBtn)
    
    local sendGameCenterNotificationBannerBtn = widget.newButton {
        label = "Send GC Notification Banner",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseSendGameCenterNotificationBannerBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    sendGameCenterNotificationBannerBtn.x = composerM.contentCenterX
    sendGameCenterNotificationBannerBtn.y = 740
    sceneGroup:insert(sendGameCenterNotificationBannerBtn)
    
end

function scene:show(e)
    if(e.phase == 'will') then
        
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
    print('[SceneMainMenu] !!!!!!!!!!! destroy called !!!!!!!!!!!')
end

-- Scene Listener setup
scene:addEventListener('create', scene)
scene:addEventListener('show', scene)
scene:addEventListener('hide', scene)
scene:addEventListener('destroy', scene)

return scene