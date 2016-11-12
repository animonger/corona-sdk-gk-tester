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
local fortyFiveMinutes = 2700  -- 2700 seconds is 45 minutes
local twoHours = 7200  -- 7200 seconds is 2 hours
local oneDay = 86400 -- 86400 seconds is 24 hours

-- GameKit GKTurnBasedMatch Constants:
-- https://developer.apple.com/library/ios/documentation/GameKit/Reference/GKTurnBasedMatch_Ref/index.html#//apple_ref/c/tdef/GKTurnBasedMatchStatus

local matchStatusUnknown = 0
local matchStatusOpen = 1
local matchStatusEnded = 2
local matchStatusMatching = 3

local participantStatusUnknown = 0
local participantStatusInvited = 1
local participantStatusDeclined = 2
local participantStatusMatching = 3
local participantStatusActive = 4
local participantStatusDone = 5

local matchOutcomeNone = 0
local matchOutcomeQuit = 1
local matchOutcomeWon = 2
local matchOutcomeLost = 3
local matchOutcomeTied = 4
local matchOutcomeTimeExpired = 5
local matchOutcomeFirst = 6
local matchOutcomeSecond = 7
local matchOutcomeThird = 8
local matchOutcomeFourth = 9

local scores = nil  -- end of match scores table		
local achievements = nil  -- end of match achievements table

local function turnTimeoutDateExpiredMatchOutcomeQuitStatusDeclined()
    if(composerM.currentTurnBasedMatch.matchStatus ~= matchStatusEnded) then
        local firstIndexMatchOutcome = nil
        local secondIndexMatchOutcome = nil 
        if( (composerM.opponentOneTurnTimeoutDate ~= "nil") or (composerM.localPlayerTurnTimeoutDate ~= "nil") ) then
            if( composerM.isGameCenterEnabled == true ) then
                local dataStr = "turnTimeoutEndMockGameData" .. " - " .. mimeM.unb64(composerM.currentTurnBasedMatch.matchData) -- base64 decoding
                local dataB64 = mimeM.b64(dataStr) -- base64 encoding
                if(composerM.opponentOneTurnTimeoutDate ~= "nil") then
                    if(composerM.localPlayerParticipantsIndex == 1) then
                        firstIndexMatchOutcome = matchOutcomeWon
                        secondIndexMatchOutcome = matchOutcomeTimeExpired
                    else
                        firstIndexMatchOutcome = matchOutcomeTimeExpired
                        secondIndexMatchOutcome = matchOutcomeWon
                    end
                elseif(composerM.localPlayerTurnTimeoutDate ~= "nil") then
                    if(composerM.localPlayerParticipantsIndex == 1) then
                        firstIndexMatchOutcome = matchOutcomeTimeExpired
                        secondIndexMatchOutcome = matchOutcomeWon
                    else
                        firstIndexMatchOutcome = matchOutcomeWon
                        secondIndexMatchOutcome = matchOutcomeTimeExpired
                    end
                end
                local turnTimoutMessage = "Turn-Based Match Ended Turn Timeout"
                composerM.gameKit.submit( "endMatchInTurnWithMatchData", 
                { matchID=composerM.currentTurnBasedMatch.matchID, matchData=dataB64, 
                outcomes={firstIndexMatchOutcome, secondIndexMatchOutcome}, messageKey=turnTimoutMessage } )
                composerM.isLocalPlayerCurrentParticipant = false
            else
                print( "[SceneTurnBasedGame] Can not submit because isGameCenterEnabled = false" )
            end
        end
        if( (composerM.opponentOneMatchOutcome == matchOutcomeQuit) or (composerM.localPlayerMatchOutcome == matchOutcomeQuit) ) then
            if( composerM.isGameCenterEnabled == true ) then
                local dataStr = "matchOutcomeEndMockGameData" .. " - " .. mimeM.unb64(composerM.currentTurnBasedMatch.matchData) -- base64 decoding
                local dataB64 = mimeM.b64(dataStr) -- base64 encoding
                if(composerM.opponentOneMatchOutcome == matchOutcomeQuit) then
                    if(composerM.localPlayerParticipantsIndex == 1) then
                        firstIndexMatchOutcome = matchOutcomeWon
                        secondIndexMatchOutcome = matchOutcomeQuit
                    else
                        firstIndexMatchOutcome = matchOutcomeQuit
                        secondIndexMatchOutcome = matchOutcomeWon
                    end
                elseif(composerM.localPlayerMatchOutcome == matchOutcomeQuit) then
                    if(composerM.localPlayerParticipantsIndex == 1) then
                        firstIndexMatchOutcome = matchOutcomeQuit
                        secondIndexMatchOutcome = matchOutcomeWon
                    else
                        firstIndexMatchOutcome = matchOutcomeWon
                        secondIndexMatchOutcome = matchOutcomeQuit
                    end
                end
                local matchQuitMessage = "Turn-Based Match Ended Quit"
                composerM.gameKit.submit( "endMatchInTurnWithMatchData", 
                { matchID=composerM.currentTurnBasedMatch.matchID, matchData=dataB64, 
                outcomes={firstIndexMatchOutcome, secondIndexMatchOutcome}, messageKey=matchQuitMessage } )
                composerM.isLocalPlayerCurrentParticipant = false
            else
                    print( "[SceneTurnBasedGame] Can not submit because isGameCenterEnabled = false" )
            end
        end
        if( composerM.opponentOneParticipantStatus == participantStatusDeclined ) then
            if( composerM.isGameCenterEnabled == true ) then
                print( "[SceneTurnBasedGame] opponentOneParticipantStatus = participantStatusDeclined" )
                local quitMatchMessage = "Opponent Declined :("
                composerM.gameKit.submit( "participantQuitInTurnWithOutcome", 
                { matchID=composerM.currentTurnBasedMatch.matchID, matchOutcome=matchOutcomeQuit, 
                nextParticipantIndexs={composerM.localPlayerParticipantsIndex}, 
                matchData=composerM.currentTurnBasedMatch.matchData, removeMatch=true, messageKey=quitMatchMessage } )
                composerM.isLocalPlayerCurrentParticipant = false
            else
                print( "[SceneTurnBasedGame] Can not submit because isGameCenterEnabled = false" )
            end
        end
    end
