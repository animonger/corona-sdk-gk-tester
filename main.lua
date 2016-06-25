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

display.setStatusBar(display.HiddenStatusBar)

print('[Lua main] Corona GameKit Plugin Test App Launch')
print('[Lua main] pixelWidth = ' .. tostring(display.pixelWidth) .. '   pixelHeight = ' .. tostring(display.pixelHeight))
print('[Lua main] actualContentWidth = ' .. tostring(display.actualContentWidth) .. '   actualContentHeight = ' .. 
tostring(display.actualContentHeight))
print('[Lua main] contentWidth = ' .. tostring(display.contentWidth) .. '   contentHeight = ' .. 
tostring(display.contentHeight))
print('[Lua main] contentCenterX = ' .. tostring(display.contentCenterX) .. '   contentCenterY = ' .. 
tostring(display.contentCenterY))
print('[Lua main] contentScaleX = ' .. tostring(display.contentScaleX) .. '   contentScaleY = ' .. 
tostring(display.contentScaleY))
print('[Lua main] screenOriginX = ' .. tostring(display.screenOriginX) .. '   screenOriginY = ' .. 
tostring(display.screenOriginY))
print('')

local bg = display.newRect( 0, 0, display.contentWidth, display.contentHeight )
bg:setFillColor( 0.9, 0.9, 0.9 )
bg.x = display.contentCenterX
bg.y = display.contentCenterY

local composerM = require('composer')
composerM.gameKit = require("plugin.gamekit")
composerM.contentCenterX = display.contentCenterX
composerM.contentCenterY = display.contentCenterY
composerM.isGameCenterEnabled = false
composerM.localPlayerID = "nil"
composerM.localPlayerAlias = "nil"
composerM.friends = nil  -- local player's game center friends table
composerM.currentRealTimeMatchPlayers = nil  -- real-time match opponent players table
composerM.currentTurnBasedMatch = nil  -- current turn-based match table
composerM.currentTurnBasedExchange = nil  -- current turn-based exchange table
composerM.isLocalPlayerCurrentParticipant = false
composerM.localPlayerParticipantsIndex = 0
composerM.opponentOneParticipantsIndex = 0
composerM.localPlayerTurnTimeoutDate = "nil"
composerM.opponentOneTurnTimeoutDate = "nil"
composerM.localPlayerParticipantStatus = 0
composerM.opponentOneParticipantStatus = 0
composerM.localPlayerMatchOutcome = 0
composerM.opponentOneMatchOutcome = 0
composerM.achievement40pointsID = "Your-AGC-AchievementID"
composerM.achievement60pointsID = "Your-AGC-AchievementID"
composerM.defaultLeaderboardID = "Your-AGC-LeaderboardID"
composerM.secondLeaderboardID = "Your-AGC-LeaderboardID"

local function onInitGameCenterEvent(e)
    print( '[Lua main] onInitGameCenterEvent event.name = ' .. e.name )
    print( '[Lua main] onInitGameCenterEvent event.type = ' .. e.type )
    if(e.type == "error") then
        print( '[Lua main] onInitGameCenterEvent event.errorCode = ' .. e.errorCode )
        print( '[Lua main] onInitGameCenterEvent event.errorDescription = ' .. e.errorDescription )
        composerM.isGameCenterEnabled = false
    elseif(e.type == "showSignInUI") then
        print( '[Lua main] onInitGameCenterEvent call show gameCenterSignInUI when convenient' )
            composerM.isGameCenterEnabled = false
    elseif(e.type == "authenticated") then
        print( '[Lua main] onInitGameCenterEvent event.localPlayerID = ' .. e.localPlayerID )
        print( '[Lua main] onInitGameCenterEvent event.localPlayerAlias = ' .. e.localPlayerAlias )
        print( '[Lua main] onInitGameCenterEvent event.localPlayerIsUnderage = ' .. tostring(e.localPlayerIsUnderage) )
        composerM.localPlayerID = e.localPlayerID
        composerM.localPlayerAlias = e.localPlayerAlias 
        composerM.isGameCenterEnabled = true
    end
    print( '****')
    return true
end

local function onSystemEvent(e) 
    if( e.type == "applicationStart" ) then
        print( '[Lua main] onSystemEvent() applicationStart called' )
        composerM.gameKit.init( onInitGameCenterEvent )
    end
    return true
end

Runtime:addEventListener( "system", onSystemEvent )

composerM.gotoScene('SceneMainMenu', {effect = 'fade', time = 500})
