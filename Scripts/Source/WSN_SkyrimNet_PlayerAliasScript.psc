Scriptname WSN_SkyrimNet_PlayerAliasScript Extends ReferenceAlias

; Filled with the player. Uses PO3 Papyrus Extender's alias-based event registration
; to detect when the Wintersun prayer MagicEffect is applied to the player.

WSN_SkyrimNet_QuestScript Property QuestScript Auto
MagicEffect Property PrayerEffect Auto   ; 00A839:Wintersun - Faiths of Skyrim.esp

Event OnInit()
    ; Force-fill this alias with the player at quest start
    ForceRefTo(Game.GetPlayer())
    DBG("Alias filled with player: " + GetReference())
    RegisterForSingleUpdate(3.0)
EndEvent

Event OnUpdate()
    If PrayerEffect == None
        DBG("PrayerEffect not set, retrying in 5s")
        RegisterForSingleUpdate(5.0)
        Return
    EndIf
    DBG("Registering PO3 alias event for prayer effect")
    PO3_Events_Alias.RegisterForMagicEffectApplyEx(Self, PrayerEffect as Form, True)
    DBG("PO3 alias registration complete")
EndEvent

; Fired by PO3 when PrayerEffect is applied to any ObjectReference.
; abApplied = True on application, False on removal (if supported by this PO3 version).
Function OnMagicEffectApplyEx(ObjectReference akCaster, MagicEffect akEffect, Form akSource, Bool abApplied)
    DBG("OnMagicEffectApplyEx fired caster=" + akCaster + " applied=" + abApplied)
    If akCaster != Game.GetPlayer() as ObjectReference
        Return
    EndIf
    If abApplied
        DBG("Player cast prayer — notifying QuestScript")
        QuestScript.HandlePrayerStart()
    EndIf
EndFunction

Function DBG(String msg)
    If QuestScript != None && QuestScript.bDebugMode
        Debug.Notification("[WSN-Alias] " + msg)
        Debug.Trace("[WSN-Alias] " + msg, 0)
    EndIf
EndFunction
