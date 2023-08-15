scriptname sslSystemAlias extends ReferenceAlias

import StorageUtil
import SexLabUtil

; Framework
SexLabFramework property SexLab auto
sslSystemConfig property Config auto

; Function libraries
sslActorLibrary property ActorLib auto
sslThreadLibrary property ThreadLib auto
sslActorStats property Stats auto

; Object registry
sslThreadSlots property ThreadSlots auto
sslAnimationSlots property AnimSlots auto
sslCreatureAnimationSlots property CreatureSlots auto
sslVoiceSlots property VoiceSlots auto
sslExpressionSlots property ExpressionSlots auto
sslObjectFactory property Factory auto

; ------------------------------------------------------- ;
; --- System Startup                                  --- ;
; ------------------------------------------------------- ;

event OnPlayerLoadGame()
	; Config.DebugMode = true
	Log("Version "+CurrentVersion+" / "+SexLabUtil.GetVersion(), "LOADED")
	; Check for install
	if CurrentVersion > 0 && Config.CheckSystem()
		Config.Reload()
		ThreadSlots.StopAll()
		; Cleanup tasks
		Factory.Cleanup()
		CleanTrackedFactions()
		CleanTrackedActors()
		; Send game loaded event
		ModEvent.Send(ModEvent.Create("SexLabGameLoaded"))
	elseIf !IsInstalled && !ForcedOnce && GetState() == "" && Config.CheckSystem()
		Utility.Wait(0.1)
		RegisterForSingleUpdate(30.0)
	elseIf Version == 0 && GetState() == "Ready" && Config.CheckSystem()
		Utility.Wait(0.1)
		Log("SexLab somehow failed to install things, but it did. Not sure how this happened and it never should, attempting to fix it automatically now... ")
		InstallSystem()
	endIf
endEvent

event OnInit()
	GoToState("")
	Version = 0
	ForcedOnce = false
endEvent

; ------------------------------------------------------- ;
; --- System Install/Update                           --- ;
; ------------------------------------------------------- ;

int Version
int property CurrentVersion hidden
	int function get()
		return Version
	endFunction
endProperty

bool ForcedOnce = false
bool property IsInstalled hidden
	bool function get()
		return Version > 0 && GetState() == "Ready"
	endFunction
endProperty

bool property UpdatePending hidden
	bool function get()
		return Version > 0 && Version < SexLabUtil.GetVersion()
	endFunction
endProperty

bool property PreloadDone hidden
	bool function get()
		return GetIntValue(Config, "PreloadDone", 0) == 1
	endFunction
	function set(bool value)
		SetIntValue(Config, "PreloadDone", value as int)
	endFunction
endProperty

bool function SetupSystem()
	Version = SexLabUtil.GetVersion()
	SexLab.GoToState("Disabled")
	GoToState("Installing")

	; Framework
	; LoadLibs(false)
	; SexLab.Setup()
	Config.Setup()

	; Function libraries
	; ThreadLib.Setup()
	; ActorLib.Setup()
	; Stats.Setup()

	; Object registry
	Factory.Setup()
	VoiceSlots.Setup()
	ExpressionSlots.Setup()
	; AnimSlots.Setup()
	CreatureSlots.Setup()
	; ThreadSlots.Setup()

	; Finish setup
	GoToState("Ready")
	SexLab.GoToState("Enabled")
	LogAll("SexLab v" + SexLabUtil.GetStringVer() + " - Ready!")
	; Clean storage lists
	CleanActorStorage()
	return true
endFunction

event InstallSystem()
	ForcedOnce = true
	; Begin installation
	LogAll("SexLab v" + SexLabUtil.GetStringVer() + " - Installing...")
	; Init system
	If(SetupSystem())
		Stats.EmptyStats(Game.GetPlayer())
		SendVersionEvent("SexLabInstalled")
	else
		Debug.TraceAndBox("SexLab v" + SexLabUtil.GetStringVer() + " - INSTALL ERROR, CHECK YOUR PAPYRUS LOGS!")
		ForcedOnce = false
	endIf
endEvent

function SendVersionEvent(string VersionEvent)
	int eid = ModEvent.Create(VersionEvent)
	ModEvent.PushInt(eid, CurrentVersion)
	ModEvent.Send(eid)
endFunction

