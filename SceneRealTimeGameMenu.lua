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

local function onRealTimeMatchmakerGameCenterEvent(e)
    print( '[SceneRealTimeGameMenu] onRealTimeMatchmakerGameCenterEvent event.name = ' .. e.name )
    print( '[SceneRealTimeGameMenu] onRealTimeMatchmakerGameCenterEvent event.type = ' .. e.type )
    if(e.type == "error") then
        print( '[SceneRealTimeGameMenu] onRealTimeMatchmakerGameCenterEvent event.errorCode = ' .. e.errorCode )
        print( '[SceneRealTimeGameMenu] onRealTimeMatchmakerGameCenterEvent event.errorDescription = ' .. e.errorDescription )
    elseif(e.type == "success") then
        print( '[SceneRealTimeGameMenu] onRealTimeMatchmakerGameCenterEvent event.successDescription = ' .. e.successDescription )
    elseif(e.type == "playerAddedToMatch") then
    	print( '[SceneRealTimeGameMenu] onRealTimeMatchmakerGameCenterEvent added to match e.playerID = ' .. e.playerID )
    	print( '[SceneRealTimeGameMenu] onRealTimeMatchmakerGameCenterEvent match e.remotePlayerCount = ' .. tostring(e.remotePlayerCount) )
    elseif(e.type == "nearbyPlayerFound") then
    	print('[SceneRealTimeGameMenu] event.playerID = ' .. e.playerID )
    elseif(e.type == "matchStarted") then
    	composerM.currentRealTimeMatchPlayers = e.players
        print( '[SceneRealTimeGameMenu] onRealTimeMatchmakerGameCenterEvent event.playersCount = ' .. tostring(e.playersCount) )
        for i = 1, e.playersCount do
            print('[SceneRealTimeGameMenu] player ' .. tostring(i) .. ' playerID = ' .. e.players[i].playerID )
            print('[SceneRealTimeGameMenu] player ' .. tostring(i) .. ' displayName = ' .. e.players[i].displayName )
            print('[SceneRealTimeGameMenu] player ' .. tostring(i) .. ' isFriend = ' .. tostring(e.players[i].isFriend) )
        end
        composerM.gotoScene('SceneRealTimeGame', {effect = 'fade', time = 500})
        -- call registerRealTimeListener in game scene
    elseif(e.type == "inviteeResponse") then
    	print('[SceneRealTimeGameMenu] event.playerID = ' .. e.playerID )
    	print('[SceneRealTimeGameMenu] event.response = ' .. tostring(e.response) )
    elseif(e.type == "acceptedInvite") then
--        composerM.gameKit.show( "gameCenterRealTimeMatchWithInviteUI" )
	composerM.gameKit.request( "realTimeMatchForInvite" )
    elseif(e.type == "matchmakingActivity") then
    	print('[SceneRealTimeGameMenu] event.numberOfPlayers = ' .. tostring(e.numberOfPlayers) )
    end
end

