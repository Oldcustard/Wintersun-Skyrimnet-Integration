Scriptname WSN_SkyrimNet_PlayerAliasScript Extends ReferenceAlias

; Filled with the player. Uses PO3 Papyrus Extender's alias-based event registration
; to detect when the Wintersun prayer MagicEffect is applied to the player, and when
; any shrine request effect fires (for optional shrine communion feature).

WSN_SkyrimNet_QuestScript Property QuestScript Auto
MagicEffect Property PrayerEffect Auto   ; 00A839:Wintersun - Faiths of Skyrim.esp

MagicEffect[] ShrineRequestEffects

Event OnInit()
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
    If QuestScript.GetAllowShrineCommunion()
        InitShrineEffects()
    EndIf
    DBG("PO3 alias registration complete")
EndEvent

Function InitShrineEffects()
    String esp = "Wintersun - Faiths of Skyrim.esp"
    ShrineRequestEffects = New MagicEffect[52]
    ShrineRequestEffects[0]  = Game.GetFormFromFile(0x00F94C, esp) as MagicEffect  ; Julianos
    ShrineRequestEffects[1]  = Game.GetFormFromFile(0x019B6F, esp) as MagicEffect  ; Syrabane
    ShrineRequestEffects[2]  = Game.GetFormFromFile(0x065BFA, esp) as MagicEffect  ; Magnus
    ShrineRequestEffects[3]  = Game.GetFormFromFile(0x06AD10, esp) as MagicEffect  ; Jephre
    ShrineRequestEffects[4]  = Game.GetFormFromFile(0x06AD15, esp) as MagicEffect  ; Mara
    ShrineRequestEffects[5]  = Game.GetFormFromFile(0x065C03, esp) as MagicEffect  ; Meridia
    ShrineRequestEffects[6]  = Game.GetFormFromFile(0x07F169, esp) as MagicEffect  ; Azura
    ShrineRequestEffects[7]  = Game.GetFormFromFile(0x07F165, esp) as MagicEffect  ; Talos
    ShrineRequestEffects[8]  = Game.GetFormFromFile(0x08E493, esp) as MagicEffect  ; Akatosh
    ShrineRequestEffects[9]  = Game.GetFormFromFile(0x08E49C, esp) as MagicEffect  ; Dibella
    ShrineRequestEffects[10] = Game.GetFormFromFile(0x0935AE, esp) as MagicEffect  ; Phynaster
    ShrineRequestEffects[11] = Game.GetFormFromFile(0x0986CB, esp) as MagicEffect  ; Mehrunes Dagon
    ShrineRequestEffects[12] = Game.GetFormFromFile(0x09D7FE, esp) as MagicEffect  ; Vaermina
    ShrineRequestEffects[13] = Game.GetFormFromFile(0x09D7EA, esp) as MagicEffect  ; Zenithar
    ShrineRequestEffects[14] = Game.GetFormFromFile(0x09D7EB, esp) as MagicEffect  ; Boethiah
    ShrineRequestEffects[15] = Game.GetFormFromFile(0x0C60B1, esp) as MagicEffect  ; Nocturnal
    ShrineRequestEffects[16] = Game.GetFormFromFile(0x0C609B, esp) as MagicEffect  ; Molag Bal
    ShrineRequestEffects[17] = Game.GetFormFromFile(0x0B1C6F, esp) as MagicEffect  ; Kynareth
    ShrineRequestEffects[18] = Game.GetFormFromFile(0x0C60AD, esp) as MagicEffect  ; Mephala
    ShrineRequestEffects[19] = Game.GetFormFromFile(0x0A2946, esp) as MagicEffect  ; Arkay
    ShrineRequestEffects[20] = Game.GetFormFromFile(0x0C60B9, esp) as MagicEffect  ; Sanguine
    ShrineRequestEffects[21] = Game.GetFormFromFile(0x0C60C8, esp) as MagicEffect  ; Malacath
    ShrineRequestEffects[22] = Game.GetFormFromFile(0x0F8C19, esp) as MagicEffect  ; Stendarr
    ShrineRequestEffects[23] = Game.GetFormFromFile(0x0F8C16, esp) as MagicEffect  ; Auriel
    ShrineRequestEffects[24] = Game.GetFormFromFile(0x0FDD39, esp) as MagicEffect  ; Peryite
    ShrineRequestEffects[25] = Game.GetFormFromFile(0x149E79, esp) as MagicEffect  ; Hircine
    ShrineRequestEffects[26] = Game.GetFormFromFile(0x0F8C23, esp) as MagicEffect  ; Xarxes
    ShrineRequestEffects[27] = Game.GetFormFromFile(0x149E7D, esp) as MagicEffect  ; Shor
    ShrineRequestEffects[28] = Game.GetFormFromFile(0x149E8C, esp) as MagicEffect  ; Hermaeus Mora
    ShrineRequestEffects[29] = Game.GetFormFromFile(0x0E476D, esp) as MagicEffect  ; Clavicus Vile
    ShrineRequestEffects[30] = Game.GetFormFromFile(0x135A17, esp) as MagicEffect  ; Namira
    ShrineRequestEffects[31] = Game.GetFormFromFile(0x149E84, esp) as MagicEffect  ; Jyggalag
    ShrineRequestEffects[32] = Game.GetFormFromFile(0x0F8C0D, esp) as MagicEffect  ; Trinimac
    ShrineRequestEffects[33] = Game.GetFormFromFile(0x25B909, esp) as MagicEffect  ; Sheogorath
    ShrineRequestEffects[34] = Game.GetFormFromFile(0x107FDC, esp) as MagicEffect  ; Sithis
    ShrineRequestEffects[35] = Game.GetFormFromFile(0x1266D9, esp) as MagicEffect  ; Z'en
    ShrineRequestEffects[36] = Game.GetFormFromFile(0x1E1F23, esp) as MagicEffect  ; Satakal
    ShrineRequestEffects[37] = Game.GetFormFromFile(0x1E1F38, esp) as MagicEffect  ; Tall Papa
    ShrineRequestEffects[38] = Game.GetFormFromFile(0x1E1F33, esp) as MagicEffect  ; the HoonDing
    ShrineRequestEffects[39] = None                                                 ; (unused)
    ShrineRequestEffects[40] = Game.GetFormFromFile(0x1F12BD, esp) as MagicEffect  ; the Animal Gods
    ShrineRequestEffects[41] = Game.GetFormFromFile(0x26AC27, esp) as MagicEffect  ; Baan Dar
    ShrineRequestEffects[42] = Game.GetFormFromFile(0x1E7054, esp) as MagicEffect  ; Ebonarm
    ShrineRequestEffects[43] = Game.GetFormFromFile(0x1CDAFE, esp) as MagicEffect  ; Rajhin
    ShrineRequestEffects[44] = Game.GetFormFromFile(0x1CDAF8, esp) as MagicEffect  ; Riddle'Thar
    ShrineRequestEffects[45] = Game.GetFormFromFile(0x1CDAE4, esp) as MagicEffect  ; Morwha
    ShrineRequestEffects[46] = Game.GetFormFromFile(0x24C5DE, esp) as MagicEffect  ; Leki
    ShrineRequestEffects[47] = Game.GetFormFromFile(0x24C5E1, esp) as MagicEffect  ; the Hist
    ShrineRequestEffects[48] = Game.GetFormFromFile(0x24C5DD, esp) as MagicEffect  ; St. Alessia
    ShrineRequestEffects[49] = Game.GetFormFromFile(0x24C5DC, esp) as MagicEffect  ; Mannimarco
    ShrineRequestEffects[50] = Game.GetFormFromFile(0x3EBD8F, esp) as MagicEffect  ; the All-Maker
    ShrineRequestEffects[51] = Game.GetFormFromFile(0x3EBD8D, esp) as MagicEffect  ; the Magna-Ge
    Int i = 0
    While i < ShrineRequestEffects.Length
        If ShrineRequestEffects[i] != None
            PO3_Events_Alias.RegisterForMagicEffectApplyEx(Self, ShrineRequestEffects[i] as Form, True)
        EndIf
        i += 1
    EndWhile
    DBG("InitShrineEffects: registered shrine effects")
EndFunction

; Fired by PO3 when PrayerEffect or a shrine request effect is applied to the player.
Function OnMagicEffectApplyEx(ObjectReference akCaster, MagicEffect akEffect, Form akSource, Bool abApplied)
    DBG("OnMagicEffectApplyEx fired applied=" + abApplied)
    If !abApplied
        Return
    EndIf
    ; Prayer: player self-casts
    If akEffect == PrayerEffect
        If akCaster == Game.GetPlayer() as ObjectReference
            DBG("Player cast prayer — notifying QuestScript")
            QuestScript.HandlePrayerStart()
        EndIf
        Return
    EndIf
    ; Shrine request: cast on player from shrine (caster is not the player)
    If QuestScript.GetAllowShrineCommunion()
        QuestScript.HandleShrineEffectApplied(akEffect)
    EndIf
EndFunction

Function DBG(String msg)
    If QuestScript != None && QuestScript.GetDebugMode()
        Debug.Notification("[WSN-Alias] " + msg)
        Debug.Trace("[WSN-Alias] " + msg, 0)
    EndIf
EndFunction
