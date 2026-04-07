Scriptname WSN_SkyrimNet_QuestScript Extends Quest

; =============================================================================
; Wintersun x SkyrimNet Integration - Virtual Deity NPC
;
; Prayer detection is handled by WSN_SkyrimNet_PlayerAliasScript (ReferenceAlias
; on the player) using PO3 Papyrus Extender's alias-based MagicEffectApply event.
; That script calls HandlePrayerStart() here when prayer begins.
;
; Prayer end detection uses 5s polling via RegisterForSingleUpdate since there
; is no "effect removed" event in PO3.
;
; Voice configuration:
;   DeityVoiceID defaults to "malesoldier".
;
; Debug:
;   bDebugMode = True logs every event to screen + Papyrus log.
; =============================================================================

String VIRTUAL_NPC_NAME = "wsn_deity"

String Property DeityVoiceID = "malesoldier" Auto
Bool Property bDebugMode = False Auto
Bool Property bInitialized = False Auto Hidden
Bool Property bPrayerActive = False Auto Hidden

; ---------------------------------------------------------------------------
; Init — defer until game is fully loaded, register NPC
; ---------------------------------------------------------------------------

Event OnInit()
    RegisterForSingleUpdate(3.0)
EndEvent

Event OnUpdate()
    If !bInitialized
        If IsWintersunLoaded()
            DBG("Init: Wintersun loaded, registering virtual NPC")
            RegisterOrUpdateVirtualNPC()
            bInitialized = True
            DBG("Init: complete")
        Else
            DBG("Init: Wintersun not loaded, retrying in 5s")
            RegisterForSingleUpdate(5.0)
        EndIf
        Return
    EndIf

    ; Prayer end detection: poll every 1s while prayer is active
    If bPrayerActive
        MagicEffect prayerEffect = GetPrayerEffect()
        If prayerEffect != None && Game.GetPlayer().HasMagicEffect(prayerEffect)
            RegisterForSingleUpdate(5.0)
        Else
            HandlePrayerEnd()
        EndIf
    EndIf
EndEvent

; ---------------------------------------------------------------------------
; Prayer start — called by WSN_SkyrimNet_PlayerAliasScript
; ---------------------------------------------------------------------------

Function HandlePrayerStart()
    DBG("HandlePrayerStart called")

    If bPrayerActive
        DBG("HandlePrayerStart: already active, skipping")
        Return
    EndIf

    wsn_trackerquest_quest tracker = GetTracker()
    If tracker == None
        DBG("HandlePrayerStart: tracker is None")
        Return
    EndIf

    If !tracker.IsFavored
        DBG("HandlePrayerStart: player is not Favored")
        Return
    EndIf

    Int worshipID = tracker.worshipID
    If worshipID == -1
        DBG("HandlePrayerStart: worshipID is -1")
        Return
    EndIf

    String deityName = tracker.WSN_DeityName[worshipID]
    If deityName == ""
        DBG("HandlePrayerStart: deity name empty for worshipID=" + worshipID as String)
        Return
    EndIf

    DBG("HandlePrayerStart: worshipID=" + worshipID as String + " deity=" + deityName)

    SkyrimNetApi.UpdateVirtualNPC(VIRTUAL_NPC_NAME, deityName, "", "", "")

    DBG("HandlePrayerStart: enabling virtual NPC")
    SkyrimNetApi.EnableVirtualNPC(VIRTUAL_NPC_NAME)
    bPrayerActive = True
    RegisterForSingleUpdate(5.0)
EndFunction

; ---------------------------------------------------------------------------
; Prayer end
; ---------------------------------------------------------------------------

Function HandlePrayerEnd()
    DBG("HandlePrayerEnd: disabling virtual NPC")
    bPrayerActive = False
    SkyrimNetApi.DisableVirtualNPC(VIRTUAL_NPC_NAME)
EndFunction

; ---------------------------------------------------------------------------
; Registration
; ---------------------------------------------------------------------------

Function RegisterOrUpdateVirtualNPC()
    wsn_trackerquest_quest tracker = GetTracker()
    String deityName = ""

    If tracker != None && tracker.worshipID != -1
        deityName = tracker.WSN_DeityName[tracker.worshipID]
    EndIf

    If deityName == ""
        deityName = "Unknown Deity"
    EndIf

    DBG("RegisterVirtualNPC: name=" + deityName + " voice=" + DeityVoiceID)
    SkyrimNetApi.RegisterVirtualNPC(VIRTUAL_NPC_NAME, deityName, DeityVoiceID, "private", "")
    SkyrimNetApi.DisableVirtualNPC(VIRTUAL_NPC_NAME)
EndFunction

; ---------------------------------------------------------------------------
; Helpers
; ---------------------------------------------------------------------------

wsn_trackerquest_quest Function GetTracker()
    Quest q = Game.GetFormFromFile(0x005901, "Wintersun - Faiths of Skyrim.esp") as Quest
    If q == None
        Return None
    EndIf
    Return q as wsn_trackerquest_quest
EndFunction

MagicEffect Function GetPrayerEffect()
    Return Game.GetFormFromFile(0x00A839, "Wintersun - Faiths of Skyrim.esp") as MagicEffect
EndFunction

Bool Function IsWintersunLoaded()
    Return Game.GetFormFromFile(0x005901, "Wintersun - Faiths of Skyrim.esp") != None
EndFunction

Function DBG(String msg)
    If bDebugMode
        Debug.Notification("[WSN] " + msg)
        Debug.Trace("[WSN] " + msg, 0)
    EndIf
EndFunction
