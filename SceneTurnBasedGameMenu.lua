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

local twoHours = 7200  -- 7200 seconds is two hours
local turnBasedMatchID = "nil"

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

local function printTurnBasedMatchTable( tbl )
    for k, v in pairs( tbl ) do
        print('k = ' .. tostring(k) .. '  v = ' .. tostring(v))
    end
    return true
end

local function onTurnBasedMatchmakerGameCenterEvent(e)
    print( '[SceneTurnBasedGameMenu] onTurnBasedMatchmakerGameCenterEvent event.name = ' .. e.name )
    print( '[SceneTurnBasedGameMenu] onTurnBasedMatchmakerGameCenterEvent event.type = ' .. e.type )
    if(e.type == "error") then
        print( '[SceneTurnBasedGameMenu] onTurnBasedMatchmakerGameCenterEvent event.errorCode = ' .. e.errorCode )
        print( '[SceneTurnBasedGameMenu] onTurnBasedMatchmakerGameCenterEvent event.errorDescription = ' .. e.errorDescription )
    elseif(e.type == "success") then
        print( '[SceneTurnBasedGameMenu] onTurnBasedMatchmakerGameCenterEvent event.successDescription = ' .. e.successDescription )
    elseif(e.type == "matchSelected") then
    	print('*****')
        print( '[SceneTurnBasedGameMenu] onTurnBasedMatchmakerGameCenterEvent event.participantsCount = ' .. tostring(e.participantsCount) )
        
        if(e.match.currentParticipant ~= "nil") then
            print( '[SceneTurnBasedGameMenu] onTurnBasedMatchmakerGameCenterEvent event.turnBasedMatch.currentParticipant =' )
            printTurnBasedMatchTable(e.match.currentParticipant)
            if(composerM.localPlayerID == e.match.currentParticipant.playerID) then
                composerM.isLocalPlayerCurrentParticipant = true
            else
                composerM.isLocalPlayerCurrentParticipant = false
            end
        else
            composerM.isLocalPlayerCurrentParticipant = false
            print( '[SceneTurnBasedGameMenu] onTurnBasedMatchmakerGameCenterEvent event.turnBasedMatch.currentParticipant = nil' )
        end
        
        for i = 1, e.participantsCount do
            if(composerM.localPlayerID == e.match.participants[i].playerID) then
                composerM.localPlayerParticipantsIndex = i
                composerM.localPlayerTurnTimeoutDate = e.match.participants[i].timeoutDate
                composerM.localPlayerParticipantStatus = e.match.participants[i].participantStatus
                composerM.localPlayerMatchOutcome = e.match.participants[i].matchOutcome
            else
                composerM.opponentOneParticipantsIndex = i
                composerM.opponentOneTurnTimeoutDate = e.match.participants[i].timeoutDate
                composerM.opponentOneParticipantStatus = e.match.participants[i].participantStatus
                composerM.opponentOneMatchOutcome = e.match.participants[i].matchOutcome
            end
            print( '[SceneTurnBasedGameMenu] onTurnBasedMatchmakerGameCenterEvent event.turnBasedMatch.participants[' .. tostring(i) ..'] =' )
            printTurnBasedMatchTable(e.match.participants[i])
        end
        print( '[SceneTurnBasedGameMenu] onTurnBasedMatchmakerGameCenterEvent event.turnBasedMatch =' )
        printTurnBasedMatchTable(e.match)
        if(e.match.exchanges ~= "nil") then
            composerM.currentTurnBasedExchange = e.match.exchanges[1]
            for j = 1, #e.match.exchanges do
                printTurnBasedMatchTable(e.match.exchanges[j])
            end
        else
            print( '[SceneTurnBasedGameMenu] onTurnBasedMatchmakerGameCenterEvent event.turnBasedMatch.exchanges = nil' )
        end
        composerM.currentTurnBasedMatch = e.match
        
        composerM.gotoScene('SceneTurnBasedGame', {effect = 'fade', time = 500})
        -- call registerTurnBasedListener in game scene
    elseif(e.type == "matchList") then
    	print( '[SceneTurnBasedGameMenu] onTurnBasedMatchmakerGameCenterEvent event.matchesCount = ' .. tostring(e.matchesCount) )
    	local isInvited = false
        for i = 1, e.matchesCount do
            print('[SceneTurnBasedGameMenu] turn-based match ' .. tostring(i) .. ' creationDate = ' .. e.matches[i].creationDate )
            print('[SceneTurnBasedGameMenu] turn-based match ' .. tostring(i) .. ' matchID = ' .. e.matches[i].matchID )
            print('[SceneTurnBasedGameMenu] turn-based match ' .. tostring(i) .. ' matchStatus = ' .. tostring(e.matches[i].matchStatus) )
            print('[SceneTurnBasedGameMenu] turn-based match ' .. tostring(i) .. ' message = ' .. e.matches[i].message )
            print('[SceneTurnBasedGameMenu] turn-based match ' .. tostring(i) .. ' matchDataMaximumSize = ' .. tostring(e.matches[i].matchDataMaximumSize) )
            print('[SceneTurnBasedGameMenu] turn-based match ' .. tostring(i) .. ' matchDataLength = ' .. tostring(e.matches[i].matchDataLength) )
            print('[SceneTurnBasedGameMenu] turn-based match ' .. tostring(i) .. ' matchData = ' .. e.matches[i].matchData )
            if(e.matches[i].currentParticipant ~= "nil") then
                print('[SceneTurnBasedGameMenu] turn-based match ' .. tostring(i) .. ' currentParticipant.lastTurnDate = ' .. e.matches[i].currentParticipant.lastTurnDate )
                print('[SceneTurnBasedGameMenu] turn-based match ' .. tostring(i) .. ' currentParticipant.playerID = ' .. e.matches[i].currentParticipant.playerID )
                print('[SceneTurnBasedGameMenu] turn-based match ' .. tostring(i) .. ' currentParticipant.participantStatus = ' .. tostring(e.matches[i].currentParticipant.participantStatus) )
                print('[SceneTurnBasedGameMenu] turn-based match ' .. tostring(i) .. ' currentParticipant.timeoutDate = ' .. e.matches[i].currentParticipant.timeoutDate )
                print('[SceneTurnBasedGameMenu] turn-based match ' .. tostring(i) .. ' currentParticipant.matchOutcome = ' .. tostring(e.matches[i].currentParticipant.matchOutcome) )
                if(e.matches[i].currentParticipant.participantStatus == participantStatusInvited) then
                    isInvited = true
                    turnBasedMatchID = e.matches[i].matchID
                end
            else
                print('[SceneTurnBasedGameMenu] turn-based match ' .. tostring(i) .. ' currentParticipant = ' .. e.matches[i].currentParticipant )
            end
            local participantsCount = #e.matches[i].participants
            for j = 1, participantsCount do
                print('[SceneTurnBasedGameMenu] turn-based match ' .. tostring(i) .. ' participant ' .. tostring(j) .. ' lastTurnDate = ' .. e.matches[i].participants[j].lastTurnDate )
                print('[SceneTurnBasedGameMenu] turn-based match ' .. tostring(i) .. ' participant ' .. tostring(j) .. ' playerID = ' .. e.matches[i].participants[j].playerID )
                print('[SceneTurnBasedGameMenu] turn-based match ' .. tostring(i) .. ' participant ' .. tostring(j) .. ' participantStatus = ' .. tostring(e.matches[i].participants[j].participantStatus) )
                print('[SceneTurnBasedGameMenu] turn-based match ' .. tostring(i) .. ' participant ' .. tostring(j) .. ' timeoutDate = ' .. e.matches[i].participants[j].timeoutDate )
                print('[SceneTurnBasedGameMenu] turn-based match ' .. tostring(i) .. ' participant ' .. tostring(j) .. ' matchOutcome = ' .. tostring(e.matches[i].participants[j].matchOutcome) )
            end
    	end
    	if(isInvited == true) then
            native.showAlert( "Match Invite", "Your friend invited you to a\nTurn-Based Match.", { "Close" } )
        end
    elseif(e.type == "localPlayerQuit") then
    	local localPlayerParticipantsIndex = 0
    	local localPlayerParticipantStatus = 0
    	local opponentOneParticipantsIndex = 0
    	local opponentOneParticipantStatus = 0
    	for i = 1, e.participantsCount do
            if(composerM.localPlayerID == e.match.participants[i].playerID) then
                localPlayerParticipantsIndex = i
                localPlayerParticipantStatus = e.match.participants[i].participantStatus
            else
                opponentOneParticipantsIndex = i
                opponentOneParticipantStatus = e.match.participants[i].participantStatus
            end
        end
    	if((opponentOneParticipantStatus == participantStatusDeclined) or (opponentOneParticipantStatus == participantStatusDone)) then
            composerM.gameKit.request( "localPlayerQuitMatchWithOutcome", { matchID=e.match.matchID, 
            matchOutcome=matchOutcomeQuit, nextParticipantIndexs={localPlayerParticipantsIndex}, 
            matchData=e.match.matchData, removeMatch=true, messageKey="Opponent Declined." } )
        else
            composerM.gameKit.request( "localPlayerQuitMatchWithOutcome", { matchID=e.match.matchID, 
            matchOutcome=matchOutcomeQuit, nextParticipantIndexs={opponentOneParticipantsIndex}, turnTimeout=twoHours, 
            matchData=e.match.matchData, removeMatch=false, messageKey="Local Player Quit." } )
        end
    end