; ------------------------------------------------------- ;
; --- System Cleanup                                  --- ;
; ------------------------------------------------------- ;

function CleanTrackedActors()
	FormListRemove(Config, "TrackedActors", none, true)
	Form[] TrackedActors = FormListToArray(Config, "TrackedActors")
	int i = TrackedActors.Length
	while i > 0
		i -= 1
		if !IsActor(TrackedActors[i])
			FormListRemoveAt(Config, "TrackedActors", i)
			StringListClear(TrackedActors[i], "SexLabEvents")
		endIf
	endWhile
endFunction

function CleanTrackedFactions()
	FormListRemove(Config, "TrackedFactions", none, true)
	Form[] TrackedFactions = FormListToArray(Config, "TrackedFactions")
	int i = TrackedFactions.Length
	while i
		i -= 1
		if !TrackedFactions[i] || TrackedFactions[i].GetType() != 11 ; kFaction
			FormListRemoveAt(Config, "TrackedFactions", i)
			StringListClear(TrackedFactions[i], "SexLabEvents")
		endIf
	endWhile
endFunction

function CleanActorStorage()
	if !PreloadDone
		GoToState("PreloadStorage")
		return
	endIf
	Log("Starting..." ,"CleanActorStorage")
	FormListRemove(none, "SexLab.ActorStorage", none, true)

	Form[] ActorStorage = FormListToArray(none, "SexLab.ActorStorage")
	int i = ActorStorage.Length
	while i > 0
		i -= 1
		bool IsActor = IsActor(ActorStorage[i])
		if !IsActor || (IsActor && !IsImportant(ActorStorage[i] as Actor, false))
			ClearFromActorStorage(ActorStorage[i])
		endIf
	endWhile
	; Log change in storage
	int Count = FormListCount(none, "SexLab.ActorStorage")
	if Count != ActorStorage.Length
		Log(ActorStorage.Length+" -> "+Count, "CleanActorStorage")
	else
		Log("Done - "+Count, "CleanActorStorage")
	endIf
	if Config.DebugMode
		debug_Cleanup()
	endIf
endFunction

function ClearFromActorStorage(Form FormRef)
	if IsActor(FormRef)
		Actor ActorRef = FormRef as Actor
		sslActorStats._ResetStats(ActorRef)
		Stats.ClearCustomStats(ActorRef)
		Stats.ClearLegacyStats(ActorRef)
	endIf
	UnsetStringValue(FormRef, "SexLab.SavedVoice")
	UnsetStringValue(FormRef, "SexLab.CustomVoiceAlias")
	UnsetFormValue(FormRef, "SexLab.CustomVoiceQuest")
 	FormListClear(FormRef, "SexPartners")
	FormListClear(FormRef, "WasVictimOf")
	FormListClear(FormRef, "WasAggressorTo")
	FormListRemove(none, "SexLab.SkilledActors", FormRef, true)
	FormListRemove(none, "SexLab.ActorStorage", FormRef, true)
endFunction

bool function IsActor(Form FormRef) global
	if FormRef
		int Type = FormRef.GetType()
		return Type == 43 || Type == 44 || Type == 62 ; kNPC = 43 kLeveledCharacter = 44 kCharacter = 62
	endIf
	return false
endFunction

bool function IsImportant(Actor ActorRef, bool Strict = false) global
	if ActorRef == Game.GetPlayer()
		return true
	elseIf !ActorRef || ActorRef.IsDead() || ActorRef.IsDeleted() || ActorRef.IsChild()
		return false
	elseIf !Strict
		return true
	endIf
	; Strict check
	ActorBase BaseRef = ActorRef.GetLeveledActorBase()
	return BaseRef.IsUnique() || BaseRef.IsEssential() || BaseRef.IsInvulnerable() || BaseRef.IsProtected() || ActorRef.IsGuard() || ActorRef.IsPlayerTeammate() || ActorRef.Is3DLoaded()
endFunction

; ------------------------------------------------------- ;
; --- System Utils                                   --- ;
; ------------------------------------------------------- ;

function Log(string Log, string Type = "NOTICE")
	Log = "SEXLAB - "+Type+": "+Log
	SexLabUtil.PrintConsole(Log)
	Debug.Trace(Log)
endFunction

function LogAll(string Log)
	Log = "SexLab  - "+Log
	Debug.Notification(Log)
	Debug.Trace(Log)
	MiscUtil.PrintConsole(Log)
