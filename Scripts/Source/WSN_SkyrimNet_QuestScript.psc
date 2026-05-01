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
String[] WSN_DeityDomain
String[] WSN_DeityTenets
String[] WSN_DeityBoons
Bool Property bInitialized = False Auto Hidden
Bool Property bPrayerActive = False Auto Hidden
Bool Property bShrineCommunionActive = False Auto Hidden
Int Property ActiveDeityWorshipID = -1 Auto Hidden

; ---------------------------------------------------------------------------
; Init — defer until game is fully loaded, register NPC
; ---------------------------------------------------------------------------

Event OnInit()
    InitDeityVoices()
    InitDeityLore()
    RegisterForSingleUpdate(3.0)
EndEvent

Event OnUpdate()
    If !bInitialized
        InitDeityVoices()
        InitDeityLore()
        If IsWintersunLoaded()
            DBG("Init: Wintersun loaded, registering world knowledge")
            RegisterDeityWorldKnowledge()
            SkyrimNetApi.DisableVirtualNPC(VIRTUAL_NPC_NAME)
            bInitialized = True
            DBG("Init: complete")
        Else
            DBG("Init: Wintersun not loaded, retrying in 5s")
            RegisterForSingleUpdate(5.0)
        EndIf
        Return
    EndIf

    ; Prayer end detection: poll every 5s while prayer is active
    If bPrayerActive
        MagicEffect prayerEffect = GetPrayerEffect()
        If prayerEffect != None && Game.GetPlayer().HasMagicEffect(prayerEffect)
            RegisterForSingleUpdate(5.0)
        Else
            HandlePrayerEnd()
        EndIf
        Return
    EndIf

    ; Shrine communion timer fired — end communion
    If bShrineCommunionActive
        HandleShrineWorshipEnd()
        Return
    EndIf
EndEvent

; ---------------------------------------------------------------------------
; Prayer start — called by WSN_SkyrimNet_PlayerAliasScript
; ---------------------------------------------------------------------------

Function HandlePrayerStart()
    DBG("HandlePrayerStart called")

    If bShrineCommunionActive
        DBG("HandlePrayerStart: cancelling shrine communion for prayer")
        HandleShrineWorshipEnd()
    EndIf

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
    ActiveDeityWorshipID = worshipID
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
    ActiveDeityWorshipID = -1
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
; Lore initialization — indexed by worshipID (0-51)
; Data for world knowledge injection (domain, tenets, boons)
; ---------------------------------------------------------------------------

