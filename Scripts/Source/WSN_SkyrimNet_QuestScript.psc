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
;   WSN_DeityVoiceID is a String[] indexed by worshipID (0-51), providing
;   per-deity default voice types. DeityVoiceID is the hardcoded fallback.
;   The "voice.override" manifest setting takes precedence over all if set.
;   HandlePrayerStart always passes the resolved voice so deity switches
;   update correctly. If an override is set, it persists across switches.
;
; Debug:
;   Controlled via manifest.yaml "debug.enabled" setting (SkyrimNet WebUI).
; =============================================================================

String VIRTUAL_NPC_NAME = "wsn_deity"

String Property DeityVoiceID = "MaleSoldier" Auto
String[] WSN_DeityVoiceID
Bool Property bInitialized = False Auto Hidden
Bool Property bPrayerActive = False Auto Hidden

; ---------------------------------------------------------------------------
; Init — defer until game is fully loaded, register NPC
; ---------------------------------------------------------------------------

Event OnInit()
    InitDeityVoices()
    RegisterForSingleUpdate(3.0)
EndEvent

Event OnUpdate()
    If !bInitialized
        InitDeityVoices()
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

    If GetRequireDevotee() && !tracker.IsFavored
        DBG("HandlePrayerStart: player is not Devotee and require_devotee is enabled")
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

    String deityVoice = ResolveVoice(worshipID)
    SkyrimNetApi.UpdateVirtualNPC(VIRTUAL_NPC_NAME, deityName, deityVoice, "", "")

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
    Int worshipID = -1

    If tracker != None && tracker.worshipID != -1
        deityName = tracker.WSN_DeityName[tracker.worshipID]
        worshipID = tracker.worshipID
    EndIf

    If deityName == ""
        deityName = "Unknown Deity"
    EndIf

    String deityVoice = ResolveVoice(worshipID)
    DBG("RegisterVirtualNPC: name=" + deityName + " voice=" + deityVoice)
    SkyrimNetApi.RegisterVirtualNPC(VIRTUAL_NPC_NAME, deityName, deityVoice, "private", "")
    SkyrimNetApi.DisableVirtualNPC(VIRTUAL_NPC_NAME)
EndFunction

; ---------------------------------------------------------------------------
; Voice initialization — indexed by worshipID (0-51)
; Order must match WSN_DeityName in wsn_trackerquest_quest
; ---------------------------------------------------------------------------