end

-- use Lua conditionals if then else to filter turn-based match properties: matchStatus, currentParticipant,
-- participantStatus, timeoutDate, matchOutcome, etc.
local function onTurnBasedGameCenterEvent(e)
    print( '[SceneTurnBasedGame] onTurnBasedGameCenterEvent e.name = ' .. e.name )
    print( '[SceneTurnBasedGame] onTurnBasedGameCenterEvent e.type = ' .. e.type )
    if(e.type == "matchUpdated") then
        if(composerM.currentTurnBasedMatch.matchID == e.match.matchID) then
            composerM.localPlayerTurnTimeoutDate = e.match.participants[composerM.localPlayerParticipantsIndex].timeoutDate
            composerM.localPlayerParticipantStatus = e.match.participants[composerM.localPlayerParticipantsIndex].participantStatus
            composerM.localPlayerMatchOutcome = e.match.participants[composerM.localPlayerParticipantsIndex].matchOutcome
            composerM.opponentOneTurnTimeoutDate = e.match.participants[composerM.opponentOneParticipantsIndex].timeoutDate
            composerM.opponentOneParticipantStatus = e.match.participants[composerM.opponentOneParticipantsIndex].participantStatus
            composerM.opponentOneMatchOutcome = e.match.participants[composerM.opponentOneParticipantsIndex].matchOutcome
            composerM.currentTurnBasedMatch = e.match
            print( '[SceneTurnBasedGame] matchUpdated matchData = ' .. mimeM.unb64(composerM.currentTurnBasedMatch.matchData) ) -- base64 decoding
            if(composerM.localPlayerID == e.match.currentParticipant.playerID) then
                composerM.isLocalPlayerCurrentParticipant = true
                print( '[SceneTurnBasedGame] matchUpdated isLocalPlayerCurrentParticipant = true' )
            else
                composerM.isLocalPlayerCurrentParticipant = false
                print( '[SceneTurnBasedGame] matchUpdated isLocalPlayerCurrentParticipant = false' )
            end
            turnTimeoutDateExpiredMatchOutcomeQuitStatusDeclined()
            if(composerM.isLocalPlayerCurrentParticipant == true) then
                native.showAlert( "Current Match Updated", "Take your turn and submit it to Game Center.", { "Close" } )
            else
                native.showAlert( "Current Match Updated", "Match has been updated but its not your turn", { "Close" } )
            end
        else
            native.showAlert( "Other Match Updated", "A match other than this one has been updated.", { "Close" } )
        end
    elseif(e.type == "matchEnded") then
    	if(composerM.currentTurnBasedMatch.matchID == e.match.matchID) then
            composerM.isLocalPlayerCurrentParticipant = false
            composerM.currentTurnBasedMatch = e.match
            print( '[SceneTurnBasedGame] matchEnded matchData = ' .. mimeM.unb64(composerM.currentTurnBasedMatch.matchData) ) -- base64 decoding
            native.showAlert( "Match Ended", "This match has ended.", { "Close" } )
        else
            native.showAlert( "Other Match Ended", "A match other than this one has ended.", { "Close" } )
        end
    elseif(e.type == "exchangeRequest") then
    	if(composerM.currentTurnBasedMatch.matchID == e.exchange.matchID) then
            composerM.currentTurnBasedExchange = e.exchange
            print( '[SceneTurnBasedGame] exchangeRequest exchangeID = ' .. composerM.currentTurnBasedExchange.exchangeID )
            print( '[SceneTurnBasedGame] exchangeRequest exchangeData = ' .. composerM.currentTurnBasedExchange.exchangeData )
            native.showAlert( "Exchange Request", "Exchange request received.", { "Close" } )
        else
            native.showAlert( "Other Exchange Request", "A match other than this one has an exchange request.", { "Close" } )
        end
    elseif(e.type == "exchangeCanceled") then
    	if(composerM.currentTurnBasedMatch.matchID == e.exchange.matchID) then
            composerM.currentTurnBasedExchange = e.exchange
            print( '[SceneTurnBasedGame] exchangeCanceled exchangeID = ' .. composerM.currentTurnBasedExchange.exchangeID )
            print( '[SceneTurnBasedGame] exchangeCanceled exchangeData = ' .. composerM.currentTurnBasedExchange.exchangeData )
            native.showAlert( "Exchange Canceled", "Exchange canceled.", { "Close" } )
        else
            native.showAlert( "Other Exchange Canceled", "A match other than this one has an exchange canceled.", { "Close" } )
        end
    elseif(e.type == "exchangeCompleted") then
    	if(composerM.currentTurnBasedMatch.matchID == e.exchange.matchID) then
            composerM.currentTurnBasedExchange = e.exchange
            print( '[SceneTurnBasedGame] exchangeCompleted exchangeID = ' .. composerM.currentTurnBasedExchange.exchangeID )
            print( '[SceneTurnBasedGame] exchangeCompleted exchangeData = ' .. composerM.currentTurnBasedExchange.exchangeData )
            native.showAlert( "Exchange Completed", "Exchange completed.", { "Close" } )
        else
            native.showAlert( "Other Exchange Completed", "A match other than this one has an exchange completed.", { "Close" } )
        end
    elseif(e.type == "error") then
        print( '[SceneTurnBasedGame] onTurnBasedGameCenterEvent e.errorCode = ' .. e.errorCode )
        print( '[SceneTurnBasedGame] onTurnBasedGameCenterEvent e.errorDescription = ' .. e.errorDescription )
    elseif(e.type == "success") then
        print( '[SceneTurnBasedGame] onTurnBasedGameCenterEvent e.successDescription = ' .. e.successDescription )
    end
    return true
