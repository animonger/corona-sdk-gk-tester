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
local mimeM = require ('mime')

local inputTxtField = nil
local isRealTimeListenerRegistered = false

local currentMatchData = ""

local function onRealTimeGameCenterEvent(e)
    print( '[SceneRealTimeGame] onRealTimeGameCenterEvent e.name = ' .. e.name )
    print( '[SceneRealTimeGame] onRealTimeGameCenterEvent e.type = ' .. e.type )
    if(e.type == "matchData") then
        print( '[SceneRealTimeGame] onRealTimeGameCenterEvent e.fromPlayerID = ' .. e.fromPlayerID )
        print( '[SceneRealTimeGame] onRealTimeGameCenterEvent e.data = ' .. e.data )
        currentMatchData = mimeM.unb64(e.data) -- base64 decoding
        print( '[SceneRealTimeGame] onRealTimeGameCenterEvent currentMatchData = ' .. currentMatchData )
        native.showAlert( "Received Match Data", "Take your turn and send it to Game Center.", { "Close" } )
    elseif(e.type == "error") then
        print( '[SceneRealTimeGame] onRealTimeGameCenterEvent e.errorCode = ' .. e.errorCode )
        print( '[SceneRealTimeGame] onRealTimeGameCenterEvent e.errorDescription = ' .. e.errorDescription )
    elseif(e.type == "success") then
        print( '[SceneRealTimeGame] onRealTimeGameCenterEvent e.successDescription = ' .. e.successDescription )
    elseif(e.type == "playerStateDisconnected") then
        print( '[SceneRealTimeGame] onRealTimeGameCenterEvent stateDisconnected e.playerID = ' .. e.playerID )
        if(e.playerID == composerM.localPlayerID) then
            -- local player connection got broken, disconnect local player from match
            if( composerM.isGameCenterEnabled == true ) then
                    composerM.gameKit.request( "disconnectRealTimeMatch" )
                    isRealTimeListenerRegistered = false
            else
                    print( "[SceneRealTimeGame] Can not disconnect because isGameCenterEnabled = false" )
            end
            native.showAlert( "Local Player Disconnected", "You have been disconnected, start a new real-time match.", { "Close" } )
        else
            -- one of local player's opponents disconnected, add more players or disconnect local player from match
        end
    elseif(e.type == "playerStateUnknown") then
        print( '[SceneRealTimeGame] onRealTimeGameCenterEvent stateUnknown e.playerID = ' .. e.playerID )
    end
    return true
end

local function onUserInputTxtField(e)
    if ( e.phase == "began" ) then
        native.setKeyboardFocus( e.target )
        --print( "[SceneRealTimeGame] Input Text = began" )
    end
    return true
end

local function onReleaseCancelTextInputBtn(e)
    print( "[SceneRealTimeGame] Cancel Text Input Button Released" )
    native.setKeyboardFocus(nil)
    inputTxtField.text = ""
    return true
end

local function onReleaseSendGameCenterRealTimeDataToAllPlayersBtn(e)
    print( "[SceneRealTimeGame] Send Game Center Real Time Data To All Players Button Released" )
    native.setKeyboardFocus(nil)
    local dataStr = inputTxtField.text
    if( composerM.isGameCenterEnabled == true ) then
        if( dataStr ~= "" ) then
            dataStr = dataStr .. " - " .. currentMatchData
            local dataB64 = mimeM.b64(dataStr) -- base64 encoding
            composerM.gameKit.sendRealTimeDataToAllPlayers( { data=dataB64, dataMode="Reliable", successCallback=true } )
        end
    else
        print( "[SceneRealTimeGame] Can not send because isGameCenterEnabled = false" )
    end
    inputTxtField.text = ""
    return true
end

local function onReleaseSendGameCenterRealTimeDataToPlayersBtn(e)
    print( "[SceneRealTimeGame] Send Game Center Real Time Data To Players Button Released" )
    native.setKeyboardFocus(nil)
    local dataStr = inputTxtField.text
    if( composerM.isGameCenterEnabled == true ) then
        if( dataStr ~= "" ) then
            dataStr = dataStr .. " - " .. currentMatchData
            local dataB64 = mimeM.b64(dataStr) -- base64 encoding
            if( composerM.currentRealTimeMatchPlayers ~= nil ) then
                composerM.gameKit.sendRealTimeDataToPlayers( { data=dataB64, dataMode="Reliable", 
                playerIDs={composerM.currentRealTimeMatchPlayers[1].playerID}, successCallback=false } )
            else
            	print( "[SceneRealTimeGame] Can not send because players = nil" )
            end
        end
    else
        print( "[SceneRealTimeGame] Can not send because isGameCenterEnabled = false" )
    end
    inputTxtField.text = ""
    return true
