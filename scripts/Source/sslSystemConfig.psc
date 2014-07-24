scriptname sslSystemConfig extends sslSystemLibrary

; ------------------------------------------------------- ;
; --- System Resources                                --- ;
; ------------------------------------------------------- ;

SexLabFramework property SexLab auto

int function GetVersion()
	return SexLabUtil.GetVersion()
endFunction

string function GetStringVer()
	return SexLabUtil.GetStringVer()
endFunction

bool bDebugMode
bool property DebugMode hidden
	bool function get()
		return bDebugMode
	endFunction
	function set(bool value)
		bDebugMode = value
		if bDebugMode
			; MiscUtil.PrintConsole("SexLab Debug/Development Mode Activated")
			PlayerRef.AddSpell((Game.GetFormFromFile(0x073CC, "SexLab.esm") as Spell))
			PlayerRef.AddSpell((Game.GetFormFromFile(0x5FE9B, "SexLab.esm") as Spell))
		else
			; MiscUtil.PrintConsole("SexLab Debug/Development Mode Deactivated")
			PlayerRef.RemoveSpell((Game.GetFormFromFile(0x073CC, "SexLab.esm") as Spell))
			PlayerRef.RemoveSpell((Game.GetFormFromFile(0x5FE9B, "SexLab.esm") as Spell))
		endIf
	endFunction
endProperty

bool property Enabled hidden
	bool function get()
		return SexLab.Enabled
	endFunction
endProperty

Faction property AnimatingFaction auto
Faction property GenderFaction auto
Faction property ForbiddenFaction auto
Weapon property DummyWeapon auto
Armor property NudeSuit auto
Armor property CalypsStrapon auto
form[] property Strapons auto hidden

Spell property CumVaginalOralAnalSpell auto
Spell property CumOralAnalSpell auto
Spell property CumVaginalOralSpell auto
Spell property CumVaginalAnalSpell auto
Spell property CumVaginalSpell auto
Spell property CumOralSpell auto
Spell property CumAnalSpell auto

Keyword property CumOralKeyword auto
Keyword property CumAnalKeyword auto
Keyword property CumVaginalKeyword auto
Keyword property ActorTypeNPC auto

; FormList property ValidActorList auto
; FormList property NoStripList auto
; FormList property StripList auto

Furniture property BaseMarker auto
Package property DoNothing auto

Sound property OrgasmFX auto
Sound property SquishingFX auto
Sound property SuckingFX auto
Sound property SexMixedFX auto

Static property LocationMarker auto
FormList property BedsList auto
FormList property BedRollsList auto
Message property UseBed auto
Message property CleanSystemFinish auto
Message property CheckSKSE auto
Message property CheckFNIS auto
Message property CheckSkyrim auto
Message property CheckPapyrusUtil auto
Message property CheckSkyUI auto
Message property TakeThreadControl auto

Topic property LipSync auto
VoiceType property SexLabVoiceM auto
VoiceType property SexLabVoiceF auto
FormList property SexLabVoices auto
; FormList property VoicesPlayer auto ; No longer used - v1.56
SoundCategory property AudioSFX auto
SoundCategory property AudioVoice auto

; ------------------------------------------------------- ;
; --- Config Properties                               --- ;
; ------------------------------------------------------- ;

; Booleans
bool property RestrictAggressive auto hidden
bool property AllowCreatures auto hidden
bool property NPCSaveVoice auto hidden
bool property UseStrapons auto hidden
bool property RedressVictim auto hidden
bool property RagdollEnd auto hidden
bool property UseMaleNudeSuit auto hidden
bool property UseFemaleNudeSuit auto hidden
bool property UndressAnimation auto hidden
bool property UseLipSync auto hidden
bool property UseExpressions auto hidden
bool property ScaleActors auto hidden
bool property UseCum auto hidden
bool property AllowFFCum auto hidden
bool property DisablePlayer auto hidden
bool property AutoTFC auto hidden
bool property AutoAdvance auto hidden
bool property ForeplayStage auto hidden
bool property OrgasmEffects auto hidden
bool property RaceAdjustments auto hidden
bool property BedRemoveStanding auto hidden

; Integers
int property AnimProfile auto hidden
int property NPCBed auto hidden