Function InitDeityLore()
    WSN_DeityDomain = New String[52]
    WSN_DeityTenets = New String[52]
    WSN_DeityBoons = New String[52]

    WSN_DeityDomain[0]  = "Justice, logic, history, scholarship, contradiction"
    WSN_DeityTenets[0]  = "Master the skills of the Mage. Strive to raise your Magicka. Never openly break the laws of Skyrim."
    WSN_DeityBoons[0]   = "Follower: Spells cost less to cast. Devotee: Spells and scrolls are more effective."

    WSN_DeityDomain[1]  = "Magic, arcane lore, protection of knowledge"
    WSN_DeityTenets[1]  = "Read books that teach new skills. Study a wide variety of spells. High Elves are most deserving of favor."
    WSN_DeityBoons[1]   = "Follower: More likely to find spell tomes and scrolls on killed enemies. Devotee: Learn all Mage skills faster."

    WSN_DeityDomain[2]  = "Magic, the sun, arcane knowledge"
    WSN_DeityTenets[2]  = "Practice magic successfully while praying. Safeguard the Eye of Magnus. Create enchanted items."
    WSN_DeityBoons[2]   = "Follower: Magicka does not regenerate, but praying rapidly replenishes it and spells cost less. Devotee: Praying auto-casts beneficial self-targeted spells for free."

    WSN_DeityDomain[3]  = "The Green, nature, the songs of nature, the Spinners"
    WSN_DeityTenets[3]  = "Explore new locations. Read the stories of others. Hunt animals. Wood Elves are most deserving of favor."
    WSN_DeityBoons[3]   = "Follower: Movement speed increased out of combat. Devotee: Stamina regenerates very quickly out of combat, praying brings clear weather."

    WSN_DeityDomain[4]  = "Love, compassion, marriage, fertility"
    WSN_DeityTenets[4]  = "Be married. Own one or more houses. Be generous to beggars and children. Receive the blessing of Lover's Comfort. Never openly break the laws of Skyrim."
    WSN_DeityBoons[4]   = "Follower: Pray to cure all diseases affecting you or allies. Devotee: Living allies within 40 feet are healed per second."

    WSN_DeityDomain[5]  = "Light, beauty, energy, initiative, the undead (enemy)"
    WSN_DeityTenets[5]  = "Slay the undead. Never summon the undead or become one. High Elves and those skilled in Restoration are most deserving of favor."
    WSN_DeityBoons[5]   = "Follower: Attacks and spells are more effective against undead. Devotee: Activate an undead opponent to call down a solar strike."

    WSN_DeityDomain[6]  = "Dusk and dawn, magic, vanity, the transition between night and day"
    WSN_DeityTenets[6]  = "Trap souls. Explore new locations. Pray only at twilight, preferably outside. Dark Elves and those skilled in Illusion are most deserving of favor."
    WSN_DeityBoons[6]   = "Follower: Nearby foes suffer reduced magic resistance. Devotee: Paralyze a weakened opponent in combat."

    WSN_DeityDomain[7]  = "War, governance, the empires of Men"
    WSN_DeityTenets[7]  = "Bring the Civil War to a conclusion. Learn the dragon tongue. Absorb dragon souls. Slay elves and the Thalmor. Never openly break the laws of Skyrim."
    WSN_DeityBoons[7]   = "Follower: Attacks and shouts are more effective against elves. Devotee: Shout cooldown halved when enemies die nearby."

    WSN_DeityDomain[8]  = "Time, endurance, invincibility, everlasting legitimacy"
    WSN_DeityTenets[8]  = "Fulfill your destiny by saving Tamriel. Raise your character level. Absorb dragon souls. Never openly break the laws of Skyrim."
    WSN_DeityBoons[8]   = "Follower: Attacks, spells and shouts are more effective against dragons. Devotee: Praying resets the cooldown of your most recently used shout and power."

    WSN_DeityDomain[9]  = "Beauty, love, arts, music, aesthetics"
    WSN_DeityTenets[9]  = "Persuade others. Receive the blessing of Lover's Comfort. Find a new Sybil for the Temple of Dibella. Pray only in the nude. Never openly break the laws of Skyrim."
    WSN_DeityBoons[9]   = "Follower: Lover's Comfort also improves all skills. Devotee: Activate a person in combat to make them unequip items and follow you."

    WSN_DeityDomain[10] = "The protection of the Summerset Isles, endurance, patience"
    WSN_DeityTenets[10] = "Explore new locations. Find the standing stones of Skyrim. Harvest the fruits of nature. Bretons are most deserving of favor."
    WSN_DeityBoons[10]  = "Follower: Health, Magicka and Stamina regenerate faster when standing still. Devotee: Teleport back to the last location where you prayed."

    WSN_DeityDomain[11] = "Destruction, change, revolution, energy, ambition"
    WSN_DeityTenets[11] = "Slay people who stand in your way. Defile the shrines of enemies. Those skilled in Destruction are most deserving of favor."
    WSN_DeityBoons[11]  = "Follower: Daedric fire drains Magicka while praying; stop at low Magicka for more favor. Devotee: Nearby foes burn and explode on death."

    WSN_DeityDomain[12] = "Dreams, nightmares, evil omens, psychological terror"
    WSN_DeityTenets[12] = "Witness the death of those under your mind affecting spells. Kill people in their sleep. Sleep to pray. Those skilled in Illusion are most deserving of favor."
    WSN_DeityBoons[12]  = "Follower: Mind affecting illusion spells work on higher level targets. Devotee: Activate a sleeping person to summon an illusion companion."

    WSN_DeityDomain[13] = "Work, commerce, crafts, communication"
    WSN_DeityTenets[13] = "Invest in stores and merchants. Seek out skill training. Make weapons and armor. Never openly break the laws of Skyrim."
    WSN_DeityBoons[13]  = "Follower: Learn Smithing, Alchemy and Enchanting faster and they are more effective. Devotee: Pray to buy and sell items directly."

    WSN_DeityDomain[14] = "Deceit, conspiracy, secret plots, assassination, treason"
    WSN_DeityTenets[14] = "Murder the innocent. Strike unseen with sneak attacks. Poison your weapons. Dark Elves are most deserving of favor."
    WSN_DeityBoons[14]  = "Follower: Attacks deal more damage when fighting only one opponent. Devotee: Invoke Daedric Invisibility; breaking it with a sneak attack deals extra damage."

    WSN_DeityDomain[15] = "Night, darkness, luck, shadows, the unknown"
    WSN_DeityTenets[15] = "Pickpocket Mysterious Coinpurses. Pick locks. Pray only at night, preferably in darkness. Those skilled in Sneak are most deserving of favor."
    WSN_DeityBoons[15]  = "Follower: Praying clears non-violent crime bounties. Devotee: Astrally observe the nearest person within 300 feet."

    WSN_DeityDomain[16] = "Domination, enslavement, the harvesting of souls"
    WSN_DeityTenets[16] = "Slay people who stand in your way. Trap souls. Live as a vampire and never seek a cure. Those skilled in Destruction are most deserving of favor."
    WSN_DeityBoons[16]  = "Follower: Absorb Magicka and Stamina from nearby enemies in combat. Devotee: Banish a person in combat to Coldharbour."

    WSN_DeityDomain[17] = "Air, wind, elements, travel, birds"
    WSN_DeityTenets[17] = "Explore new locations. Strive to raise your Stamina. Receive the Voice of the Sky. Pray only outdoors. Never openly break the laws of Skyrim."
    WSN_DeityBoons[17]  = "Follower: Movement speed increased in combat. Devotee: Pray to summon a sacred Sabre Cat mount."

    WSN_DeityDomain[18] = "Sex, lies, secret murder, obscure plots"
    WSN_DeityTenets[18] = "Poison your weapons. Strike unseen with sneak attacks. Intimidate the weak. Dark Elves are most deserving of favor."
    WSN_DeityBoons[18]  = "Follower: Sneak attacks deal more damage from behind. Devotee: Seize control of the nearest person to fight for you."

    WSN_DeityDomain[19] = "Life, death, the cycle of souls, burial rites"
    WSN_DeityTenets[19] = "Slay the undead and their summoners. Perform Arkay's Rites. Never openly break the laws of Skyrim. Never summon the undead or become one."
    WSN_DeityBoons[19]  = "Follower: Regenerate Health based on missing Health. Devotee: Revive with full Health upon taking fatal damage."

    WSN_DeityDomain[20] = "Hedonism, debauchery, dark reveries"
    WSN_DeityTenets[20] = "Make mischief and commit crimes worthy of a bounty. Indulge in mead, wine and ale. Find your own way out of jail."
    WSN_DeityBoons[20]  = "Follower: Health, Magicka and Stamina regenerate faster while a potion or food is active. Devotee: Pray in combat to force nearby hostiles to dance."

    WSN_DeityDomain[21] = "The spurned, the ostracised, the betrayed, the bloody oath"
    WSN_DeityTenets[21] = "Defeat epic foes. Improve weapons and armor. Never commit a crime against the strongholds. Orcs and those skilled in Smithing are most deserving of favor."
    WSN_DeityBoons[21]  = "Follower: Power attacks deal more damage. Devotee: When enemies die nearby, their killer is healed by overkill damage dealt."

    WSN_DeityDomain[22] = "Mercy, charity, well-earned luck, righteous might"
    WSN_DeityTenets[22] = "Clear dungeons of evil. Slay daedra and the undead. Complete side quests for the people of Skyrim. Never openly break the laws of Skyrim."
    WSN_DeityBoons[22]  = "Follower: Take less attack damage from daedra and undead. Devotee: Spend favor to gain improved attack, defense and healing."

    WSN_DeityDomain[23] = "Time, the light of the heavens, the Elven aspects of Akatosh"
    WSN_DeityTenets[23] = "Fulfill your destiny by saving Tamriel. Master all skills. Become Champion at the sacred Chantry. High Elves are most deserving of favor."
    WSN_DeityBoons[23]  = "Follower: Learn all skills faster. Devotee: Level 100 skills are improved further."

    WSN_DeityDomain[24] = "Tasks, pestilence, order among the lowest of Daedra"
    WSN_DeityTenets[24] = "Catch as many diseases as you can. Accept Gifts of pestilence. Pray only while diseased. Never accept a cure for your afflictions."
    WSN_DeityBoons[24]  = "Follower: Learn all skills faster. Devotee: Inflict all your diseases on a living opponent plus disease damage per second."

    WSN_DeityDomain[25] = "The hunt, sport, the Great Game, the Chase"
    WSN_DeityTenets[25] = "Slay the living in open combat, especially those stronger. Live as a werewolf. Pray in the wild. Those skilled in Light Armor are most deserving of favor."
    WSN_DeityBoons[25]  = "Follower: Double attack damage to living targets with low Health. Devotee: Invoke a Hunt to reveal and expose nearby living targets."

    WSN_DeityDomain[26] = "Ancestry, secret knowledge, the scribe of Auri-El"
    WSN_DeityTenets[26] = "Explore new locations. Read the stories of others. Study a wide variety of spells. Bretons are most deserving of favor."
    WSN_DeityBoons[26]  = "Follower: Reading a Skill Book while praying grants an extra Skill Point. Devotee: Ascend in a trance, revealing all characters in a large radius."

    WSN_DeityDomain[27] = "The underworld, the dead, mankind, Sovngarde"
    WSN_DeityTenets[27] = "Fulfill your destiny by saving Tamriel. Master the skills of the Warrior. Slay elves. Defeat epic foes."
    WSN_DeityBoons[27]  = "Follower: Take less damage and stagger from elves. Devotee: When entering combat with a mighty foe, a Shield-Thane assists you."

    WSN_DeityDomain[28] = "Knowledge, memory, the scrying of the tides of Fate"
    WSN_DeityTenets[28] = "Read Eldritch Pages and bind them into Eldritch Tomes. Read books that teach new skills. Become Champion at the Summit of Apocrypha."
    WSN_DeityBoons[28]  = "Follower: Find Eldritch Pages on corpses; bind into Tomes that improve magic and shouts. Devotee: Pray to permanently raise a skill."

    WSN_DeityDomain[29] = "Power, wishes, trickery, bargains"
    WSN_DeityTenets[29] = "Pray to accept a Pact and complete it as written within the allotted time. Never break or ignore Pacts."
    WSN_DeityBoons[29]  = "Follower: Conjuration spells last longer. Devotee: Pray to make a Wish, permanently gaining an additional perk point."

    WSN_DeityDomain[30] = "Ancient darkness, revulsion, the foul, cannibalism"
    WSN_DeityTenets[30] = "Murder the innocent. Poison your weapons. Eat the corpses of the dead with the Ring. Be generous to beggars."
    WSN_DeityBoons[30]  = "Follower: Reduces Poison Resistance of all nearby. Devotee: Poisoning a person attracts insects, reducing armor and dealing disease damage."

    WSN_DeityDomain[31] = "Order, logic, deductive reasoning, natural law"
    WSN_DeityTenets[31] = "Activate Obelisks of Order. Clear dungeons of evil. Slay daedra. Never serve Sheogorath. Those skilled in Heavy Armor are most deserving of favor."
    WSN_DeityBoons[31]  = "Follower: Obelisks of Order grant Health, Magicka and Stamina. Devotee: Trap an opponent in an inert but invulnerable state."

    WSN_DeityDomain[32] = "Strength, honour, the warrior Aedra"
    WSN_DeityTenets[32] = "Slay humans. Defeat epic foes. Never accept Boethiah's blessing or serve her. Those skilled in Two-Handed are most deserving of favor."
    WSN_DeityBoons[32]  = "Follower: Attacks deal more damage to humans. Devotee: Become ethereal and invulnerable until your next attack."

    WSN_DeityDomain[33] = "Madness, creativity, the mind"
    WSN_DeityTenets[33] = "Pray often and receive Touch of Madness. Never disrespect cheese."
    WSN_DeityBoons[33]  = "Follower: Praying grants a random Touch of Madness. Devotee: Receive a Touch of Madness whenever you enter combat."

    WSN_DeityDomain[34] = "The Void, change, entropy, the Dark Brotherhood"
    WSN_DeityTenets[34] = "Murder the innocent. Pray while sacrificing a Human Heart or Flesh. Send victims to the Void. Argonians are most deserving of favor."
    WSN_DeityBoons[34]  = "Follower: Harder to detect nearby; chance to find Human Hearts on kills. Devotee: Turn a door into a Void portal that pulls in and kills unaware targets."

    WSN_DeityDomain[35] = "Toil, payment in kind, the merchant lord"
    WSN_DeityTenets[35] = "Bribe people as needed. Harvest the fruits of nature. Eat as much food as you want. Those skilled in Speech are most deserving of favor."
    WSN_DeityBoons[35]  = "Follower: Beneficial potions and food last longer and are better if consumed while praying. Devotee: Pray to open unlimited extradimensional storage."

    WSN_DeityDomain[36] = "The world-eating serpent, the beginning and end of all things"
    WSN_DeityTenets[36] = "Fulfill your destiny by saving Tamriel. Strive to raise your Health. Absorb dragon souls."
    WSN_DeityBoons[36]  = "Follower: Shrine blessings from other gods are more effective and last longer. Devotee: Pray to become reborn, moving points between attributes."

    WSN_DeityDomain[37] = "The overseer of all spirits, the highest of the Yokudan gods, endurance"
    WSN_DeityTenets[37] = "Touch the Fractures scattered around Skyrim. Create enchanted items. Those skilled in Enchanting are most deserving of favor."
    WSN_DeityBoons[37]  = "Follower: Weapon enchantments drain less charge. Devotee: On death, enter ethereal state; if combat ends in time, revive."

    WSN_DeityDomain[38] = "Perseverance, the spirit of going forward, movement against all odds"
    WSN_DeityTenets[38] = "Slay your foes in open combat, especially those stronger. Those skilled in One-Handed are most deserving of favor."
    WSN_DeityBoons[38]  = "Follower: Staggering an opponent reduces their armor. Devotee: Chance to resist stagger from attacks and bashes."

    WSN_DeityDomain[39] = ""
    WSN_DeityTenets[39] = ""
    WSN_DeityBoons[39]  = ""

    WSN_DeityDomain[40] = "The old animal god traditions; the Bear, the Crow, the Fox, the Hawk, the Snake, the Wolf"
    WSN_DeityTenets[40] = "Slay people who stand in your way. Absorb dragon souls. Assume powers through prayer. Nords are most deserving of favor."
    WSN_DeityBoons[40]  = "Follower: Sacrifice gemstones while praying to assume animal god powers. Devotee: Assume the powers of the Dragon."

    WSN_DeityDomain[41] = "Thieves, the bandit, clever tricks, the clever merchant"
    WSN_DeityTenets[41] = "Pick locks and pockets successfully. Khajiit and those skilled in Archery are most deserving of favor."
    WSN_DeityBoons[41]  = "Follower: Buying from other races costs more, but pickpocketing is easier. Devotee: Put skooma in people's inventory, then pray to ignite them."

    WSN_DeityDomain[42] = "War, warriors, the Black Knight"
    WSN_DeityTenets[42] = "Slay daedra. Defeat epic foes. Complete miscellaneous quests. Those skilled in Block are most deserving of favor."
    WSN_DeityBoons[42]  = "Follower: Attacks are more effective against daedra and their summoners. Devotee: Reduces armor of nearby enemies; you gain the total amount."

    WSN_DeityDomain[43] = "Thieves, rogues, the master thief, luck"
    WSN_DeityTenets[43] = "Explore new locations. Bribe people. Pick locks. Those skilled in Lockpicking are most deserving of favor."
    WSN_DeityBoons[43]  = "Follower: Find additional gold in containers. Devotee: Pray to break a lock within 20 feet."

    WSN_DeityDomain[44] = "The cosmic order of the moons, the Two-Moons Dance, Khajiiti faith"
    WSN_DeityTenets[44] = "Master skills of the Warrior, Thief and Mage equally. Strive to raise Health, Magicka and Stamina. Pray only at night."
    WSN_DeityBoons[44]  = "Follower: All skills improved. Devotee: An ancient Mane grants a blessing appropriate for upcoming challenges."

    WSN_DeityDomain[45] = "Love, fertility, the mother goddess of the Yokudan pantheon"
    WSN_DeityTenets[45] = "Be married. Receive the blessing of Lover's Comfort. Harvest the fruits of nature. Eat as much food as you want."
    WSN_DeityBoons[45]  = "Follower: Praying restores Health for you and nearby allies. Devotee: Praying blesses you with enchanted fruit."

    WSN_DeityDomain[46] = "Sword-craft, the sublime art of the blade, the Saint of the Spirit Sword"
    WSN_DeityTenets[46] = "Bring the Civil War to a conclusion. Make and improve weapons. Master the skills of the Warrior."
    WSN_DeityBoons[46]  = "Follower: Power attacks ignore armor. Devotee: Spend favor to gain increased melee damage for 10 minutes."

    WSN_DeityDomain[47] = "The ancient trees of Black Marsh, Argonian souls, the Hist-sap"
    WSN_DeityTenets[47] = "Explore new locations. Slay daedra. Pray only outdoors. Never summon a daedra."
    WSN_DeityBoons[47]  = "Follower: Pray to gain a bonus to all attributes. Devotee: Absorb Magicka and Stamina of dead creatures and people nearby."

    WSN_DeityDomain[48] = "The first Empress of Men, freedom, salvation, the Alessian Order"
    WSN_DeityTenets[48] = "Have a follower at your side. Slay elves. Receive the blessing of a Divine."
    WSN_DeityBoons[48]  = "Follower: Pray for a Divine blessing of your choice. Devotee: Talk to non-hostile humans to make them a friend and potential follower."

    WSN_DeityDomain[49] = "Necromancy, undeath, the Worm Cult"
    WSN_DeityTenets[49] = "Trap souls. Pray only at night. Never accept Arkay's blessing. Those skilled in Conjuration are most deserving of favor."
    WSN_DeityBoons[49]  = "Follower: Undead conjured at night last longer. Devotee: Allied conjured undead deal more damage and regenerate Health."

    WSN_DeityDomain[50] = "The Skaal concept of the divine force that created all things"
    WSN_DeityTenets[50] = "Cleanse the All-Maker Stones. Hunt animals. Explore new locations. Pray only outdoors. Nords are most deserving of favor."
    WSN_DeityBoons[50]  = "Follower: Healing spells restore more Health. Devotee: After using an All-Maker Stone power, pray to have it restored."

    WSN_DeityDomain[51] = "Stars, the starry heavens, Magnus's kin who fled Mundus"
    WSN_DeityTenets[51] = "Create enchanted items. Explore new locations. Pray only outdoors at night. High Elves and those skilled in Alteration are most deserving of favor."
    WSN_DeityBoons[51]  = "Follower: Gain weapon charge per second. Devotee: Let the Magna-Ge carry you to a location within line of sight."

    DBG("InitDeityLore: initialized 52 deity lore entries")