local function onReleaseRegisterRealTimeMatchmakerListenerBtn(e)
    print( "[SceneRealTimeGameMenu] Register Real-Time Matchmaker Listener Button Released" )
    if(composerM.isGameCenterEnabled == true) then
        composerM.gameKit.request( "registerRealTimeMatchmakerListener", { listener=onRealTimeMatchmakerGameCenterEvent } )
    else
        print( "[SceneRealTimeGameMenu] Can not register because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseShowGameCenterRealTimeMatchUI_Btn(e)
    print( "[SceneRealTimeGameMenu] Show Game Center Real-Time Match Button Released" )
    if(composerM.isGameCenterEnabled == true) then
        --composerM.gameKit.show( "gameCenterRealTimeMatchmakerUI", { minPlayers=2, maxPlayers=2, defaultNumPlayers=2, 
        --playerGroup=3, playerAttributes=0xFFFF0000 } )
        composerM.gameKit.show( "gameCenterRealTimeMatchUI", { minPlayers=2, maxPlayers=3, defaultNumPlayers=2 } )
    else
        print( "[SceneRealTimeGameMenu] Can not show because isGameCenterEnabled = false" )
    end
    return true
end

-- call gameCenterAddPlayersRealTimeMatchUI if an opponent loses their network connection and drops from the game. 
-- the added player will fill the dropped opponent's place in the existing match instead of having to end the match.
local function onReleaseShowGameCenterAddPlayersRealTimeMatchUI_Btn(e)
    print( "[SceneRealTimeGameMenu] Show Game Center Add Players To Real-Time Match Button Released" )
    if(composerM.isGameCenterEnabled == true) then
        --composerM.gameKit.show( "gameCenterAddPlayersRealTimeMatchUI", { minPlayers=2, maxPlayers=2, 
--        defaultNumPlayers=2, playerGroup=3, playerAttributes=0xFFFF0000 } )
        composerM.gameKit.show( "gameCenterAddPlayersRealTimeMatchUI", { minPlayers=2, maxPlayers=3, 
        defaultNumPlayers=2 } )
    else
        print( "[SceneRealTimeGameMenu] Can not show because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseRealTimeAutoMatchmakerBtn(e)
    print( "[SceneRealTimeGameMenu] Real-Time Auto-Matchmaker Button Released" )
    if(composerM.isGameCenterEnabled == true) then
        --composerM.gameKit.request( "realTimeAutoMatch", { minPlayers=2, maxPlayers=2, playerGroup=3, 
        --playerAttributes=0xFFFF0000 } )
        composerM.gameKit.request( "realTimeAutoMatchmaker", { minPlayers=2, maxPlayers=2 } )
    else
        print( "[SceneRealTimeGameMenu] Can not request because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseCancelRealTimeMatchmakerBtn(e)
    print( "[SceneRealTimeGameMenu] Cancel Real-Time Matchmaker Button Released" )
    if(composerM.isGameCenterEnabled == true) then
		composerM.gameKit.request( "cancelRealTimeMatchmaker" )
    else
        print( "[SceneRealTimeGameMenu] Can not cancel because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseInviteFriendsRealTimeMatchmakerBtn(e)
    print( "[SceneRealTimeGameMenu] Invite Friends Real-Time Matchmaker Button Released" )
    if(composerM.isGameCenterEnabled == true) then
    	if(composerM.friends ~= nil) then
            --composerM.gameKit.request( "inviteFriendsRealTimeMatchmaker", { minPlayers=2, maxPlayers=2, 
--            playerIDs={composerM.friends[1].playerID, composerM.friends[2].playerID}, 
--            inviteMessage = "You up for a real-time match!" } )
            composerM.gameKit.request( "inviteFriendsRealTimeMatchmaker", { minPlayers=2, maxPlayers=3, 
            playerIDs={composerM.friends[1].playerID}, inviteMessage = "You up for a real-time match!" } )
        else
            print( "[SceneRealTimeGameMenu] Can not invite because friends = nil" )
        end
    else
        print( "[SceneRealTimeGameMenu] Can not invite because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseAddPlayersToRealTimeMatchBtn(e)
    print( "[SceneRealTimeGameMenu] Add Players To Real-Time Match Button Released" )
    if(composerM.isGameCenterEnabled == true) then
    	if(composerM.friends ~= nil) then
            composerM.gameKit.request( "addPlayersToRealTimeMatch", { minPlayers=2, maxPlayers=3, 
            playerIDs={composerM.friends[3].playerID}, inviteMessage = "Join our real-time match??? :)" } )
        else
                print( "[SceneRealTimeGameMenu] Can not add players because friends = nil" )
        end
    else
        print( "[SceneRealTimeGameMenu] Can not request because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseFinishAddingPlayersToRealTimeMatchBtn(e)
    print( "[SceneRealTimeGameMenu] Finish Adding Players To Real-Time Match Button Released" )
    if(composerM.isGameCenterEnabled == true) then
    	composerM.gameKit.request( "finishAddingPlayersToRealTimeMatch" )
    else
        print( "[SceneRealTimeGameMenu] Can not request because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseStartBrowsingForNearbyPlayersBtn(e)
    print( "[SceneRealTimeGameMenu] Start Browsing For Nearby Players Button Released" )
    if(composerM.isGameCenterEnabled == true) then
    	composerM.gameKit.request( "startBrowsingForNearbyPlayers" )
    else
        print( "[SceneRealTimeGameMenu] Can not browse because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseStopBrowsingForNearbyPlayersBtn(e)
    print( "[SceneRealTimeGameMenu] Stop Browsing For Nearby Players Button Released" )
    if(composerM.isGameCenterEnabled == true) then
    	composerM.gameKit.request( "stopBrowsingForNearbyPlayers" )
    else
        print( "[SceneRealTimeGameMenu] Can not stop browse because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseGetNumberOfRealTimeMatchRequestsInLast60secondsBtn(e)
    print( "[SceneRealTimeGameMenu] Get Number Of Real-Time Match Requests In Last 60 Seconds Button Released" )
    if(composerM.isGameCenterEnabled == true) then
    	composerM.gameKit.get( "numberRealTimeMatchRequestsLast60seconds", { playerGroup=0 } )
    else
        print( "[SceneRealTimeGameMenu] Can not get because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseRealTimeGameScreenBtn(e)
    print( "[SceneRealTimeGameMenu] Real-Time Game Screen Button Released" )
    composerM.gotoScene('SceneRealTimeGame', {effect = 'fade', time = 500})
    return true
end

local function onReleaseBackBtn(e)
    print( "[SceneRealTimeGameMenu] Back Button Released" )
    composerM.gameKit.request( "unregisterRealTimeMatchmakerListener" )
    composerM.gotoScene('SceneMainMenu', {effect = 'fade', time = 500})
    return true
end

function scene:create(e)
    local sceneGroup = self.view
    
    local registerRealTimeMatchmakerListenerBtn = widget.newButton {
        label = "Register RT Matchmaker Listener",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseRegisterRealTimeMatchmakerListenerBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 2,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    registerRealTimeMatchmakerListenerBtn.x = composerM.contentCenterX
    registerRealTimeMatchmakerListenerBtn.y = 48
    sceneGroup:insert(registerRealTimeMatchmakerListenerBtn)
    
    local showGameCenterRealTimeMatchUI_Btn = widget.newButton {
        label = "Show GC Real-Time Match UI",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseShowGameCenterRealTimeMatchUI_Btn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    showGameCenterRealTimeMatchUI_Btn.x = composerM.contentCenterX
    showGameCenterRealTimeMatchUI_Btn.y = 124
    sceneGroup:insert(showGameCenterRealTimeMatchUI_Btn)
    
    local showGameCenterAddPlayersRealTimeMatchUI_Btn = widget.newButton {
        label = "Show GC Add Players RT Match UI",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseShowGameCenterAddPlayersRealTimeMatchUI_Btn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    showGameCenterAddPlayersRealTimeMatchUI_Btn.x = composerM.contentCenterX
    showGameCenterAddPlayersRealTimeMatchUI_Btn.y = 200
    sceneGroup:insert(showGameCenterAddPlayersRealTimeMatchUI_Btn)
    
    local cancelRealTimeMatchmakerBtn = widget.newButton {
        label = "Cancel Real-Time Matchmaker",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseCancelRealTimeMatchmakerBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    cancelRealTimeMatchmakerBtn.x = composerM.contentCenterX
    cancelRealTimeMatchmakerBtn.y = 276
    sceneGroup:insert(cancelRealTimeMatchmakerBtn)
    
    local realTimeAutoMatchmakerBtn = widget.newButton {
        label = "Real-Time Auto-Matchmaker",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseRealTimeAutoMatchmakerBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    realTimeAutoMatchmakerBtn.x = composerM.contentCenterX
    realTimeAutoMatchmakerBtn.y = 352
    sceneGroup:insert(realTimeAutoMatchmakerBtn)
    
    local inviteFriendsRealTimeMatchmakerBtn = widget.newButton {
        label = "Invite Friends RT Matchmaker",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseInviteFriendsRealTimeMatchmakerBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    inviteFriendsRealTimeMatchmakerBtn.x = composerM.contentCenterX
    inviteFriendsRealTimeMatchmakerBtn.y = 428
    sceneGroup:insert(inviteFriendsRealTimeMatchmakerBtn)
    
    local addPlayersToRealTimeMatchBtn = widget.newButton {
        label = "Add Players To Real-Time Match",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseAddPlayersToRealTimeMatchBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    addPlayersToRealTimeMatchBtn.x = composerM.contentCenterX
    addPlayersToRealTimeMatchBtn.y = 504
    sceneGroup:insert(addPlayersToRealTimeMatchBtn)
    
    local finishAddingPlayersToRealTimeMatchBtn = widget.newButton {
        label = "Finish Adding Players To RT Match",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseFinishAddingPlayersToRealTimeMatchBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    finishAddingPlayersToRealTimeMatchBtn.x = composerM.contentCenterX
    finishAddingPlayersToRealTimeMatchBtn.y = 580
    sceneGroup:insert(finishAddingPlayersToRealTimeMatchBtn)
    
    local startBrowsingForNearbyPlayersBtn = widget.newButton {
        label = "Start Browsing For Nearby Players",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseStartBrowsingForNearbyPlayersBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    startBrowsingForNearbyPlayersBtn.x = composerM.contentCenterX
    startBrowsingForNearbyPlayersBtn.y = 656
    sceneGroup:insert(startBrowsingForNearbyPlayersBtn)
    
    local stopBrowsingForNearbyPlayersBtn = widget.newButton {
        label = "Stop Browsing For Nearby Players",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseStopBrowsingForNearbyPlayersBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    stopBrowsingForNearbyPlayersBtn.x = composerM.contentCenterX
    stopBrowsingForNearbyPlayersBtn.y = 732
    sceneGroup:insert(stopBrowsingForNearbyPlayersBtn)
    
    local getNumberOfRealTimeMatchRequestsInLast60secondsBtn = widget.newButton {
        label = "Get # RT Match Req In Last 60 Sec",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseGetNumberOfRealTimeMatchRequestsInLast60secondsBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    getNumberOfRealTimeMatchRequestsInLast60secondsBtn.x = composerM.contentCenterX
    getNumberOfRealTimeMatchRequestsInLast60secondsBtn.y = 808
    sceneGroup:insert(getNumberOfRealTimeMatchRequestsInLast60secondsBtn)
    
    
    local realTimeGameScreenBtn = widget.newButton {
        label = "RT Game Screen",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseRealTimeGameScreenBtn,
        shape="roundedRect",
        width = 420,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    realTimeGameScreenBtn.x = 410
    realTimeGameScreenBtn.y = 912
    sceneGroup:insert(realTimeGameScreenBtn)
    
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
    print('[SceneRealTimeGameMenu] !!!!!!!!!!! destroy called !!!!!!!!!!!')
end

-- Scene Listener setup
scene:addEventListener('create', scene)
scene:addEventListener('show', scene)
scene:addEventListener('hide', scene)
scene:addEventListener('destroy', scene)

return scene