int property Backwards auto hidden
int property AdjustStage auto hidden
int property AdvanceAnimation auto hidden
int property ChangeAnimation auto hidden
int property ChangePositions auto hidden
int property AdjustChange auto hidden
int property AdjustForward auto hidden
int property AdjustSideways auto hidden
int property AdjustUpward auto hidden
int property RealignActors auto hidden
int property MoveScene auto hidden
int property RestoreOffsets auto hidden
int property RotateScene auto hidden
int property EndAnimation auto hidden
int property ToggleFreeCamera auto hidden
int property TargetActor auto hidden

; Floats
float property CumTimer auto hidden
float property AutoSUCSM auto hidden
float property MaleVoiceDelay auto hidden
float property FemaleVoiceDelay auto hidden
float property VoiceVolume auto hidden
float property SFXDelay auto hidden
float property SFXVolume auto hidden

; Boolean Arrays
bool[] property StripMale auto hidden
bool[] property StripFemale auto hidden
bool[] property StripLeadInFemale auto hidden
bool[] property StripLeadInMale auto hidden
bool[] property StripVictim auto hidden
bool[] property StripAggressor auto hidden

; Float Array
float[] property StageTimer auto hidden
float[] property StageTimerLeadIn auto hidden
float[] property StageTimerAggr auto hidden

; Data
Actor property TargetRef auto hidden
Actor CrosshairRef

; ------------------------------------------------------- ;
; --- Config Accessors                                --- ;
; ------------------------------------------------------- ;

float function GetVoiceDelay(bool IsFemale = false, int Stage = 1, bool IsSilent = false)
	if IsSilent
		return 3.0 ; Return basic delay for loop
	endIf
	float VoiceDelay
	if IsFemale
		VoiceDelay = FemaleVoiceDelay
	else
		VoiceDelay = MaleVoiceDelay
	endIf
	if Stage > 1
		VoiceDelay -= (Stage * 0.8) + Utility.RandomFloat(-0.4, 0.4)
		if VoiceDelay < 0.8
			return Utility.RandomFloat(0.8, 1.3) ; Can't have delay shorter than animation update loop
		endIf
	endIf
	return VoiceDelay
endFunction

bool[] function GetStrip(bool IsFemale, bool IsLeadIn = false, bool IsAggressive = false, bool IsVictim = false)
	if IsLeadIn
		if IsFemale
			return StripLeadInFemale
		else
			return StripLeadInMale
		endIf
 	elseif IsAggressive
 		if IsVictim
 			return StripVictim
 		else
 			return StripAggressor
 		endIf
 	elseIf IsFemale
 		return StripFemale
 	else
 		return StripMale
 	endIf
endFunction

bool function UsesNudeSuit(bool IsFemale)
	return ((!IsFemale && UseMaleNudeSuit) || (IsFemale && UseFemaleNudeSuit))
endFunction

Form function GetStrapon()
	if Strapons.Length > 0
		return Strapons[Utility.RandomInt(0, (Strapons.Length - 1))]
	endIf
	return none
endFunction

; ------------------------------------------------------- ;
; --- Hotkeys                                         --- ;
; ------------------------------------------------------- ;

sslThreadController Control

event OnKeyDown(int keyCode)
	if !Utility.IsInMenuMode() && !UI.IsMenuOpen("Console") && !UI.IsMenuOpen("Loading Menu")
		if keyCode == ToggleFreeCamera
			ToggleFreeCamera()
		elseIf keyCode == TargetActor
			if Control != none
				DisableThreadControl(Control)
			else
				SetTargetActor()
			endIf
		endIf
	endIf
endEvent

event OnCrosshairRefChange(ObjectReference ActorRef)
	CrosshairRef = none
	if ActorRef != none
		CrosshairRef = ActorRef as Actor
	endIf
endEvent

function SetTargetActor()
	if CrosshairRef != none
		TargetRef = CrosshairRef
		Debug.Notification("SexLab Target Selected: "+TargetRef.GetLeveledActorBase().GetName())
		; Give them stats if they need it
		Stats.SeedActor(TargetRef)
		; Attempt to grab control of their animation?
		sslThreadController TargetThread = ThreadSlots.GetActorController(TargetRef)
		if TargetThread != none && !TargetThread.HasPlayer && ThreadSlots.GetActorController(PlayerRef) == none && TakeThreadControl.Show()
			GetThreadControl(TargetThread)
		endIf
	endif
endFunction