end

local function onReleaseRegisterTurnBasedMatchmakerListenerBtn(e)
    print( "[SceneTurnBasedGameMenu] Register Turn-Based Matchmaker Listener Button Released" )
    if(composerM.isGameCenterEnabled == true) then
        composerM.gameKit.request( "registerTurnBasedMatchmakerListener", { listener=onTurnBasedMatchmakerGameCenterEvent } )
    else
        print( "[SceneTurnBasedGameMenu] Can not register because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseShowGameCenterTurnBasedExistingMatchesUI_Btn(e)
    print( "[SceneTurnBasedGameMenu] Show Game Center Turn-Based Existing Matches Button Released" )
    if(composerM.isGameCenterEnabled == true) then
        --composerM.gameKit.show( "gameCenterTurnBasedMatchUI", { minPlayers=2, maxPlayers=2, defaultNumPlayers=2, 
        --showExistingMatches=true, playerGroup=3, playerAttributes=0xFFFF0000 } )
        composerM.gameKit.show( "gameCenterTurnBasedMatchUI", { minPlayers=2, maxPlayers=2, defaultNumPlayers=2, 
        showExistingMatches=true } )
    else
        print( "[SceneTurnBasedGameMenu] Can not show because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseShowGameCenterTurnBasedCreateMatchUI_Btn(e)
    print( "[SceneTurnBasedGameMenu] Show Game Center Turn-Based Create Match Button Released" )
    if(composerM.isGameCenterEnabled == true) then
        composerM.gameKit.show( "gameCenterTurnBasedMatchUI", { minPlayers=2, maxPlayers=2, defaultNumPlayers=2, 
        showExistingMatches=false } )
    else
        print( "[SceneTurnBasedGameMenu] Can not show because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseTurnBasedAutoMatchmakerBtn(e)
    print( "[SceneRealTimeGameMenu] Turn-Based Auto-Matchmaker Button Released" )
    if(composerM.isGameCenterEnabled == true) then
--        composerM.gameKit.request( "turnBasedAutoMatchmaker", { minPlayers=2, maxPlayers=2, playerGroup=3, 
--        playerAttributes=0xFFFF0000 } )
        composerM.gameKit.request( "turnBasedAutoMatchmaker", { minPlayers=2, maxPlayers=2 } )
    else
        print( "[SceneTurnBasedGameMenu] Can not request because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseInviteFriendsTurnBasedMatchmakerBtn(e)
    print( "[SceneRealTimeGameMenu] Invite Friends Turn-Based Matchmaker Button Released" )
    if(composerM.isGameCenterEnabled == true) then
        if(composerM.friends ~= nil) then
            composerM.gameKit.request( "inviteFriendsTurnBasedMatchmaker", { minPlayers=2, maxPlayers=2, 
            playerIDs={composerM.friends[1].playerID}, inviteMessage = "Shall we play a game?" } )
        else
            print( "[SceneTurnBasedGameMenu] Can not invite because friends = nil" )
        end
    else
        print( "[SceneTurnBasedGameMenu] Can not invite because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseAcceptTurnBasedInviteBtn(e)
    print( "[SceneRealTimeGameMenu] Accept Turn-Based Invite Button Released" )
    if(composerM.isGameCenterEnabled == true) then
        if(turnBasedMatchID ~= "nil") then
            composerM.gameKit.request( "acceptTurnBasedMatchInvite", { matchID=turnBasedMatchID } )
        else
            print( "[SceneTurnBasedGameMenu] Can not accept because turnBasedMatchID = nil" )
        end
    else
        print( "[SceneTurnBasedGameMenu] Can not accept because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseDeclineTurnBasedInviteBtn(e)
    print( "[SceneRealTimeGameMenu] Decline Turn-Based Invite Button Released" )
    if(composerM.isGameCenterEnabled == true) then
        if(turnBasedMatchID ~= "nil") then
            composerM.gameKit.request( "declineTurnBasedMatchInvite", { matchID=turnBasedMatchID } )
        else
            print( "[SceneTurnBasedGameMenu] Can not decline because turnBasedMatchID = nil" )
        end
    else
        print( "[SceneTurnBasedGameMenu] Can not decline because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseGetTurnBasedMatchesBtn(e)
    print( "[SceneRealTimeGameMenu] Get Turn-Based Matches Button Released" )
    if(composerM.isGameCenterEnabled == true) then
        composerM.gameKit.get( "turnBasedMatches", { matchStatus="Open" } ) -- matchStatus = "All" or "Open"
    else
        print( "[SceneTurnBasedGameMenu] Can not get because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseGetTurnBasedMatchWithMatchID_Btn(e)
    print( "[SceneRealTimeGameMenu] Get Turn-Based Match With MatchID Button Released" )
    if(composerM.isGameCenterEnabled == true) then
        if(composerM.currentTurnBasedMatch ~= nil) then
            composerM.gameKit.get( "turnBasedMatchWithMatchID", { matchID=composerM.currentTurnBasedMatch.matchID } )
        else
            print( "[SceneTurnBasedGameMenu] Can not get because currentTurnBasedMatch = nil" )
        end
    else
        print( "[SceneTurnBasedGameMenu] Can not get because isGameCenterEnabled = false" )
    end
    return true
end

local function onReleaseRemoveTurnBasedMatchBtn(e)
    print( "[SceneRealTimeGameMenu] Remove Turn-Based Match Button Released" )
    if(composerM.isGameCenterEnabled == true) then
        if(composerM.currentTurnBasedMatch.matchID ~= "nil") then
            composerM.gameKit.request( "removeTurnBasedMatch", { matchID=composerM.currentTurnBasedMatch.matchID } )
        else
            print( "[SceneTurnBasedGameMenu] Can not remove because currentTurnBasedMatchID = nil" )
        end
    else
        print( "[SceneTurnBasedGameMenu] Can not remove because isGameCenterEnabled = false" )
    end
    return true
end


local function onReleaseTurnBasedGameScreenBtn(e)
    print( "[SceneTurnBasedGameMenu] Turn-Based Game Screen Button Released" )
    composerM.gotoScene('SceneTurnBasedGame', {effect = 'fade', time = 500})
    return true
end

local function onReleaseBackBtn(e)
    print( "[SceneTurnBasedGameMenu] Back Button Released" )
    composerM.gameKit.request( "unregisterTurnBasedMatchmakerListener" )
    composerM.gotoScene('SceneMainMenu', {effect = 'fade', time = 500})
    return true
end

function scene:create(e)
    local sceneGroup = self.view
    
    local registerTurnBasedMatchmakerListenerBtn = widget.newButton {
    label = "Register TB Matchmaker Listener",
    labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
    fontSize = 35,
    onRelease = onReleaseRegisterTurnBasedMatchmakerListenerBtn,
    shape="roundedRect",
    width = 600,
    height = 56,
    cornerRadius = 2,
    fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
    strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
    strokeWidth = 4
    }
    registerTurnBasedMatchmakerListenerBtn.x = display.contentCenterX
    registerTurnBasedMatchmakerListenerBtn.y = 48
    sceneGroup:insert(registerTurnBasedMatchmakerListenerBtn)
    
    local showGameCenterTurnBasedExistingMatchesUI_Btn = widget.newButton {
        label = "Show GC TB Existing Matches UI",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseShowGameCenterTurnBasedExistingMatchesUI_Btn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    showGameCenterTurnBasedExistingMatchesUI_Btn.x = composerM.contentCenterX
    showGameCenterTurnBasedExistingMatchesUI_Btn.y = 124
    sceneGroup:insert(showGameCenterTurnBasedExistingMatchesUI_Btn)
    
    local showGameCenterTurnBasedCreateMatchUI_Btn = widget.newButton {
        label = "Show GC TB Create Match UI",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseShowGameCenterTurnBasedCreateMatchUI_Btn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    showGameCenterTurnBasedCreateMatchUI_Btn.x = composerM.contentCenterX
    showGameCenterTurnBasedCreateMatchUI_Btn.y = 200
    sceneGroup:insert(showGameCenterTurnBasedCreateMatchUI_Btn)
    
    local turnBasedAutoMatchmakerBtn = widget.newButton {
        label = "Turn-Based Auto-Matchmaker",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseTurnBasedAutoMatchmakerBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    turnBasedAutoMatchmakerBtn.x = composerM.contentCenterX
    turnBasedAutoMatchmakerBtn.y = 276
    sceneGroup:insert(turnBasedAutoMatchmakerBtn)
    
    local inviteFriendsTurnBasedMatchmakerBtn = widget.newButton {
        label = "Invite Friends TB Matchmaker",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseInviteFriendsTurnBasedMatchmakerBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    inviteFriendsTurnBasedMatchmakerBtn.x = composerM.contentCenterX
    inviteFriendsTurnBasedMatchmakerBtn.y = 352
    sceneGroup:insert(inviteFriendsTurnBasedMatchmakerBtn)
    
    local acceptTurnBasedInviteBtn = widget.newButton {
        label = "Accept Turn-Based Invite",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseAcceptTurnBasedInviteBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    acceptTurnBasedInviteBtn.x = composerM.contentCenterX
    acceptTurnBasedInviteBtn.y = 428
    sceneGroup:insert(acceptTurnBasedInviteBtn)
    
    local declineTurnBasedInviteBtn = widget.newButton {
        label = "Decline Turn-Based Invite",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseDeclineTurnBasedInviteBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    declineTurnBasedInviteBtn.x = composerM.contentCenterX
    declineTurnBasedInviteBtn.y = 504
    sceneGroup:insert(declineTurnBasedInviteBtn)
    
    local getTurnBasedMatchesBtn = widget.newButton {
        label = "Get Turn-Based Matches",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseGetTurnBasedMatchesBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    getTurnBasedMatchesBtn.x = composerM.contentCenterX
    getTurnBasedMatchesBtn.y = 580
    sceneGroup:insert(getTurnBasedMatchesBtn)
    
    local getTurnBasedMatchWithMatchID_Btn = widget.newButton {
        label = "Get TB Match With MatchID",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseGetTurnBasedMatchWithMatchID_Btn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    getTurnBasedMatchWithMatchID_Btn.x = composerM.contentCenterX
    getTurnBasedMatchWithMatchID_Btn.y = 656
    sceneGroup:insert(getTurnBasedMatchWithMatchID_Btn)
    
    local removeTurnBasedMatchBtn = widget.newButton {
        label = "Remove Turn-Based Match",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseRemoveTurnBasedMatchBtn,
        shape="roundedRect",
        width = 600,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    removeTurnBasedMatchBtn.x = composerM.contentCenterX
    removeTurnBasedMatchBtn.y = 732
    sceneGroup:insert(removeTurnBasedMatchBtn)
    
    
    local turnBasedGameScreenBtn = widget.newButton {
        label = "TB Game Screen",
        labelColor = { default={ 0, 0, 0 }, over={ 0, 0, 0, 0.5 } },
        fontSize = 35,
        onRelease = onReleaseTurnBasedGameScreenBtn,
        shape="roundedRect",
        width = 420,
        height = 56,
        cornerRadius = 4,
        fillColor = { default={ 1, 0, 0, 1 }, over={ 1, 0.1, 0.7, 0.4 } },
        strokeColor = { default={ 1, 0.4, 0, 1 }, over={ 0.8, 0.8, 1, 1 } },
        strokeWidth = 4
    }
    turnBasedGameScreenBtn.x = 410
    turnBasedGameScreenBtn.y = 912
    sceneGroup:insert(turnBasedGameScreenBtn)
    
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
        -- Called when the scene is on screen but is about to go off screen.
        -- Insert code here to pause the scene.
        -- Example: start listeners, stop timers, stop animation, stop audio, etc.
    elseif (e.phase == 'did' ) then
        -- Called immediately after scene goes off screen.
    end
end

function scene:destroy(e)
    print('[SceneTurnBasedGameMenu] !!!!!!!!!!! destroy called !!!!!!!!!!!')
end

-- Scene Listener setup
scene:addEventListener('create', scene)
scene:addEventListener('show', scene)
scene:addEventListener('hide', scene)
scene:addEventListener('destroy', scene)

return scene