end

local function onUserInputTxtField(e)
    if ( e.phase == "began" ) then
        native.setKeyboardFocus( e.target )
        --print( "[SceneTurnBasedGame] Input Text = began" )
    end
    return true
end

local function onReleaseCancelTextInputBtn(e)
    print( "[SceneTurnBasedGame] Cancel Text Input Button Released" )
    native.setKeyboardFocus(nil)
    inputTxtField.text = ""
    return true
end

local function onReleaseCloseKeyboardBtn(e)
    print( "[SceneTurnBasedGame] Close Keyboard Button Released" )
    native.setKeyboardFocus(nil)
    return true
end

local function onReleaseSubmitGameCenterTurnBasedSaveDataBtn(e)
    print( "[SceneTurnBasedGame] Submit Game Center Turn Based Save Data Button Released" )
    native.setKeyboardFocus(nil)
    local dataStr = inputTxtField.text
    if( composerM.isLocalPlayerCurrentParticipant == true ) then
        if( composerM.isGameCenterEnabled == true ) then
            if( dataStr ~= "" ) then
                local matchData = mimeM.unb64(composerM.currentTurnBasedMatch.matchData) -- base64 decoding
                if( (matchData == "") or (matchData == nil) ) then
                    matchData = "."
                end
                dataStr = dataStr .. " - " .. matchData
                local dataB64 = mimeM.b64(dataStr) -- base64 encoding
                composerM.gameKit.submit( "saveCurrentTurnWithMatchData", 
                { matchID=composerM.currentTurnBasedMatch.matchID, matchData=dataB64 } )
            end
        else
            print( "[SceneTurnBasedGame] Can not submit because isGameCenterEnabled = false" )
        end
    else
	print( "[SceneTurnBasedGame] Can not submit because isLocalPlayerCurrentParticipant = false" )
    end
    inputTxtField.text = ""
    return true