end

local function onReleaseDisconnectGameCenterRealTimeMatchBtn(e)
    print( "[SceneRealTimeGame] Disconnect Game Center Real Time Match Button Released" )
    if( composerM.isGameCenterEnabled == true ) then
        composerM.gameKit.request( "disconnectRealTimeMatch" )
        isRealTimeListenerRegistered = false
    else
        print( "[SceneRealTimeGame] Can not disconnect because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseBackBtn(e)
    print( "[SceneRealTimeGame] Back Button Released" )
    composerM.gotoScene('SceneRealTimeGameMenu', {effect = 'fade', time = 500})
    return true
end

function scene:create(e)
    local sceneGroup = self.view
    
    local textBg = display.newRoundedRect( composerM.contentCenterX, 48, 600, 56, 12 )
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
    cancelTextInputBtn.y = 124
    sceneGroup:insert(cancelTextInputBtn)
    
    local sendGameCenterRealTimeDataToAllPlayersBtn = widget.newButton {
        label = "Send GC RT Data To ALL Players",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseSendGameCenterRealTimeDataToAllPlayersBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    sendGameCenterRealTimeDataToAllPlayersBtn.x = display.contentCenterX
    sendGameCenterRealTimeDataToAllPlayersBtn.y = 200
    sceneGroup:insert(sendGameCenterRealTimeDataToAllPlayersBtn)
    
    local sendGameCenterRealTimeDataToPlayersBtn = widget.newButton {
        label = "Send GC RT Data To Players",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseSendGameCenterRealTimeDataToPlayersBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    sendGameCenterRealTimeDataToPlayersBtn.x = display.contentCenterX
    sendGameCenterRealTimeDataToPlayersBtn.y = 276
    sceneGroup:insert(sendGameCenterRealTimeDataToPlayersBtn)
    
    local disconnectGameCenterRealTimeMatchBtn = widget.newButton {
        label = "Disconnect GC Real Time Match",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseDisconnectGameCenterRealTimeMatchBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    disconnectGameCenterRealTimeMatchBtn.x = display.contentCenterX
    disconnectGameCenterRealTimeMatchBtn.y = 352
    sceneGroup:insert(disconnectGameCenterRealTimeMatchBtn)
    
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
    	if(isRealTimeListenerRegistered == false) then
            if(composerM.isGameCenterEnabled == true) then
                composerM.gameKit.request( "registerRealTimeListener", { listener=onRealTimeGameCenterEvent } )
                isRealTimeListenerRegistered = true
            else
                print( "[SceneRealTimeGame] Can not register because isGameCenterEnabled = false" )
            end
        end
    elseif(e.phase == 'did') then
        inputTxtField = native.newTextField( composerM.contentCenterX, 48, 580, 56 )
        inputTxtField.font = native.newFont(native.systemFont, 30)
        inputTxtField:setTextColor(0, 0, 0)
        inputTxtField.align = 'left'
        inputTxtField.hasBackground = false
        inputTxtField.placeholder = "Input mock game data"
        inputTxtField:addEventListener( "userInput", onUserInputTxtField )
    end
end

function scene:hide(e)
    if (e.phase == 'will') then
    	inputTxtField:removeEventListener( "userInput", onUserInputTxtField )
        inputTxtField:removeSelf()
        inputTxtField = nil
    elseif (e.phase == 'did' ) then
        -- Called immediately after scene goes off screen.
    end
end

function scene:destroy(e)
    print('[SceneRealTimeGame] !!!!!!!!!!! destroy called !!!!!!!!!!!')
end

-- Scene Listener setup
scene:addEventListener('create', scene)
scene:addEventListener('show', scene)
scene:addEventListener('hide', scene)
scene:addEventListener('destroy', scene)

return scene