endFunction

function MenuWait()
	Utility.Wait(2.0)
	while Utility.IsInMenuMode()
		Utility.Wait(0.5)
	endWhile
endFunction

state PreloadStorage
	event OnBeginState()
		RegisterForSingleUpdate(0.1)
	endEvent
	event OnUpdate()
		GoToState("Ready")
		if PreloadDone
			return
		endIf
		PreloadDone = true
		Log("Preloading actor storage... This may take a long time...")
		; Start actor preloading
		int PreCount = FormListCount(none, "SexLab.ActorStorage")
		FormListRemove(none, "SexLab.ActorStorage", none, true)
		; Check actors with saved stats
		Actor[] Actors = sslActorStats.GetAllSkilledActors()
		int i = Actors.Length
		while i > 0
			i -= 1
			if Actors[i] && !FormListHas(none, "SexLab.ActorStorage", Actors[i])
				sslSystemConfig.StoreActor(Actors[i])
			endIf
		endWhile
		; Check string values for SexLab.SavedVoice
		Form[] Forms = debug_AllStringObjs()
		i = Forms.Length
		while i > 0
			i -= 1
			if Forms[i] && !FormListHas(none, "SexLab.ActorStorage", Forms[i]) && HasStringValue(Forms[i], "SexLab.SavedVoice")
				sslSystemConfig.StoreActor(Forms[i])
			endIf
		endWhile
		; Check form list for partners, victims, aggressors, or legacy skill storage
		Forms = debug_AllFormListObjs()
		i = Forms.Length
		while i > 0
			i -= 1
			if Forms[i] && !FormListHas(none, "SexLab.ActorStorage", Forms[i]) && (FormListCount(Forms[i], "SexPartners") > 0 || FormListCount(Forms[i], "WasAggressorTo") > 0 || FormListCount(Forms[i], "WasVictimOf") > 0)
				sslSystemConfig.StoreActor(Forms[i])
			endIf
		endWhile
		; Load legacy skilled actor storage
		i = FormListCount(none, "SexLab.SkilledActors")
		while i > 0
			i -= 1
			Form FormRef = FormListGet(none, "SexLab.SkilledActors", i)
			if FormRef && FormRef != Game.GetPlayer()
				if IsActor(FormRef)
					Stats.UpgradeLegacyStats(FormRef, IsImportant(FormRef as Actor, true))
				else
					ClearFromActorStorage(FormRef)
				endIf
			endIf
		endWhile
		FormListClear(none, "SexLab.SkilledActors")
		; Log change in storage
		int Count = FormListCount(none, "SexLab.ActorStorage")
		if Count != PreCount
			Log(PreCount+" -> "+Count, "PreloadSavedStorage")
		else
			Log("Done - "+Count, "PreloadSavedStorage")
		endIf
		; Preload finished, now clean it.
		CleanActorStorage()
	endEvent
endState

; Check if we should force install system, because user hasn't done it manually yet for some reason. Or it failed somehow.
event OnUpdate()
	if !IsInstalled && !ForcedOnce && GetState() == ""
		Quest UnboundQ = Quest.GetQuest("MQ101")
		if UnboundQ && !UnboundQ.GetStageDone(250)
			; Wait until the end of the opening quest(cart scene) to prevent issues related with the First Person Camera
			RegisterForSingleUpdate(120.0)
		else
			ForcedOnce = true
			LogAll("Automatically Installing SexLab v"+SexLabUtil.GetStringVer())
			InstallSystem()
		endIf
	endIf
endEvent

; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* ;
; ----------------------------------------------------------------------------- ;
;								██╗     ███████╗ ██████╗  █████╗  ██████╗██╗   ██╗							;
;								██║     ██╔════╝██╔════╝ ██╔══██╗██╔════╝╚██╗ ██╔╝							;
;								██║     █████╗  ██║  ███╗███████║██║      ╚████╔╝ 							;
;								██║     ██╔══╝  ██║   ██║██╔══██║██║       ╚██╔╝  							;
;								███████╗███████╗╚██████╔╝██║  ██║╚██████╗   ██║   							;
;								╚══════╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝   ╚═╝   							;
; ----------------------------------------------------------------------------- ;
; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* ;

event UpdateSystem(int OldVersion, int NewVersion)
endEvent