end

-- need to submit at least 2 or more indexs in nextParticipantIndexs table for turnTimeout to work, otherwise turn gets 
-- stuck on next participant forever or until the next participant takes their turn. include local player index last 
-- in the nextParticipantIndexs so if other players all quit the turn will end on the last player to take a turn.
local function onReleaseSubmitGameCenterTurnBasedDataEndTurnWithNextParticipantsBtn(e)
    print( "[SceneTurnBasedGame] Submit Game Center Turn Based Data End Turn With Next Participants Button Released" )
    native.setKeyboardFocus(nil)
    local dataStr = inputTxtField.text
    if( composerM.isLocalPlayerCurrentParticipant == true ) then
        if( composerM.isGameCenterEnabled == true ) then
            if( dataStr ~= "" ) then
                local matchData = mimeM.unb64(composerM.currentTurnBasedMatch.matchData) -- base64 decoding
                if( (matchData == "") or (matchData == nil) ) then
                    matchData = "."
                end
                dataStr = dataStr .. " - " .. matchData
                local dataB64 = mimeM.b64(dataStr) -- base64 encoding
                local participantMessage = ""
                local stringFormatArguments = nil
                if(composerM.localPlayerParticipantsIndex == 1) then
                        participantMessage = "Participant %@, check this %@"
                        stringFormatArguments = {"1", "8"}
                else
                        participantMessage = "Participant %@, bagga mouth :D"
                        stringFormatArguments = {"2"}
                end
                composerM.gameKit.submit( "endTurnWithNextParticipants", 
                { matchID=composerM.currentTurnBasedMatch.matchID, 
                nextParticipantIndexs={composerM.opponentOneParticipantsIndex, composerM.localPlayerParticipantsIndex}, 
                turnTimeout=twoHours, matchData=dataB64, messageKey=participantMessage, messageArguments=stringFormatArguments } )
                composerM.isLocalPlayerCurrentParticipant = false
            end
        else
            print( "[SceneTurnBasedGame] Can not submit because isGameCenterEnabled = false" )
        end
    else
	print( "[SceneTurnBasedGame] Can not submit because isLocalPlayerCurrentParticipant = false" )
    end
    inputTxtField.text = ""
    return true
end