EndFunction

; ---------------------------------------------------------------------------
; World knowledge registration — inject deity lore into SkyrimNet
; ---------------------------------------------------------------------------

Function RegisterDeityWorldKnowledge()
    wsn_trackerquest_quest tracker = GetTracker()
    If tracker == None
        DBG("RegisterDeityWorldKnowledge: tracker is None, skipping")
        Return
    EndIf
    Int i = 0
    While i < 52
        String deityName = tracker.WSN_DeityName[i]
        If deityName != "" && WSN_DeityDomain[i] != ""
            String content = deityName + "'s domain is " + WSN_DeityDomain[i] + ". The tenets of " + deityName + " worship are: " + WSN_DeityTenets[i] + ". The boons granted by " + deityName + " are: " + WSN_DeityBoons[i]
            String condition = "get_entity_display_name(actorUUID) == \"" + deityName + "\""
            Int result = SkyrimNetApi.AddWorldKnowledge(content, condition, true, 0.9, "WSN_" + deityName)
            If result > 0
                DBG("Registered world knowledge for " + deityName + " (id=" + result + ")")
            Else
                DBG("Failed to register world knowledge for " + deityName)
            EndIf
        EndIf
        i += 1
    EndWhile
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

Bool Function GetAllowShrineCommunion()
    Return SkyrimNetApi.GetConfigBool("Plugin_Wintersun Integration", "allow_shrine_communion", True)
