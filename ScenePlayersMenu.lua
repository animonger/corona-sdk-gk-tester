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

local playerPhoto = nil

local function onRecipientsInFriendRequestCallback( event )
    for k, v in pairs( event ) do
        print('[ScenePlayersMenu] onRecipientsInFriendRequestCallback k = ' .. tostring(k) .. '  v = ' .. tostring(v))
    end
    return true
end

local function onGameCenterPlayerPhotoCallback(e)
    print( '[ScenePlayersMenu] onGameCenterPlayerPhotoCallback e.name = ' .. e.name )
    print( '[ScenePlayersMenu] onGameCenterPlayerPhotoCallback e.type = ' .. e.type )
    if(e.type == "error") then
        print( '[ScenePlayersMenu] onGameCenterPlayerPhotoCallback e.errorCode = ' .. e.errorCode )
        print( '[ScenePlayersMenu] onGameCenterPlayerPhotoCallback e.errorDescription = ' .. 
        e.errorDescription )
    elseif(e.type == "playerPhoto") then
        print('[ScenePlayersMenu] playerID = ' .. e.playerID )
    	playerPhoto = e.photo
    	playerPhoto.x = composerM.contentCenterX
    	playerPhoto.y = 600
    	scene.view:insert(playerPhoto)
    end
end

local function onGameCenterFriendsCallback(e)
    print( '[ScenePlayersMenu] onGameCenterFriendsCallback event.name = ' .. e.name )
    print( '[ScenePlayersMenu] onGameCenterFriendsCallback event.type = ' .. e.type )
    if(e.type == "error") then
        print( '[ScenePlayersMenu] onGameCenterFriendsCallback event.errorCode = ' .. e.errorCode )
        print( '[ScenePlayersMenu] onGameCenterFriendsCallback event.errorDescription = ' .. e.errorDescription )
    elseif(e.type == "friendList") then
    	composerM.friends = e.friends
        print( '[ScenePlayersMenu] onMatchmakerGameCenterEvent event.friendsCount = ' .. tostring(e.friendsCount) )
        for i = 1, e.friendsCount do
            print('[ScenePlayersMenu] friend ' .. tostring(i) .. ' playerID = ' .. e.friends[i].playerID )
            print('[ScenePlayersMenu] friend ' .. tostring(i) .. ' alias = ' .. e.friends[i].alias )
            print('[ScenePlayersMenu] friend ' .. tostring(i) .. ' displayName = ' .. e.friends[i].displayName )
        end
    end
end

local function onReleaseGetGameCenterPlayerPhotoBtn(e)
    print( "[ScenePlayersMenu] Get Game Center Player Photo Button Released" )
    if( composerM.isGameCenterEnabled == true ) then
        if(composerM.friends ~= nil) then
            composerM.gameKit.get( "playerPhoto", { playerID=composerM.friends[1].playerID, photoSize="Small",
            listener=onGameCenterPlayerPhotoCallback } )
        else
            print( "[SceneRealTimeGameMenu] Can not invite because friends = nil" )
        end
    else
        print( "[ScenePlayersMenu] Can not get because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseGetGameCenterMaxNumberOfRecipientsInFriendRequestBtn(e)
    print( "[ScenePlayersMenu] Get Game Center Max Number Of Recipients In Friend Request Button Released" )
    if( composerM.isGameCenterEnabled == true ) then
        composerM.gameKit.get( "maxNumberOfRecipientsInFriendRequest", { listener=onRecipientsInFriendRequestCallback } )
    else
        print( "[ScenePlayersMenu] Can not get because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseShowGameCenterFriendRequestUI_Btn(e)
    print( "[ScenePlayersMenu] Show Game Center Friend Request UI Button Released" )
    if( composerM.isGameCenterEnabled == true ) then
        composerM.gameKit.show( "gameCenterFriendRequestUI", { message="PLEASE, be my friend!" } )
    else
        print( "[ScenePlayersMenu] Can not get because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseGetGameCenterFriendsBtn(e)
    print( "[ScenePlayersMenu] Get Game Center Friends Button Released" )
    if( composerM.isGameCenterEnabled == true ) then
        composerM.gameKit.get( "friends", { listener=onGameCenterFriendsCallback } )
    else
        print( "[ScenePlayersMenu] Can not get because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseBackBtn(e)
    print( "[ScenePlayersMenu] Back Button Released" )
    composerM.gotoScene('SceneMainMenu', {effect = 'fade', time = 500})
    return true
end

function scene:create(e)
    local sceneGroup = self.view
	
    local getGameCenterPlayerPhotoBtn = widget.newButton {
        label = "Get Game Center Player Photo",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseGetGameCenterPlayerPhotoBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    getGameCenterPlayerPhotoBtn.x = composerM.contentCenterX
    getGameCenterPlayerPhotoBtn.y = 48
    sceneGroup:insert(getGameCenterPlayerPhotoBtn)
    
    local getGameCenterMaxNumberOfRecipientsInFriendRequestBtn = widget.newButton {
        label = "Get GC Max Recipients In Friend Req.",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseGetGameCenterMaxNumberOfRecipientsInFriendRequestBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    getGameCenterMaxNumberOfRecipientsInFriendRequestBtn.x = composerM.contentCenterX
    getGameCenterMaxNumberOfRecipientsInFriendRequestBtn.y = 124
    sceneGroup:insert(getGameCenterMaxNumberOfRecipientsInFriendRequestBtn)
    
    local showGameCenterFriendRequestUI_Btn = widget.newButton {
        label = "Show Game Center Friend Request UI",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseShowGameCenterFriendRequestUI_Btn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    showGameCenterFriendRequestUI_Btn.x = composerM.contentCenterX
    showGameCenterFriendRequestUI_Btn.y = 200
    sceneGroup:insert(showGameCenterFriendRequestUI_Btn)
    
    local getGameCenterFriendsBtn = widget.newButton {
        label = "Get Game Center Friends",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseGetGameCenterFriendsBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    getGameCenterFriendsBtn.x = composerM.contentCenterX
    getGameCenterFriendsBtn.y = 276
    sceneGroup:insert(getGameCenterFriendsBtn)
    
    
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
        if(playerPhoto ~= nil) then
       		playerPhoto:removeSelf()
       		playerPhoto = nil
       end
    elseif(e.phase == 'did') then
        
    end
end

function scene:hide(e)
    if (e.phase == 'will') then
        
    elseif (e.phase == 'did' ) then
        -- Called immediately after scene goes off screen.
    end
end

function scene:destroy(e)
    print('[ScenePlayersMenu] !!!!!!!!!!! destroy called !!!!!!!!!!!')
end

-- Scene Listener setup
scene:addEventListener('create', scene)
scene:addEventListener('show', scene)
scene:addEventListener('hide', scene)
scene:addEventListener('destroy', scene)

return scene