function GetThreadControl(sslThreadController TargetThread)
	if Control != none || !(TargetThread.GetState() == "Animating" || TargetThread.GetState() == "Advancing")
		Log("Failed to control thread "+TargetThread)
		return ; Control not available
	endIf
	; Set active controlled thread
	Control = TargetThread
	; Lock players movement
	PlayerRef.StopCombat()
	if PlayerRef.IsWeaponDrawn()
		PlayerRef.SheatheWeapon()
	endIf
	PlayerRef.SetFactionRank(AnimatingFaction, 1)
	ActorUtil.AddPackageOverride(PlayerRef, DoNothing, 100, 1)
	PlayerRef.EvaluatePackage()
	Game.SetPlayerAIDriven()
	; Give player control
	Control.AutoAdvance = false
	Control.HasPlayer   = true
	Control.EnableHotkeys()
	Control.HasPlayer   = false
	Log("Player has taken control of thread "+Control)
endFunction

function DisableThreadControl(sslThreadController TargetThread)
	if Control != none && TargetThread == Control
		; Release players thread control
		Control.DisableHotkeys()
		Control.AutoAdvance = true
		; Unlock players movement
		PlayerRef.RemoveFromFaction(AnimatingFaction)
		ActorUtil.RemovePackageOverride(PlayerRef, DoNothing)
		PlayerRef.EvaluatePackage()
		Game.EnablePlayerControls()
		Game.SetPlayerAIDriven(false)
		; Release the active thread
		Control = none
	endIf
endfunction

function ToggleFreeCamera()
	if Game.GetCameraState() != 3
		MiscUtil.SetFreeCameraSpeed(AutoSUCSM)
	endIf
	MiscUtil.ToggleFreeCamera()
endFunction


bool function BackwardsPressed()
	return Input.GetNumKeysPressed() > 1 && (Input.IsKeyPressed(Backwards) || (Backwards == 54 && Input.IsKeyPressed(42)) || (Backwards == 42 && Input.IsKeyPressed(54)))
endFunction

bool function AdjustStagePressed()
	return Input.GetNumKeysPressed() > 1 && (Input.IsKeyPressed(AdjustStage) || (AdjustStage == 157 && Input.IsKeyPressed(29)) || (AdjustStage == 29 && Input.IsKeyPressed(157)))
endFunction

function HotkeyCallback(sslThreadController Thread, int keyCode)

	; Advance Stage
	if keyCode == AdvanceAnimation
		Thread.AdvanceStage(BackwardsPressed())

	; Change Animation
	elseIf keyCode == ChangeAnimation
		Thread.ChangeAnimation(BackwardsPressed())

	; Forward / Backward adjustments
	elseIf keyCode == AdjustForward
		Thread.AdjustForward(BackwardsPressed(), AdjustStagePressed())

	; Up / Down adjustments
	elseIf keyCode == AdjustUpward
		Thread.AdjustUpward(BackwardsPressed(), AdjustStagePressed())

	; Left / Right adjustments
	elseIf keyCode == AdjustSideways
		Thread.AdjustSideways(BackwardsPressed(), AdjustStagePressed())

	; Rotate Scene
	elseIf keyCode == RotateScene
		Thread.RotateScene(BackwardsPressed())

	; Change Adjusted Actor
	elseIf keyCode == AdjustChange
		Thread.AdjustChange(BackwardsPressed())

	; RePosition Actors
	elseIf keyCode == RealignActors
		Thread.RealignActors()

	; Change Positions
	elseIf keyCode == ChangePositions
		Thread.ChangePositions(BackwardsPressed())

	; Restore animation offsets
	elseIf keyCode == RestoreOffsets
		Thread.RestoreOffsets()

	; Move Scene
	elseIf keyCode == MoveScene
		Thread.MoveScene()

	; EndAnimation
	elseIf keyCode == EndAnimation
		Thread.EndAnimation(true)

	endIf
endFunction

; ------------------------------------------------------- ;
; --- Strapon Functions                               --- ;
; ------------------------------------------------------- ;

form function WornStrapon(Actor ActorRef)
	int i = Strapons.Length
	while i
		i -= 1
		if ActorRef.IsEquipped(Strapons[i])
			return Strapons[i]
		endIf
	endWhile
	return none
endFunction

bool function HasStrapon(Actor ActorRef)
	return WornStrapon(ActorRef) != none
endFunction