Function InitDeityVoices()
    WSN_DeityVoiceID = New String[52]
    WSN_DeityVoiceID[0]  = "MaleEvenToned"       ; Julianos
    WSN_DeityVoiceID[1]  = "MaleElfHaughty"       ; Syrabane
    WSN_DeityVoiceID[2]  = "MaleElfHaughty"       ; Magnus
    WSN_DeityVoiceID[3]  = "MaleElfHaughty"       ; Jephre
    WSN_DeityVoiceID[4]  = "FemaleOldKindly"      ; Mara
    WSN_DeityVoiceID[5]  = "FemaleUniqueMeridia"   ; Meridia
    WSN_DeityVoiceID[6]  = "FemaleUniqueAzura"     ; Azura
    WSN_DeityVoiceID[7]  = "MaleCommander"        ; Talos
    WSN_DeityVoiceID[8]  = "MaleOldKindly"        ; Akatosh
    WSN_DeityVoiceID[9]  = "FemaleSultry"         ; Dibella
    WSN_DeityVoiceID[10] = "MaleElfHaughty"       ; Phynaster
    WSN_DeityVoiceID[11] = "MaleUniqueMehrunesDagon" ; Mehrunes Dagon
    WSN_DeityVoiceID[12] = "FemaleUniqueVaermina"   ; Vaermina
    WSN_DeityVoiceID[13] = "MaleCommoner"         ; Zenithar
    WSN_DeityVoiceID[14] = "FemaleUniqueBoethiah"  ; Boethiah
    WSN_DeityVoiceID[15] = "FemaleUniqueNocturnal" ; Nocturnal
    WSN_DeityVoiceID[16] = "MaleUniqueMolagBal"    ; Molag Bal
    WSN_DeityVoiceID[17] = "FemaleEvenToned"      ; Kynareth
    WSN_DeityVoiceID[18] = "FemaleUniqueMephala"   ; Mephala
    WSN_DeityVoiceID[19] = "MaleOldKindly"        ; Arkay
    WSN_DeityVoiceID[20] = "MaleDrunk"            ; Sanguine
    WSN_DeityVoiceID[21] = "MaleUniqueMalacath"    ; Malacath
    WSN_DeityVoiceID[22] = "MaleCommander"        ; Stendarr
    WSN_DeityVoiceID[23] = "MaleElfHaughty"       ; Auriel
    WSN_DeityVoiceID[24] = "MaleUniquePeryite"     ; Peryite
    WSN_DeityVoiceID[25] = "MaleUniqueHircine"     ; Hircine
    WSN_DeityVoiceID[26] = "MaleElfHaughty"       ; Xarxes
    WSN_DeityVoiceID[27] = "SPECIALMaleUniqueTsun"  ; Shor
    WSN_DeityVoiceID[28] = "MaleUniqueHermaeusMora" ; Hermaeus Mora
    WSN_DeityVoiceID[29] = "MaleUniqueClavicusVile" ; Clavicus Vile
    WSN_DeityVoiceID[30] = "FemaleUniqueNamira"     ; Namira
    WSN_DeityVoiceID[31] = "MaleEvenToned"        ; Jyggalag
    WSN_DeityVoiceID[32] = "MaleElfHaughty"       ; Trinimac
    WSN_DeityVoiceID[33] = "MaleUniqueSheogorath"   ; Sheogorath
    WSN_DeityVoiceID[34] = "MaleUniqueGhost"      ; Sithis
    WSN_DeityVoiceID[35] = "MaleCommoner"         ; Z'en
    WSN_DeityVoiceID[36] = "MaleBrute"            ; Satakal
    WSN_DeityVoiceID[37] = "MaleOldKindly"        ; Tall Papa
    WSN_DeityVoiceID[38] = "MaleCommander"        ; the HoonDing
    WSN_DeityVoiceID[39] = ""                     ; (unused)
    WSN_DeityVoiceID[40] = "MaleNord"             ; the Animal Gods
    WSN_DeityVoiceID[41] = "MaleSlyCynical"       ; Baan Dar
    WSN_DeityVoiceID[42] = "MaleCommander"        ; Ebonarm
    WSN_DeityVoiceID[43] = "MaleKhajiit"          ; Rajhin
    WSN_DeityVoiceID[44] = "MaleKhajiit"          ; Riddle'Thar
    WSN_DeityVoiceID[45] = "FemaleOldKindly"      ; Morwha
    WSN_DeityVoiceID[46] = "FemaleCommander"      ; Leki
    WSN_DeityVoiceID[47] = "MaleUniqueGhost"      ; the Hist
    WSN_DeityVoiceID[48] = "FemaleEvenToned"      ; St. Alessia
    WSN_DeityVoiceID[49] = "MaleWarlock"          ; Mannimarco
    WSN_DeityVoiceID[50] = "MaleOldGrumpy"        ; the All-Maker
    WSN_DeityVoiceID[51] = "FemaleEvenToned"      ; the Magna-Ge
    DBG("InitDeityVoices: initialized 52 voice types")
EndFunction

; ---------------------------------------------------------------------------
; Config — read from SkyrimNet manifest settings
; ---------------------------------------------------------------------------

Bool Function GetDebugMode()
    Return SkyrimNetApi.GetConfigBool("Plugin_Wintersun Integration", "debug.enabled", False)
EndFunction

String Function GetVoiceOverride()
    Return SkyrimNetApi.GetConfigString("Plugin_Wintersun Integration", "voice.override", "")
EndFunction

Bool Function GetRequireDevotee()
    Return SkyrimNetApi.GetConfigBool("Plugin_Wintersun Integration", "require_devotee", True)
EndFunction

String Function ResolveVoice(Int worshipID)
    String voiceOverride = GetVoiceOverride()
    If voiceOverride != ""
        Return voiceOverride
    EndIf
    If worshipID >= 0 && worshipID < WSN_DeityVoiceID.Length
        String perDeityVoice = WSN_DeityVoiceID[worshipID]
        If perDeityVoice != ""
            Return perDeityVoice
        EndIf
    EndIf
    Return DeityVoiceID
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
    If GetDebugMode()
        Debug.Notification("[WSN] " + msg)
        Debug.Trace("[WSN] " + msg, 0)
    EndIf
EndFunction