local function onReleaseSubmitGameCenterTurnBasedSendReminderBtn(e)
    print( "[SceneTurnBasedGame] Submit Game Center Turn Based Send Reminder Button Released" )
    if( composerM.isGameCenterEnabled == true ) then
        if( composerM.currentTurnBasedMatch ~= nil ) then
            local reminderMessage = "Hey, make your move already :P"
            composerM.gameKit.submit( "sendReminderToParticipants", 
            { matchID=composerM.currentTurnBasedMatch.matchID, toParticipantIndexs={composerM.opponentOneParticipantsIndex}, 
            messageKey=reminderMessage } )
        end
    else
        print( "[SceneTurnBasedGame] Can not submit because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseSubmitGameCenterTurnBasedQuitInTurnWithOutcomeBtn(e)
    print( "[SceneTurnBasedGame] Submit Game Center Turn Based Quit In Turn Button Released" )
    native.setKeyboardFocus(nil)
    local dataStr = inputTxtField.text
    if( composerM.isLocalPlayerCurrentParticipant == true ) then
        if( composerM.isGameCenterEnabled == true ) then
            if( dataStr ~= "" ) then
                dataStr = dataStr .. " - " .. mimeM.unb64(composerM.currentTurnBasedMatch.matchData) -- base64 decoding
                local dataB64 = mimeM.b64(dataStr) -- base64 encoding
                composerM.gameKit.submit( "participantQuitInTurnWithOutcome", 
                { matchID=composerM.currentTurnBasedMatch.matchID, matchOutcome=matchOutcomeQuit, 
                nextParticipantIndexs={composerM.opponentOneParticipantsIndex}, turnTimeout=twoHours, matchData=dataB64, 
                removeMatch=false, messageKey="I Quit :)" } )
                composerM.isLocalPlayerCurrentParticipant = false
            end
        else
            print( "[SceneTurnBasedGame] Can not submit because isGameCenterEnabled = false" )
        end
    else
	print( "[SceneTurnBasedGame] Can not submit because isLocalPlayerCurrentParticipant = false" )
    end
    inputTxtField.text = ""
    return true
end

local function onReleaseSubmitGameCenterTurnBasedQuitOutOfTurnWithOutcomeBtn(e)
    print( "[SceneTurnBasedGame] Submit Game Center Turn Based Quit Out Of Turn Button Released" )
    if( composerM.isGameCenterEnabled == true ) then
        if( composerM.currentTurnBasedMatch ~= nil ) then
            local quitMessage = "I'm outtie" 
            composerM.gameKit.submit( "participantQuitOutOfTurnWithOutcome", 
            { matchID=composerM.currentTurnBasedMatch.matchID, matchOutcome=matchOutcomeQuit, messageKey=quitMessage } )
        end
    else
        print( "[SceneTurnBasedGame] Can not submit because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseSubmitGameCenterTurnBasedDataEndMatchBtn(e)
    print( "[SceneTurnBasedGame] Submit Game Center Turn Based Data End Match Button Released" )
    native.setKeyboardFocus(nil)
    local dataStr = inputTxtField.text
    if( composerM.isLocalPlayerCurrentParticipant == true ) then
        if( composerM.isGameCenterEnabled == true ) then
            if( dataStr ~= "" ) then
                dataStr = dataStr .. " - " .. mimeM.unb64(composerM.currentTurnBasedMatch.matchData) -- base64 decoding
                local dataB64 = mimeM.b64(dataStr) -- base64 encoding
                local firstIndexMatchOutcome = nil
                local secondIndexMatchOutcome = nil
                if(composerM.localPlayerParticipantsIndex == 1) then
                    firstIndexMatchOutcome = matchOutcomeWon
                    secondIndexMatchOutcome = matchOutcomeLost
                else
                    firstIndexMatchOutcome = matchOutcomeLost
                    secondIndexMatchOutcome = matchOutcomeWon
                end
                local matchEndedMessage = "Turn-Based Game Over Man, game over"
--                if( composerM.currentTurnBasedMatch.participants ~= nil) then
--                    local opponentOnePlayerID = composerM.currentTurnBasedMatch.participants[composerM.opponentOneParticipantsIndex].playerID
--                    scores = { {playerID=composerM.localPlayerID, leaderboardID=composerM.defaultLeaderboardID, value=34, context=42}, 
--                    {playerID=opponentOnePlayerID, leaderboardID=composerM.defaultLeaderboardID, value=24, context=42} }
--                    achievements = { {playerID=composerM.localPlayerID, achievementID=composerM.achievement60pointsID, 
--                    percentComplete=100.00, showsCompletionBanner=true}, {playerID=opponentOnePlayerID, 
--                    achievementID=composerM.achievement60pointsID, percentComplete=100.00, showsCompletionBanner=true} }
--
--                    composerM.gameKit.submit( "endMatchInTurnWithMatchData", 
--                    { matchID=composerM.currentTurnBasedMatch.matchID, matchData=dataB64, 
--                    outcomes={firstIndexMatchOutcome, secondIndexMatchOutcome}, scores=scores, achievements=achievements, 
--                    messageKey=matchEndedMessage } )
--                else
--                    print( "[SceneTurnBasedGame] Can not submit because currentTurnBasedMatchParticipants = nil" )
--                end
                composerM.gameKit.submit( "endMatchInTurnWithMatchData", 
                { matchID=composerM.currentTurnBasedMatch.matchID, matchData=dataB64, 
                outcomes={firstIndexMatchOutcome, secondIndexMatchOutcome}, messageKey=matchEndedMessage } )
                composerM.isLocalPlayerCurrentParticipant = false
            end
        else
                print( "[SceneTurnBasedGame] Can not submit because isGameCenterEnabled = false" )
        end
    else
        print( "[SceneTurnBasedGame] Can not submit because isLocalPlayerCurrentParticipant = false" )
    end
    inputTxtField.text = ""
    return true
end

local function onReleaseSendExchangeToParticipantsBtn(e)
    print( "[SceneTurnBasedGame] Send Exchange To Participants Button Released" )
    native.setKeyboardFocus(nil)
    local dataStr = inputTxtField.text
    if( composerM.isGameCenterEnabled == true ) then
        if( dataStr ~= "" ) then
            local exchangeMessage = "Wanna swap cards?"
            composerM.gameKit.submit( "sendExchangeToParticipants", 
            { matchID=composerM.currentTurnBasedMatch.matchID, participantIndexs={composerM.opponentOneParticipantsIndex}, 
            exchangeData=dataStr, exchangeTimeout=fortyFiveMinutes, messageKey=exchangeMessage } )
        end
    else
        print( "[SceneTurnBasedGame] Can not submit because isGameCenterEnabled = false" )
    end
    inputTxtField.text = ""
    return true
end

local function onReleaseCancelExchangeToParticipantsBtn(e)
    print( "[SceneTurnBasedGame] Cancel Exchange To Participants Button Released" )
    if( composerM.isGameCenterEnabled == true ) then
        if(composerM.currentTurnBasedExchange ~= nil) then
            local cancelMessage = "You snooze, you lose :P"
            composerM.gameKit.submit( "cancelExchangeToParticipants", 
            { matchID=composerM.currentTurnBasedExchange.matchID, 
            exchangeID=composerM.currentTurnBasedExchange.exchangeID, messageKey=cancelMessage } )
        else
            print( "[SceneTurnBasedGame] Can not submit cancel because currentTurnBasedExchange = nil" )
        end
    else
        print( "[SceneTurnBasedGame] Can not submit cancel because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseReplyToExchangeBtn(e)
    print( "[SceneTurnBasedGame] Reply To Exchange Button Released" ) 
    native.setKeyboardFocus(nil)
    local dataStr = inputTxtField.text
    if( composerM.isGameCenterEnabled == true ) then
        if(composerM.currentTurnBasedExchange ~= nil) then
            if( dataStr ~= "" ) then
                local exchangeMessage = "These are what I give thee."
                composerM.gameKit.submit( "replyToExchange", 
                { matchID=composerM.currentTurnBasedExchange.matchID, 
                exchangeID=composerM.currentTurnBasedExchange.exchangeID, exchangeData=dataStr, messageKey=exchangeMessage } )
            else
                print( "[SceneTurnBasedGame] Can not submit cancel because dataStr = nil" )
            end
        else
            print( "[SceneTurnBasedGame] Can not submit cancel because currentTurnBasedExchange = nil" )
        end
    else
        print( "[SceneTurnBasedGame] Can not submit because isGameCenterEnabled = false" )
    end
    inputTxtField.text = ""
    return true
end

local function onReleaseSaveExchangeMergedMatchDataBtn(e)
    print( "[SceneTurnBasedGame] Save Exchange Merged Match Data With Resolved Exchanges Button Released" )
    native.setKeyboardFocus(nil)
    if( composerM.isLocalPlayerCurrentParticipant == true ) then
        local dataStr = inputTxtField.text
        if( composerM.isGameCenterEnabled == true ) then
            if( dataStr ~= "" ) then
                dataStr = dataStr .. " - " .. mimeM.unb64(composerM.currentTurnBasedMatch.matchData) -- base64 decoding
                local dataB64 = mimeM.b64(dataStr) -- base64 encoding
                composerM.gameKit.submit( "saveMergedMatchDataWithResolvedExchanges", 
                { matchID=composerM.currentTurnBasedMatch.matchID, mergedMatchData=dataB64 } )
            else
                print( "[SceneTurnBasedGame] Can not submit save because dataStr = nil" )
            end
        else
            print( "[SceneTurnBasedGame] Can not submit because isGameCenterEnabled = false" )
        end
    else
        print( "[SceneTurnBasedGame] Can not submit because isLocalPlayerCurrentParticipant = false" )
    end
    inputTxtField.text = ""
    return true
end

local function onReleaseRematchWithSameOpponentsBtn(e)
    print( "[SceneTurnBasedGame] Rematch With Same Opponents Button Released" )
    if( composerM.isGameCenterEnabled == true ) then
        composerM.gameKit.submit( "rematchWithSameOpponents", { matchID=composerM.currentTurnBasedMatch.matchID } )
    else
        print( "[SceneTurnBasedGame] Can not rematch because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleasePullGameCenterTurnBasedMatchBtn(e)
    print( "[SceneTurnBasedGame] Pull Game Center Turn-Based Match Button Released" )
    if( composerM.isGameCenterEnabled == true ) then
        composerM.gameKit.submit( "pullTurnBasedMatch", { matchID=composerM.currentTurnBasedMatch.matchID } )
    else
        print( "[SceneTurnBasedGame] Can not pull because isGameCenterEnabled = false" )
    end
    return true
end


local function onReleaseBackBtn(e)
    print( "[SceneTurnBasedGame] Back Button Released" )
    composerM.gotoScene('SceneTurnBasedGameMenu', {effect = 'fade', time = 500})
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
        width = 290,
        height = 56,
        cornerRadius = 2,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    cancelTextInputBtn.x = 165
    cancelTextInputBtn.y = 124
    sceneGroup:insert(cancelTextInputBtn)
    
    local closeKeyboardBtn = widget.newButton {
        label = "Close Keyboard",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseCloseKeyboardBtn,
        shape="roundedRect",
        width = 290,
        height = 56,
        cornerRadius = 2,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    closeKeyboardBtn.x = 475
    closeKeyboardBtn.y = 124
    sceneGroup:insert(closeKeyboardBtn)
    
    local submitGameCenterTurnBasedSaveDataBtn = widget.newButton {
        label = "Submit GC Turn-Based Save Data",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseSubmitGameCenterTurnBasedSaveDataBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    submitGameCenterTurnBasedSaveDataBtn.x = display.contentCenterX
    submitGameCenterTurnBasedSaveDataBtn.y = 200
    sceneGroup:insert(submitGameCenterTurnBasedSaveDataBtn)
    
    local submitGameCenterTurnBasedDataEndTurnWithNextParticipantsBtn = widget.newButton {
        label = "Submit GC TB Data End Turn",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseSubmitGameCenterTurnBasedDataEndTurnWithNextParticipantsBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    submitGameCenterTurnBasedDataEndTurnWithNextParticipantsBtn.x = display.contentCenterX
    submitGameCenterTurnBasedDataEndTurnWithNextParticipantsBtn.y = 276
    sceneGroup:insert(submitGameCenterTurnBasedDataEndTurnWithNextParticipantsBtn)
    
    local submitGameCenterTurnBasedSendReminderBtn = widget.newButton {
        label = "Submit GC TB Send Reminder",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseSubmitGameCenterTurnBasedSendReminderBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    submitGameCenterTurnBasedSendReminderBtn.x = display.contentCenterX
    submitGameCenterTurnBasedSendReminderBtn.y = 352
    sceneGroup:insert(submitGameCenterTurnBasedSendReminderBtn)
    
    local submitGameCenterTurnBasedQuitInTurnWithOutcomeBtn = widget.newButton {
        label = "Submit GC TB Quit In Turn",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseSubmitGameCenterTurnBasedQuitInTurnWithOutcomeBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    submitGameCenterTurnBasedQuitInTurnWithOutcomeBtn.x = display.contentCenterX
    submitGameCenterTurnBasedQuitInTurnWithOutcomeBtn.y = 428
    sceneGroup:insert(submitGameCenterTurnBasedQuitInTurnWithOutcomeBtn)
    
    local submitGameCenterTurnBasedQuitOutOfTurnWithOutcomeBtn = widget.newButton {
        label = "Submit GC TB Quit Out Of Turn",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseSubmitGameCenterTurnBasedQuitOutOfTurnWithOutcomeBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    submitGameCenterTurnBasedQuitOutOfTurnWithOutcomeBtn.x = display.contentCenterX
    submitGameCenterTurnBasedQuitOutOfTurnWithOutcomeBtn.y = 504
    sceneGroup:insert(submitGameCenterTurnBasedQuitOutOfTurnWithOutcomeBtn)
    
    local submitGameCenterTurnBasedDataEndMatchBtn = widget.newButton {
        label = "Submit GC TB Data End Match",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseSubmitGameCenterTurnBasedDataEndMatchBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    submitGameCenterTurnBasedDataEndMatchBtn.x = display.contentCenterX
    submitGameCenterTurnBasedDataEndMatchBtn.y = 580
    sceneGroup:insert(submitGameCenterTurnBasedDataEndMatchBtn)
    
    local sendExchangeToParticipantsBtn = widget.newButton {
        label = "Send Exchange",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseSendExchangeToParticipantsBtn,
        shape="roundedRect",
        width = 290,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    sendExchangeToParticipantsBtn.x = 165
    sendExchangeToParticipantsBtn.y = 656
    sceneGroup:insert(sendExchangeToParticipantsBtn)
    
    local cancelExchangeToParticipantsBtn = widget.newButton {
        label = "Cancel Exchange",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseCancelExchangeToParticipantsBtn,
        shape="roundedRect",
        width = 290,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    cancelExchangeToParticipantsBtn.x = 475
    cancelExchangeToParticipantsBtn.y = 656
    sceneGroup:insert(cancelExchangeToParticipantsBtn)
    
    local ReplyToExchangeBtn = widget.newButton {
        label = "Reply Exchange",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseReplyToExchangeBtn,
        shape="roundedRect",
        width = 290,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    ReplyToExchangeBtn.x = 165
    ReplyToExchangeBtn.y = 732
    sceneGroup:insert(ReplyToExchangeBtn)
    
    local saveExchangeMergedMatchDataBtn = widget.newButton {
        label = "Resolve Exchange",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseSaveExchangeMergedMatchDataBtn,
        shape="roundedRect",
        width = 290,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    saveExchangeMergedMatchDataBtn.x = 475
    saveExchangeMergedMatchDataBtn.y = 732
    sceneGroup:insert(saveExchangeMergedMatchDataBtn)
    
    local rematchWithSameOpponentsBtn = widget.newButton {
        label = "Rematch With Same Opponents",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseRematchWithSameOpponentsBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    rematchWithSameOpponentsBtn.x = display.contentCenterX
    rematchWithSameOpponentsBtn.y = 808
    sceneGroup:insert(rematchWithSameOpponentsBtn)
    
    local submitPullGameCenterTurnBasedMatchBtn = widget.newButton {
        label = "Submit Pull GC TB Match",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleasePullGameCenterTurnBasedMatchBtn,
        shape="roundedRect",
        width = 420,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    submitPullGameCenterTurnBasedMatchBtn.x = 410
    submitPullGameCenterTurnBasedMatchBtn.y = 884
    sceneGroup:insert(submitPullGameCenterTurnBasedMatchBtn)
    
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
        if(composerM.currentTurnBasedMatch ~= nil) then
            composerM.gameKit.request( "registerTurnBasedListener", { listener=onTurnBasedGameCenterEvent } )
            print( '[SceneTurnBasedGame] currentTurnBasedMatch.matchID = ' .. composerM.currentTurnBasedMatch.matchID )
            print( '[SceneTurnBasedGame] currentTurnBasedMatch.matchData = ' .. composerM.currentTurnBasedMatch.matchData )
            print( '[SceneTurnBasedGame] isLocalPlayerCurrentParticipant = ' .. tostring(composerM.isLocalPlayerCurrentParticipant) )
            print( '[SceneTurnBasedGame] localPlayerParticipantsIndex = ' .. tostring(composerM.localPlayerParticipantsIndex) )
            print( '[SceneTurnBasedGame] opponentOneParticipantsIndex = ' .. tostring(composerM.opponentOneParticipantsIndex) )
            print( '[SceneTurnBasedGame] localPlayerTurnTimeoutDate = ' .. composerM.localPlayerTurnTimeoutDate )
            print( '[SceneTurnBasedGame] opponentOneTurnTimeoutDate = ' .. composerM.opponentOneTurnTimeoutDate )
            print( '[SceneTurnBasedGame] localPlayerParticipantStatus = ' .. tostring(composerM.localPlayerParticipantStatus) )
            print( '[SceneTurnBasedGame] opponentOneParticipantStatus = ' .. tostring(composerM.opponentOneParticipantStatus) )
            print( '[SceneTurnBasedGame] localPlayerMatchOutcome = ' .. tostring(composerM.localPlayerMatchOutcome) )
            print( '[SceneTurnBasedGame] opponentOneMatchOutcome = ' .. tostring(composerM.opponentOneMatchOutcome) )
            if(composerM.currentTurnBasedExchange ~= nil) then
                    print( '[SceneTurnBasedGame] currentTurnBasedExchange.exchangeID = ' .. composerM.currentTurnBasedExchange.exchangeID )
            else
                    print( '[SceneTurnBasedGame] currentTurnBasedExchange = nil')
            end
            turnTimeoutDateExpiredMatchOutcomeQuitStatusDeclined()
        else
                print( '[SceneTurnBasedGame] currentTurnBasedMatch = nil')
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
        composerM.gameKit.request( "unregisterTurnBasedListener" )
    elseif (e.phase == 'did' ) then
        -- Called immediately after scene goes off screen.
    end
end

function scene:destroy(e)
    print('[SceneTurnBasedGame] !!!!!!!!!!! destroy called !!!!!!!!!!!')
end

-- Scene Listener setup
scene:addEventListener('create', scene)
scene:addEventListener('show', scene)
scene:addEventListener('hide', scene)
scene:addEventListener('destroy', scene)

return scene