form function PickStrapon(Actor ActorRef)
	form Strapon = WornStrapon(ActorRef)
	if Strapon != none
		return Strapon
	endIf
	return Strapons[Utility.RandomInt(0, Strapons.Length - 1)]
endFunction

form function EquipStrapon(Actor ActorRef)
	form Strapon = PickStrapon(ActorRef)
	if Strapon != none
		ActorRef.AddItem(Strapon, 1, true)
		ActorRef.EquipItem(Strapon, false, true)
	endIf
	return Strapon
endFunction

function UnequipStrapon(Actor ActorRef)
	int i = Strapons.Length
	while i
		i -= 1
		if ActorRef.IsEquipped(Strapons[i])
			ActorRef.UnequipItem(Strapons[i], false, true)
			ActorRef.RemoveItem(Strapons[i], 1, true)
		endIf
	endWhile
endFunction

function LoadStrapons()
	Strapons = new form[1]
	Strapons[0] = CalypsStrapon
	int i = Game.GetModCount()
	while i
		i -= 1
		string Name = Game.GetModName(i)
		if Name == "StrapOnbyaeonv1.1.esp"
			LoadStrapon("StrapOnbyaeonv1.1.esp", 0x0D65)
		elseif Name == "TG.esp"
			LoadStrapon("TG.esp", 0x0182B)
		elseif Name == "Futa equippable.esp"
			LoadStrapon("Futa equippable.esp", 0x0D66)
			LoadStrapon("Futa equippable.esp", 0x0D67)
			LoadStrapon("Futa equippable.esp", 0x01D96)
			LoadStrapon("Futa equippable.esp", 0x022FB)
			LoadStrapon("Futa equippable.esp", 0x022FC)
			LoadStrapon("Futa equippable.esp", 0x022FD)
		elseif Name == "Skyrim_Strap_Ons.esp"
			LoadStrapon("Skyrim_Strap_Ons.esp", 0x00D65)
			LoadStrapon("Skyrim_Strap_Ons.esp", 0x02859)
			LoadStrapon("Skyrim_Strap_Ons.esp", 0x0285A)
			LoadStrapon("Skyrim_Strap_Ons.esp", 0x0285B)
			LoadStrapon("Skyrim_Strap_Ons.esp", 0x0285C)
			LoadStrapon("Skyrim_Strap_Ons.esp", 0x0285D)
			LoadStrapon("Skyrim_Strap_Ons.esp", 0x0285E)
			LoadStrapon("Skyrim_Strap_Ons.esp", 0x0285F)
		elseif Name == "SOS Equipable Schlong.esp"
			LoadStrapon("SOS Equipable Schlong.esp", 0x0D62)
		endif
	endWhile
endFunction

Armor function LoadStrapon(string esp, int id)
	Armor Strapon = Game.GetFormFromFile(id, esp) as Armor
	if Strapon != none
		Strapons = sslUtility.PushForm(Strapon, Strapons)
	endif
	return Strapon
endFunction

; ------------------------------------------------------- ;
; --- Animation Profiles                              --- ;
; ------------------------------------------------------- ;

function ExportProfile(int Profile = 1)
	StorageUtil.ExportFile("AnimationProfile_"+Profile+".json", ".Adjust", -1, AnimSlots, false, true, false)
	Log("Animation Profile #"+AnimProfile+" exported with ("+StorageUtil.debug_GetFloatListKeysCount(AnimSlots)+") values...", "Export")
endFunction

function SwapToProfile(int Profile)
	if Profile != AnimProfile
		ExportProfile(AnimProfile)
		Utility.WaitMenuMode(0.5)
		StorageUtil.debug_DeleteValues(AnimSlots)
		Utility.WaitMenuMode(0.5)
		AnimProfile = Profile
		ImportProfile(Profile)
	endIf
endFunction

function ImportProfile(int Profile = 1)
	StorageUtil.ImportFile("AnimationProfile_"+Profile+".json")
	Log("Animation Profile #"+AnimProfile+" imported with ("+StorageUtil.debug_GetFloatListKeysCount(AnimSlots)+") values...", "Import")
endfunction

; ------------------------------------------------------- ;
; --- System Use                                      --- ;
; ------------------------------------------------------- ;