EndFunction

Float Function GetShrineCommunionDuration()
    String val = SkyrimNetApi.GetConfigString("Plugin_Wintersun Integration", "shrine_communion_duration", "120")
    If val == ""
        Return 120.0
    EndIf
    Return val as Float
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
; Shrine communion
; ---------------------------------------------------------------------------

Function HandleShrineEffectApplied(MagicEffect akEffect)
    If bPrayerActive || bShrineCommunionActive
        DBG("HandleShrineEffectApplied: communion already active, skipping")
        Return
    EndIf
    wsn_trackerquest_quest tracker = GetTracker()
    If tracker == None
        Return
    EndIf
    ; Extract deity name: "Do you want to worship [Name]?" → "[Name]"
    String effectName = akEffect.GetName()
    String deityName = StringUtil.Substring(effectName, 23)
    Int nameLen = StringUtil.GetLength(deityName)
    If nameLen > 0 && StringUtil.GetNthChar(deityName, nameLen - 1) == "?"
        deityName = StringUtil.Substring(deityName, 0, nameLen - 1)
    EndIf
    ; Reverse-lookup worshipID
    Int worshipID = -1
    Int i = 0
    While i < tracker.WSN_DeityName.Length
        If tracker.WSN_DeityName[i] == deityName
            worshipID = i
            i = tracker.WSN_DeityName.Length
        EndIf
        i += 1
    EndWhile
    DBG("HandleShrineEffectApplied: deity=" + deityName + " worshipID=" + worshipID as String)
    If worshipID == -1
        DBG("HandleShrineEffectApplied: deity not found in name array")
        Return
    EndIf
    ; Skip if this is the player's followed deity (prayer path handles it)
    If worshipID == tracker.worshipID
        DBG("HandleShrineEffectApplied: own deity shrine, skipping (prayer path)")
        Return
    EndIf
    HandleShrineWorshipStart(worshipID)
EndFunction

Function HandleShrineWorshipStart(Int shrineWorshipID)
    wsn_trackerquest_quest tracker = GetTracker()
    If tracker == None
        Return
    EndIf
    String deityName = tracker.WSN_DeityName[shrineWorshipID]
    If deityName == ""
        Return
    EndIf
    String deityVoice = ResolveVoice(shrineWorshipID)
    SkyrimNetApi.UpdateVirtualNPC(VIRTUAL_NPC_NAME, deityName, deityVoice, "", "")
    DBG("HandleShrineWorshipStart: enabling virtual NPC for " + deityName)
    ActiveDeityWorshipID = shrineWorshipID
    SkyrimNetApi.EnableVirtualNPC(VIRTUAL_NPC_NAME)
    bShrineCommunionActive = True
    RegisterForSingleUpdate(GetShrineCommunionDuration())
EndFunction

Function HandleShrineWorshipEnd()
    DBG("HandleShrineWorshipEnd: disabling virtual NPC")
    bShrineCommunionActive = False
    ActiveDeityWorshipID = -1
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
    If GetDebugMode()
        Debug.Notification("[WSN] " + msg)
        Debug.Trace("[WSN] " + msg, 0)
    EndIf
EndFunction