bool function CheckSystem()
	; Check Skyrim Version
	if (StringUtil.SubString(Debug.GetVersionNumber(), 0, 3) as float) < 1.9
		CheckSkyrim.Show()
		return false
	; Check SKSE install
	elseIf SKSE.GetScriptVersionRelease() < 46
		CheckSKSE.Show(1.71)
		return false
	; Check SkyUI install - depends on passing SKSE check passing
	elseIf Quest.GetQuest("SKI_ConfigManagerInstance") == none
		CheckSkyUI.Show(4.1)
		return false
	; Check PapyrusUtil install - depends on passing SKSE check passing
	elseIf PapyrusUtil.GetVersion() < 24
		CheckPapyrusUtil.Show(2.4)
		return false
	; Check FNIS generation - soft fail
	elseIf !FNIS.IsGenerated()
		CheckFNIS.Show(5.11)
	endIf
	; Return result
	return true
endFunction

function ValidateTrackedActors()
	int i = StorageUtil.FormListCount(self, "TrackedActors")
	while i
		i -= 1
		Actor ActorRef = StorageUtil.FormListGet(self, "TrackedActors", i) as Actor
		if ActorRef == none
			StorageUtil.FormListRemoveAt(self, "TrackedActors", i)
		endIf
	endWhile
endFunction

function ValidateTrackedFactions()
	int i = StorageUtil.FormListCount(self, "TrackedFactions")
	while i
		i -= 1
		Faction FactionRef = StorageUtil.FormListGet(self, "TrackedFactions", i) as Faction
		if FactionRef == none
			StorageUtil.FormListRemoveAt(self, "TrackedFactions", i)
		endIf
	endWhile
endFunction

function Reload()
	Setup()
	; TFC Toggle key
	UnregisterForAllKeys()
	RegisterForKey(ToggleFreeCamera)
	RegisterForKey(TargetActor)
	; Configure SFX & Voice volumes
	AudioVoice.SetVolume(VoiceVolume)
	AudioSFX.SetVolume(SFXVolume)
	; Load animation & expression profile
	ImportProfile(AnimProfile)
	; Remove any targeted actors
	RegisterForCrosshairRef()
	CrosshairRef = none
	TargetRef = none
	; Validate tracked factions & actors
	ValidateTrackedActors()
	ValidateTrackedFactions()
	; Remove any NPC thread control player has
	DisableThreadControl(Control)
	; Cleanup phantom slots with missing owners
	SexLab.Factory.Cleanup()
endFunction

function SetDefaults()
	SexLab = Quest.GetQuest("SexLabQuestFramework") as SexLabFramework
	PlayerRef = Game.GetPlayer()

	; Booleans
	RestrictAggressive = true
	AllowCreatures     = false
	NPCSaveVoice       = false
	UseStrapons        = true
	RedressVictim      = true
	RagdollEnd         = false
	UseMaleNudeSuit    = false
	UseFemaleNudeSuit  = false
	UndressAnimation   = false
	UseLipSync         = false
	UseExpressions     = false
	ScaleActors        = false
	UseCum             = true
	AllowFFCum         = false
	DisablePlayer      = false
	AutoTFC            = false
	AutoAdvance        = true
	ForeplayStage      = false
	OrgasmEffects      = false
	RaceAdjustments    = true
	BedRemoveStanding  = true

	; Integers
	AnimProfile        = 1
	NPCBed             = 0

	Backwards          = 54 ; Right Shift
	AdjustStage        = 157; Right Ctrl
	AdvanceAnimation   = 57 ; Space
	ChangeAnimation    = 24 ; O
	ChangePositions    = 13 ; =
	AdjustChange       = 37 ; K
	AdjustForward      = 38 ; L
	AdjustSideways     = 40 ; '
	AdjustUpward       = 39 ; ;
	RealignActors      = 26 ; [
	MoveScene          = 27 ; ]
	RestoreOffsets     = 12 ; -
	RotateScene        = 22 ; U
	ToggleFreeCamera   = 81 ; NUM 3
	EndAnimation       = 207; End
	TargetActor        = 49 ; N

	; Floats
	CumTimer           = 120.0
	AutoSUCSM          = 5.0
	MaleVoiceDelay     = 5.0
	FemaleVoiceDelay   = 4.0
	VoiceVolume        = 1.0
	SFXDelay           = 3.0
	SFXVolume          = 1.0

	; Boolean strip arrays
	StripMale = new bool[33]
	StripMale[0] = true
	StripMale[1] = true
	StripMale[2] = true
	StripMale[3] = true
	StripMale[7] = true
	StripMale[8] = true
	StripMale[9] = true
	StripMale[4] = true
	StripMale[11] = true
	StripMale[15] = true
	StripMale[16] = true
	StripMale[17] = true
	StripMale[19] = true
	StripMale[23] = true
	StripMale[24] = true
	StripMale[26] = true
	StripMale[27] = true
	StripMale[28] = true
	StripMale[29] = true
	StripMale[32] = true

	StripFemale = new bool[33]
	StripFemale[0] = true
	StripFemale[1] = true
	StripFemale[2] = true
	StripFemale[3] = true
	StripFemale[4] = true
	StripFemale[7] = true
	StripFemale[8] = true
	StripFemale[9] = true
	StripFemale[11] = true
	StripFemale[15] = true
	StripFemale[16] = true
	StripFemale[17] = true
	StripFemale[19] = true
	StripFemale[23] = true
	StripFemale[24] = true
	StripFemale[26] = true
	StripFemale[27] = true
	StripFemale[28] = true
	StripFemale[29] = true
	StripFemale[32] = true

	StripLeadInFemale = new bool[33]
	StripLeadInFemale[0] = true
	StripLeadInFemale[2] = true
	StripLeadInFemale[9] = true
	StripLeadInFemale[14] = true
	StripLeadInFemale[32] = true

	StripLeadInMale = new bool[33]
	StripLeadInMale[0] = true
	StripLeadInMale[2] = true
	StripLeadInMale[9] = true
	StripLeadInMale[14] = true
	StripLeadInMale[32] = true

	StripVictim = new bool[33]
	StripVictim[1] = true
	StripVictim[2] = true
	StripVictim[4] = true
	StripVictim[9] = true
	StripVictim[11] = true
	StripVictim[16] = true
	StripVictim[24] = true
	StripVictim[26] = true
	StripVictim[28] = true
	StripVictim[32] = true

	StripAggressor = new bool[33]
	StripAggressor[2] = true
	StripAggressor[4] = true
	StripAggressor[9] = true
	StripAggressor[16] = true
	StripAggressor[24] = true
	StripAggressor[26] = true

	; Float timer arrays
	StageTimer = new float[5]
	StageTimer[0] = 30.0
	StageTimer[1] = 20.0
	StageTimer[2] = 15.0
	StageTimer[3] = 15.0
	StageTimer[4] = 9.0

	StageTimerLeadIn = new float[5]
	StageTimerLeadIn[0] = 10.0
	StageTimerLeadIn[1] = 10.0
	StageTimerLeadIn[2] = 10.0
	StageTimerLeadIn[3] = 8.0
	StageTimerLeadIn[4] = 8.0

	StageTimerAggr = new float[5]
	StageTimerAggr[0] = 20.0
	StageTimerAggr[1] = 15.0
	StageTimerAggr[2] = 10.0
	StageTimerAggr[3] = 10.0
	StageTimerAggr[4] = 4.0

	; Set animation profile
	SwapToProfile(1)

	; Config loaders
	LoadStrapons()
	Reload()

	; Rest some player configurations
	StorageUtil.SetIntValue(PlayerRef, "sslActorStats.Sexuality", 100)
	VoiceSlots.ForgetVoice(PlayerRef)
endFunction

function ReloadData()
	; ActorTypeNPC =            Game.GetForm(0x13794)
	; AnimatingFaction =        Game.GetFormFromFile(0xE50F, "SexLab.esm")
	; AudioSFX =                Game.GetFormFromFile(0x61428, "SexLab.esm")
	; AudioVoice =              Game.GetFormFromFile(0x61429, "SexLab.esm")
	; BaseMarker =              Game.GetFormFromFile(0x45A93 "SexLab.esm")
	; BedRollsList =            Game.GetFormFromFile(0x6198C, "SexLab.esm")
	; BedsList =                Game.GetFormFromFile(0x181B1, "SexLab.esm")
	; CalypsStrapon =           Game.GetFormFromFile(0x1A22A, "SexLab.esm")
	; CheckFNIS =               Game.GetFormFromFile(0x70C38, "SexLab.esm")
	; CheckPapyrusUtil =        Game.GetFormFromFile(0x70C3B, "SexLab.esm")
	; CheckSKSE =               Game.GetFormFromFile(0x70C39, "SexLab.esm")
	; CheckSkyrim =             Game.GetFormFromFile(0x70C3A, "SexLab.esm")
	; CheckSkyUI =              Game.GetFormFromFile(0x70C3C, "SexLab.esm")
	; CleanSystemFinish =       Game.GetFormFromFile(0x6CB9E, "SexLab.esm")
	; CumAnalKeyword =          Game.GetFormFromFile(0x, "SexLab.esm")
	; CumAnalSpell =            Game.GetFormFromFile(0x, "SexLab.esm")
	; CumOralAnalSpell =        Game.GetFormFromFile(0x, "SexLab.esm")
	; CumOralKeyword =          Game.GetFormFromFile(0x, "SexLab.esm")
	; CumOralSpell =            Game.GetFormFromFile(0x, "SexLab.esm")
	; CumVaginalAnalSpell =     Game.GetFormFromFile(0x, "SexLab.esm")
	; CumVaginalKeyword =       Game.GetFormFromFile(0x, "SexLab.esm")
	; CumVaginalOralAnalSpell = Game.GetFormFromFile(0x, "SexLab.esm")
	; CumVaginalOralSpell =     Game.GetFormFromFile(0x, "SexLab.esm")
	; CumVaginalSpell =         Game.GetFormFromFile(0x, "SexLab.esm")
	; DoNothing =               Game.GetFormFromFile(0x, "SexLab.esm")
	; DummyWeapon =             Game.GetFormFromFile(0x, "SexLab.esm")
	; ForbiddenFaction =        Game.GetFormFromFile(0x, "SexLab.esm")
	; GenderFaction =           Game.GetFormFromFile(0x, "SexLab.esm")
	; LipSync =                 Game.GetFormFromFile(0x, "SexLab.esm")
	; LocationMarker =          Game.GetFormFromFile(0x, "SexLab.esm")
	; NudeSuit =                Game.GetFormFromFile(0x, "SexLab.esm")
	; OrgasmFX =                Game.GetFormFromFile(0x, "SexLab.esm")
	; SexLabVoiceF =            Game.GetFormFromFile(0x, "SexLab.esm")
	; SexLabVoiceM =            Game.GetFormFromFile(0x, "SexLab.esm")
	; SexMixedFX =              Game.GetFormFromFile(0x, "SexLab.esm")
	; SquishingFX =             Game.GetFormFromFile(0x, "SexLab.esm")
	; SuckingFX =               Game.GetFormFromFile(0x, "SexLab.esm")
	; UseBed =                  Game.GetFormFromFile(0x, "SexLab.esm")
	; VoicesPlayer =            Game.GetFormFromFile(0x, "SexLab.esm")
endFunction


; ------------------------------------------------------- ;
; --- Pre 1.50 Config Accessors                       --- ;
; ------------------------------------------------------- ;

bool property bRestrictAggressive hidden
	bool function get()
		return RestrictAggressive
	endFunction
endProperty
bool property bAllowCreatures hidden
	bool function get()
		return AllowCreatures
	endFunction
endProperty
bool property bUseStrapons hidden
	bool function get()
		return UseStrapons
	endFunction
endProperty
bool property bRedressVictim hidden
	bool function get()
		return RedressVictim
	endFunction
endProperty
bool property bRagdollEnd hidden
	bool function get()
		return RagdollEnd
	endFunction
endProperty
bool property bUndressAnimation hidden
	bool function get()
		return UndressAnimation
	endFunction
endProperty
bool property bScaleActors hidden
	bool function get()
		return ScaleActors
	endFunction
endProperty
bool property bUseCum hidden
	bool function get()
		return UseCum
	endFunction
endProperty
bool property bAllowFFCum hidden
	bool function get()
		return AllowFFCum
	endFunction
endProperty
bool property bDisablePlayer hidden
	bool function get()
		return DisablePlayer
	endFunction
endProperty
bool property bAutoTFC hidden
	bool function get()
		return AutoTFC
	endFunction
endProperty
bool property bAutoAdvance hidden
	bool function get()
		return AutoAdvance
	endFunction
endProperty
bool property bForeplayStage hidden
	bool function get()
		return ForeplayStage
	endFunction
endProperty
bool property bOrgasmEffects hidden
	bool function get()
		return OrgasmEffects
	endFunction
endProperty
