scriptname sslAnimationSlots extends Quest
{
	Internal base script acing as registry for animation objects
	Interact with this Script through the main api only
}

; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* ;
; ----------------------------------------------------------------------------- ;
;        ██╗███╗   ██╗████████╗███████╗██████╗ ███╗   ██╗ █████╗ ██╗            ;
;        ██║████╗  ██║╚══██╔══╝██╔════╝██╔══██╗████╗  ██║██╔══██╗██║            ;
;        ██║██╔██╗ ██║   ██║   █████╗  ██████╔╝██╔██╗ ██║███████║██║            ;
;        ██║██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗██║╚██╗██║██╔══██║██║            ;
;        ██║██║ ╚████║   ██║   ███████╗██║  ██║██║ ╚████║██║  ██║███████╗       ;
;        ╚═╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝       ;
; ----------------------------------------------------------------------------- ;
; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* ;

import PapyrusUtil

Alias[] Objects
string[] Registry
int property Slotted auto hidden

sslSystemConfig property Config auto

; ------------------------------------------------------- ;
; --- Animation Filtering                             --- ;
; ------------------------------------------------------- ;

sslBaseAnimation[] Function GetAnimations(Actor[] akPositions, String asTags, Actor akVictim, int aiUseBed = 0)
	int[] keys = sslActorData.BuildSortedDataKeyArray(akPositions, akPositions.Find(akVictim))
	return GetAnimationsByKeys(keys, asTags, aiuseBed)
EndFunction

sslBaseAnimation[] Function GetAnimationsByKeys(int[] akPositions, String asTags, int aiUseBed = 0)
	String[] tags = PapyrusUtil.ClearEmpty(PapyrusUtil.StringSplit(asTags))
	If(aiUseBed == -1)
		tags = PapyrusUtil.PushString(tags, "-BedOnly")
	ElseIf(aiUseBed == 1)
		tags = PapyrusUtil.PushString(tags, "-Furniture")
		If(Config.BedRemoveStanding)
			tags = PapyrusUtil.PushString(tags, "-Standing")
		EndIf
	EndIf
	return _GetAnimations(akPositions, tags)
EndFunction

sslBaseAnimation[] Function _GetAnimations(int[] aiKeys, String[] asTags)
	sslBaseAnimation[] ret = _GetAnimationsImpl(aiKeys, asTags)
	While(!ret.Length)
		Log("Unable to find animations. Shifting positions from keys: " + aiKeys)
		aiKeys = ShiftKeys(aiKeys)
		If(!aiKeys.Length)
			Log("Unable to shift")
			Log("Unable to find animations")
			return sslUtility.AnimationArray(0)
		EndIf
		ret = _GetAnimationsImpl(aiKeys, asTags)
	EndWhile
	Log("_GetAnimations: Found " + ret.Length + " animations | Keys " + aiKeys + " | Tags = " + asTags)
	return ret
EndFunction

sslBaseAnimation[] Function _GetAnimationsImpl(int[] aiKeys, String[] asTags)
	Log("Searching for Animation with Keys = " + aiKeys + " | Tags = " + asTags)
	sslBaseAnimation[] ret = new sslBaseAnimation[128]
	int i = 0
	int ii = 0
	While(i < Slotted)
		If(Objects[i])
			sslBaseAnimation Slot = Objects[i] as sslBaseAnimation
			; Log("Validating Animation Nr. " + i + " | Keys = " + Slot.DataKeys() + " | Tags = " + Slot.GetTags())
			If(Slot.Enabled && Slot.MatchKeys(aiKeys) && Slot.MatchTags(asTags))
				ret[ii] = Slot
				If(ii == 127)
					return ret
				EndIf
				ii += 1
			EndIf
		EndIf
		i += 1
	EndWhile
	sslBaseAnimation[] _ret = sslUtility.AnimationArray(ii)
	int j = 0
	While(j < ii)
		_ret[j] = ret[j]
		j += 1
	EndWhile
	return _ret
EndFunction

int[] Function ShiftKeys(int[] aiKeys)
	; IDEA: Shift Futas first to female, then to male
	int k = aiKeys.Length
	While(k > 0)
		k -= 1
		If(sslActorData.IsFuta(aiKeys[k]))
			If(Config.iFutaBehavior == 0)
				If(!sslActorData.IsMaleOverwrite(aiKeys[k]))
					aiKeys[k] = sslActorData.AddOverWrite(aiKeys[k], false)
					return sslActorData.SortDataKeys(aiKeys)
				EndIf
			ElseIf(Config.iFutaBehavior == 1)
				If(!sslActorData.IsFemaleOverwrite(aiKeys[k]))
					aiKeys[k] = sslActorData.AddOverWrite(aiKeys[k], true)
					return sslActorData.SortDataKeys(aiKeys)
				EndIf
			EndIf
		EndIf
	EndWhile
	If(Config.UseStrapons)
		int i = aiKeys.Length
		While(i > 0)
			i -= 1
			If(sslActorData.IsFemale(aiKeys[k]) && !sslActorData.IsMaleOverwrite(aiKeys[k]))
				aiKeys[k] = sslActorData.AddOverWrite(aiKeys[k], false)
				return sslActorData.SortDataKeys(aiKeys)
			EndIf
		EndWhile
	EndIf
	return Utility.CreateIntArray(0)
EndFunction

; ------------------------------------------------------- ;
; --- Registry Access                                     ;
; ------------------------------------------------------- ;

sslBaseAnimation function GetBySlot(int index)
	if index >= 0 && index < Slotted && Objects[index]
		return Objects[index] as sslBaseAnimation
	endIf
	return none
endFunction

sslBaseAnimation function GetByName(string FindName)
	return GetBySlot(FindByName(FindName))
endFunction

sslBaseAnimation function GetbyRegistrar(string Registrar)
	return GetBySlot(FindByRegistrar(Registrar))
endFunction

int function FindByRegistrar(string Registrar)
	if Registrar != ""
		return Registry.Find(Registrar)
	endIf
	return -1
endFunction

int function FindByName(string FindName)
	int i = Slotted
	while i
		i -= 1
		if GetBySlot(i) && GetBySlot(i).Name == FindName
			return i
		endIf
	endWhile
	return -1
endFunction

bool function IsRegistered(string Registrar)
	return FindByRegistrar(Registrar) != -1
endFunction

; ------------------------------------------------------- ;
; --- Object Utilities                                --- ;
; ------------------------------------------------------- ;

string[] function GetNames(sslBaseAnimation[] SlotList)
	int i = SlotList.Length
	string[] Names = Utility.CreateStringArray(i)
	while i
		i -= 1
		if SlotList[i]
			Names[i] = SlotList[i].Name
		endIf
	endWhile
	return RemoveString(Names, "")
endFunction

int function CountTag(sslBaseAnimation[] Anims, string Tags)
	string[] Checking = StringSplit(Tags)
	Checking = ClearEmpty(Checking)
	if Tags == "" || Checking.Length == 0
		return 0
	endIf
	int count
	int i = Anims.Length
	while i
		i -= 1
		count += Anims[i].HasOneTag(Checking) as int
	endWhile
	return count
endFunction

int function GetCount(bool IgnoreDisabled = true)
	if !IgnoreDisabled
		return Slotted
	endIf
	int Count
	int i = Slotted
	while i
		i -= 1
		Count += ((GetBySlot(i) && GetBySlot(i).Enabled) as int)
	endWhile
	return Count
endFunction

int function CountTagUsage(string Tags, bool IgnoreDisabled = true)
	string[] Checking = ClearEmpty(StringSplit(Tags))
	if !Checking.Length
		return 0
	endIf
	int count
	int i = Slotted
	while i
		i -= 1
		sslBaseAnimation Slot = Objects[i] as sslBaseAnimation
		count += (Slot && (Slot.Enabled || !IgnoreDisabled) && Slot.HasAllTag(Checking)) as int
	endWhile
	return count
endfunction

string[] function GetAllTags(int ActorCount = -1, bool IgnoreDisabled = true)
	IgnoreDisabled = !IgnoreDisabled
	string[] Output
	int i = Slotted
	while i
		i -= 1
		sslBaseAnimation Anim = Objects[i] as sslBaseAnimation
		if Anim && (IgnoreDisabled || Anim.Enabled) && (ActorCount == -1 || Anim.PositionCount == ActorCount)
			Output = MergeStringArray(Output, Anim.GetRawTags(), true)
		endif
	endwhile
	PapyrusUtil.SortStringArray(Output)
	return RemoveString(Output, "")
endFunction

; ------------------------------------------------------- ;
; --- Object Registration                                 ;
; ------------------------------------------------------- ;

function RegisterSlots()
	CacheID = "SexLab.AnimationTags"
	ClearAnimCache()
	ClearTagCache()
	; Register default animation
	(Game.GetFormFromFile(0x639DF, "SexLab.esm") as sslAnimationDefaults).LoadAnimations()
	; Send mod event for 3rd party animation
	ModEvent.Send(ModEvent.Create("SexLabSlotAnimations"))
	Debug.Notification("$SSL_NotifyAnimationInstall")
endFunction

bool RegisterLock
int function Register(string Registrar)
	if Registrar == "" || !Registry || Registry.Length < 1
		return -1
	elseIf Registry.Find(Registrar) != -1 || Slotted >= GetNumAliases()
		return -1
	elseIf IsSuppressed(Registrar)
		Log("SKIPPING -- "+Registrar)
		return -1
	endIf

	; Thread lock registration
	float failsafe = Utility.GetCurrentRealTime() + 6.0
	while RegisterLock && failsafe < Utility.GetCurrentRealTime()
		Utility.WaitMenuMode(0.5)
		Log("Register("+Registrar+") - Lock wait...")
	endWhile
	RegisterLock = true

	ClearAnimCache()
	ClearTagCache()

	int i = Slotted
	Slotted += 1
	if i >= Registry.Length
		int n = Registry.Length + 32
		if n > GetNumAliases()
			n = GetNumAliases()
		endIf
		Log("Resizing animation registry slots: "+Registry.Length+" -> "+n)
		Registry = Utility.ResizeStringArray(Registry, n)
		Objects  = Utility.ResizeAliasArray(Objects, n, GetNthAlias(0))
		while n
			n -= 1
			if Registry[n] == ""
				Objects[n] = none
			endIf
		endWhile
		i = Registry.Find("")
	endIf
	Registry[i] = Registrar
	Objects[i]  = GetNthAlias(i)

	; Release lock
	RegisterLock = false
	return i
endFunction

sslBaseAnimation function RegisterAnimation(string Registrar, Form CallbackForm = none, ReferenceAlias CallbackAlias = none)
	; Return existing Animation
	if FindByRegistrar(Registrar) != -1
		return GetbyRegistrar(Registrar)
	endIf
	; Get free Animation slot
	int id = Register(Registrar)
	sslBaseAnimation Slot = GetBySlot(id)
	if id != -1 && Slot != none
		Slot.Initialize()
		Slot.Registry = Registrar
		Slot.Enabled  = true
		sslObjectFactory.SendCallback(Registrar, id, CallbackForm, CallbackAlias)
	endIf
	return Slot
endFunction

bool function UnregisterAnimation(string Registrar)
	if Registrar != "" && Registry.Find(Registrar) != -1
		ClearAnimCache()
		ClearTagCache()
		int Slot = Registry.Find(Registrar)
		(Objects[Slot] as sslBaseAnimation).Initialize()
		Objects[Slot] = none
		Registry[Slot] = ""
		Config.Log("Animation["+Slot+"] "+Registrar, "UnregisterAnimation()")
		return true	
	endIf
	return false
endFunction

bool function IsSuppressed(string Registrar)
	return JsonUtil.StringListHas("../SexLab/SuppressedAnimations.json", "suppress", Registrar)
endFunction

function NeverRegister(string Registrar)
	if !IsSuppressed(Registrar)
		JsonUtil.StringListAdd("../SexLab/SuppressedAnimations.json", "suppress", Registrar, false)
		JsonUtil.Save("../SexLab/SuppressedAnimations.json", true)
	endIf
endFunction

function AllowRegister(string Registrar)
	if IsSuppressed(Registrar)
		JsonUtil.StringListRemove("../SexLab/SuppressedAnimations.json", "suppress", Registrar, true)
		JsonUtil.Save("../SexLab/SuppressedAnimations.json", true)
	endIf
endFunction

int function ClearSuppressed()
	int i = JsonUtil.StringListClear("../SexLab/SuppressedAnimations.json", "suppress")
	JsonUtil.Save("../SexLab/SuppressedAnimations.json", true)
	return i
endFunction

int function GetDisabledCount()
	int count
	int i = Slotted
	while i
		i -= 1
		if Objects[i]
			sslBaseAnimation Slot = Objects[i] as sslBaseAnimation
			if Slot.Registered && !Slot.Enabled
				count += 1
			endIf
		endIf
	endWhile
	return count
endFunction

int function GetSuppressedCount()
	return JsonUtil.StringListCount("../SexLab/SuppressedAnimations.json", "suppress")
endFunction

int function SuppressDisabled()
	int count
	int i = Slotted
	while i
		i -= 1
		if Objects[i]
			sslBaseAnimation Slot = Objects[i] as sslBaseAnimation
			if Slot.Registered && !Slot.Enabled
				NeverRegister(Slot.Registry)
				count += 1
			endIf
		endIf
	endWhile
	return count
endFunction

string[] function GetSuppressedList()
	return JsonUtil.StringListToArray("../SexLab/SuppressedAnimations.json", "suppress")
endFunction

function PreloadCategoryLoaders()
	string[] Files = JsonUtil.JsonInFolder(JLoaders)
	if !Files
		return ; No JSON Animation Loaders
	endIf

	; Clear existing lists
	StorageUtil.StringListClear(self, "categories")
	StorageUtil.ClearObjStringListPrefix(self, "cat.")

	; Load files into categories
	int i = Files.Length
	while i
		i -= 1
		; Ignore the 2 example files.
		if Files[i] != "ArrokReverseCowgirl.json" && Files[i] != "TrollGrabbing.json"
			string Category = JsonUtil.GetPathStringValue(JLoaders+Files[i], ".category", "Misc")
			StorageUtil.StringListAdd(self, "categories", Category, false)
			StorageUtil.StringListAdd(self, "cat."+Category, Files[i], false)
		endIf
	endWhile
endFunction

; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* ;
; ----------------------------------------------------------------------------- ;
;        ██╗███╗   ██╗████████╗███████╗██████╗ ███╗   ██╗ █████╗ ██╗            ;
;        ██║████╗  ██║╚══██╔══╝██╔════╝██╔══██╗████╗  ██║██╔══██╗██║            ;
;        ██║██╔██╗ ██║   ██║   █████╗  ██████╔╝██╔██╗ ██║███████║██║            ;
;        ██║██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗██║╚██╗██║██╔══██║██║            ;
;        ██║██║ ╚████║   ██║   ███████╗██║  ██║██║ ╚████║██║  ██║███████╗       ;
;        ╚═╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝       ;
; ----------------------------------------------------------------------------- ;
; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* ;

; ------------------------------------------------------- ;
; --- Object MCM Pagination                               ;
; ------------------------------------------------------- ;

int function PageCount(int perpage = 125)
	return ((Slotted as float / perpage as float) as int) + 1
endFunction

int function FindPage(string Registrar, int perpage = 125)
	int i = Registry.Find(Registrar)
	if i != -1
		return ((i as float / perpage as float) as int) + 1
	endIf
	return -1
endFunction

string[] function GetSlotNames(int page = 1, int perpage = 125)
	return GetNames(GetSlots(page, perpage))
endfunction

sslBaseAnimation[] function GetSlots(int page = 1, int perpage = 125)
	perpage = ClampInt(perpage, 1, 128)
	if page > PageCount(perpage) || page < 1
		return sslUtility.AnimationArray(0)
	endIf
	int n
	sslBaseAnimation[] PageSlots
	if page == PageCount(perpage)
		n = Slotted
		PageSlots = sslUtility.AnimationArray((Slotted - ((page - 1) * perpage)))
	else
		n = page * perpage
		PageSlots = sslUtility.AnimationArray(perpage)
	endIf
	int i = PageSlots.Length
	while i
		i -= 1
		n -= 1
		if Objects[n]
			PageSlots[i] = Objects[n] as sslBaseAnimation
		endIf
	endWhile
	return PageSlots
endFunction

; ------------------------------------------------------- ;
; --- Setup	& Misc					                              ;
; ------------------------------------------------------- ;

string property JLoaders auto hidden

function Setup()
	GoToState("Locked")
	Slotted  = 0
	Registry = new string[128] ; Utility.CreateStringArray(164)
	Objects  = new Alias[128] ; Utility.CreateAliasArray(164, GetNthAlias(0))

	CacheID = "SexLab.AnimationTags"
	JLoaders = "../SexLab/Animations/"
	if self == Config.CreatureSlots
		JLoaders += "Creatures/"
	endIf

	RegisterLock = false
	RegisterSlots()
	GoToState("")
endFunction

function Log(string msg)
	if Config.DebugMode
		MiscUtil.PrintConsole(msg)
		Debug.TraceUser("SexLabDebug", msg)
	endIf
	Debug.Trace("SEXLAB - " + Self + " " + msg)
endFunction

state Locked
	function Setup()
	endFunction
endState

; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*	;
;																																											;
;									██╗     ███████╗ ██████╗  █████╗  ██████╗██╗   ██╗									;
;									██║     ██╔════╝██╔════╝ ██╔══██╗██╔════╝╚██╗ ██╔╝									;
;									██║     █████╗  ██║  ███╗███████║██║      ╚████╔╝ 									;
;									██║     ██╔══╝  ██║   ██║██╔══██║██║       ╚██╔╝  									;
;									███████╗███████╗╚██████╔╝██║  ██║╚██████╗   ██║   									;
;									╚══════╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝   ╚═╝   									;
;																																											;
; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*	;


; The usage of the below functions is considered sub-optimal for the design philosophy of SexLab
int function FindFirstTagged(string Tags, bool IgnoreDisabled = true, bool Reverse = false)
	string[] Checking = ClearEmpty(StringSplit(Tags))
	if !Checking.Length
		return -1
	endIf
	int count
	int i = 0
	if !Reverse 
		i = Slotted
	endIf
	while (i && !Reverse) || (i < Slotted && Reverse)
		if !Reverse 
			i -= 1
		endIf
		if Objects[i]
			sslBaseAnimation Slot = Objects[i] as sslBaseAnimation
			if ((Slot.Enabled || !IgnoreDisabled) && Slot.HasAllTag(Checking))
				return i
			endIf
		endIf
		if Reverse 
			i += 1
		endIf
	endWhile
	return -1
endFunction

; This is only intended to be used as wrapper to link legacy animation getters to the new one
String[] Function BuildArgTags(String[] asTags, String[] asTagsSuppress, bool abRequireAll)
	String[] ret = Utility.ResizeStringArray(asTags, asTags.Length + asTagsSuppress.Length)
	If(!abRequireAll && asTags.Length > 1)
		int n = 0
		While(n < asTags.Length)
			ret[n] = "~" + asTags[n]
			n += 1
		EndWhile
	EndIf
	int i = asTags.Length
	int k = 0
	While(k < asTagsSuppress.Length)
		ret[i + k] = "-" + asTagsSuppress[k]
		k += 1
	EndWhile
	return ret
EndFunction


sslBaseAnimation[] function GetByTags(int ActorCount, string Tags, string TagsSuppressed = "", bool RequireAll = true)
	Log("AnimationFilter: GetByTags")
	int[] keys = Utility.CreateIntArray(ActorCount)
	int n = 0
	While(n < keys.Length)
		keys[n] = sslActorData.BuildBlankKey()
		n += 1
	EndWhile
	String[] required = PapyrusUtil.ClearEmpty(PapyrusUtil.StringSplit(Tags))
	String[] suppressed = PapyrusUtil.ClearEmpty(PapyrusUtil.StringSplit(TagsSuppressed))
	String[] t = BuildArgTags(required, suppressed, RequireAll)
	return _GetAnimations(keys, t)
endFunction

sslBaseAnimation[] function GetByCommonTags(int ActorCount, string CommonTags, string Tags, string TagsSuppressed = "", bool RequireAll = true)
	Log("AnimationFilter: GetByCommonTags")
	If(CommonTags == "")
		return GetByTags(ActorCount, Tags, TagsSuppressed, RequireAll)
	EndIf
	int[] keys = Utility.CreateIntArray(ActorCount)
	int n = 0
	While(n < ActorCount)
		keys[n] = sslActorData.BuildBlankKey()
		n += 1
	EndWhile
	String[] required = PapyrusUtil.ClearEmpty(PapyrusUtil.StringSplit(Tags))
	String[] suppressed = PapyrusUtil.ClearEmpty(PapyrusUtil.StringSplit(TagsSuppressed))
	String[] argTags = BuildArgTags(required, suppressed, RequireAll)
	String[] common = PapyrusUtil.ClearEmpty(PapyrusUtil.StringSplit(CommonTags))
	return _GetAnimations(keys, sslpp.MergeStringArrayEx(argTags, common, true))
EndFunction

sslBaseAnimation[] function GetByType(int ActorCount, int Males = -1, int Females = -1, int StageCount = -1, bool Aggressive = false, bool Sexual = true)
	Log("AnimationFilter: GetByType")
	int[] keys = Utility.CreateIntArray(ActorCount)
	int i = 0
	While(i < ActorCount)
		keys[i] = sslActorData.BuildBlankKey()
		i += 1
	EndWhile
	String[] tags
	If(Sexual)
		tags = new String[1]
		tags[0] = "-LeadIn"
	EndIf
	return _GetAnimations(keys, tags)
endFunction

sslBaseAnimation[] function PickByActors(Actor[] Positions, int Limit = 64, bool Aggressive = false)
	Log("AnimationFilter: PickByActors")
	String tags = ""
	If(Aggressive)
		tags += "Aggressive"
	EndIf
	return GetAnimations(Positions, tags, none)
EndFunction

sslBaseAnimation[] function GetByDefault(int Males, int Females, bool IsAggressive = false, bool UsingBed = false, bool RestrictAggressive = true)
	Log("AnimationFilter: GetByDefault")
	int[] keys = Utility.CreateIntArray(Males + Females)
	int n = 0
	While(n < Females)
		keys[n] = sslActorData.BuildByLegacyGender(1)
		n += 1
	EndWhile
	int i = 0
	While(i < Males)
		keys[i + n] = sslActorData.BuildByLegacyGender(0) 
		i += 1
	EndWhile
	String[] tags
	If(RestrictAggressive)
		tags = new String[1]
		tags[0] = "-Aggressive"
	ElseIf(IsAggressive)
		tags = new String[1]
		tags[0] = "Aggressive"
	EndIf
	; Sorting is technically unnecessary but want to avoid breaking this if default order ever changes
	keys = sslActorData.SortDataKeys(keys)
	return _GetAnimations(keys, tags)
EndFunction

sslBaseAnimation[] function GetByDefaultTags(int Males, int Females, bool IsAggressive = false, bool UsingBed = false, bool RestrictAggressive = true, string Tags, string TagsSuppressed = "", bool RequireAll = true)
	Log("AnimationFilter: GetByDefaultTags")
	If(Males + Females == 0)
		return none
	EndIf
	int[] keys = Utility.CreateIntArray(Males + Females)
	int n = 0
	While(n < Females)
		keys[n] = sslActorData.BuildByLegacyGender(1)
		n += 1
	EndWhile
	int i = 0
	While(i < Males)
		keys[i + n] = sslActorData.BuildByLegacyGender(0) 
		i += 1
	EndWhile
	String[] required = PapyrusUtil.ClearEmpty(PapyrusUtil.StringSplit(Tags))
	String[] suppressed = PapyrusUtil.ClearEmpty(PapyrusUtil.StringSplit(TagsSuppressed))
	String[] argTags = BuildArgTags(required, suppressed, RequireAll)
	If(RestrictAggressive)
		int where = argTags.Find("Aggressive")
		If(where > -1)
			argTags[where] = "-Aggressive"
		Else
			argTags.Find("~Aggressive")
			If(where > -1)
				argTags[where] = "-Aggressive"
			Else
				argTags = PapyrusUtil.PushString(argTags, "-Aggressive")
			EndIf
		EndIf
	ElseIf(IsAggressive)
		int where = argTags.Find("-Aggressive")
		If(where > -1)
			argTags[where] = "Aggressive"
		Else
			argTags.Find("~Aggressive")
			If(where > -1)
				argTags[where] = "Aggressive"
			Else
				argTags = PapyrusUtil.PushString(argTags, "Aggressive")
			EndIf
		EndIf
	EndIf
	If(!UsingBed)
		If(argTags.Find("-BedOnly") == -1)
			argTags = PapyrusUtil.PushString(argTags, "-BedOnly")
		EndIf
	Else
		If(argTags.Find("-Furniture") == -1)
			argTags = PapyrusUtil.PushString(argTags, "-Furniture")
		EndIf
		If(Config.BedRemoveStanding && argTags.Find("-Standing") == -1)
			argTags = PapyrusUtil.PushString(argTags, "-Standing")
		EndIf
	EndIf
	; Sorting is technically unnecessary but want to avoid breaking this if default order ever changes
	keys = sslActorData.SortDataKeys(keys)
	return _GetAnimations(keys, argTags)
EndFunction

sslBaseAnimation[] function GetList(bool[] Valid)
	; Debug.Trace("GetList() - "+Valid)
	sslBaseAnimation[] Output
	if Valid && Valid.Length > 0 && Valid.Find(true) != -1
		int n = Valid.Find(true)
		int i = CountBool(Valid, true)
		; Trim over 100 to random selection
		if i > 125
			int end = Valid.RFind(true) - 1
			while i > 125
				int rand = Valid.Find(true, Utility.RandomInt(n, end))
				if rand != -1 && Valid[rand]
					Valid[rand] = false
					i -= 1
				endIf
				if i == 126 ; To be sure only 125 stay
					i = CountBool(Valid, true)
					n = Valid.Find(true)
					end = Valid.RFind(true) - 1
				endIf
			endWhile
		endIf
		; Get list
		Output = sslUtility.AnimationArray(i)
		while n != -1 && i > 0
			i -= 1
			Output[i] = Objects[n] as sslBaseAnimation
			n += 1
			if n < Slotted
				n = Valid.Find(true, n)
			else
				n = -1
			endIf
		endWhile
		; Only bother with logging the selected animation names if debug mode enabled.
		;/ string List = "Found Animations("+Output.Length+")"
		if Config.DebugMode
			List +=  " "
			i = Output.Length
			while i
				i -= 1
				List += "["+Output[i].Name+"]"
			endWhile
		endIf
		Log(List) /;
	else
		; Log("No Animations Found")
	endIf
	return Output
endFunction

bool function TestSlots()
	return true
endFunction

sslBaseAnimation[] function RemoveTagged(sslBaseAnimation[] Anims, string Tags)
	return sslUtility.FilterTaggedAnimations(Anims, StringSplit(Tags), false)
endFunction

sslBaseAnimation[] function MergeLists(sslBaseAnimation[] List1, sslBaseAnimation[] List2)
	return sslUtility.MergeAnimationLists(List1, List2)
endFunction

bool[] function FindTagged(sslBaseAnimation[] Anims, string Tags)
	return sslUtility.FindTaggedAnimations(Anims, StringSplit(Tags))
endFunction

; ------------------------------------------------------- ;
; --- Cached Tag Search
; ------------------------------------------------------- ;


int SlottedCache
string[] FilterCache
float[] CacheTimes
sslBaseAnimation[] AnimCache0
sslBaseAnimation[] AnimCache1
sslBaseAnimation[] AnimCache2
sslBaseAnimation[] AnimCache3
sslBaseAnimation[] AnimCache4
sslBaseAnimation[] AnimCache5
sslBaseAnimation[] AnimCache6
sslBaseAnimation[] AnimCache7
sslBaseAnimation[] AnimCache8
sslBaseAnimation[] AnimCache9
sslBaseAnimation[] AnimCache10
sslBaseAnimation[] AnimCache11
sslBaseAnimation[] AnimCache12
sslBaseAnimation[] AnimCache13
sslBaseAnimation[] AnimCache14
sslBaseAnimation[] AnimCache15
sslBaseAnimation[] AnimCache16
sslBaseAnimation[] AnimCache17
sslBaseAnimation[] AnimCache18
sslBaseAnimation[] AnimCache19
sslBaseAnimation[] AnimCache20
sslBaseAnimation[] AnimCache21
sslBaseAnimation[] AnimCache22
sslBaseAnimation[] AnimCache23
sslBaseAnimation[] AnimCache24
sslBaseAnimation[] AnimCache25
sslBaseAnimation[] AnimCache26
sslBaseAnimation[] AnimCache27
sslBaseAnimation[] AnimCache28
sslBaseAnimation[] AnimCache29

function ClearAnimCache()
	SlottedCache = Slotted
	FilterCache = new string[30]
	CacheTimes = new float[30]
	AnimCache0 = sslUtility.EmptyAnimationArray()
	AnimCache1 = sslUtility.EmptyAnimationArray()
	AnimCache2 = sslUtility.EmptyAnimationArray()
	AnimCache3 = sslUtility.EmptyAnimationArray()
	AnimCache4 = sslUtility.EmptyAnimationArray()
	AnimCache5 = sslUtility.EmptyAnimationArray()
	AnimCache6 = sslUtility.EmptyAnimationArray()
	AnimCache7 = sslUtility.EmptyAnimationArray()
	AnimCache8 = sslUtility.EmptyAnimationArray()
	AnimCache9 = sslUtility.EmptyAnimationArray()
	AnimCache10 = sslUtility.EmptyAnimationArray()
	AnimCache11 = sslUtility.EmptyAnimationArray()
	AnimCache12 = sslUtility.EmptyAnimationArray()
	AnimCache13 = sslUtility.EmptyAnimationArray()
	AnimCache14 = sslUtility.EmptyAnimationArray()
	AnimCache15 = sslUtility.EmptyAnimationArray()
	AnimCache16 = sslUtility.EmptyAnimationArray()
	AnimCache17 = sslUtility.EmptyAnimationArray()
	AnimCache18 = sslUtility.EmptyAnimationArray()
	AnimCache19 = sslUtility.EmptyAnimationArray()
	AnimCache20 = sslUtility.EmptyAnimationArray()
	AnimCache21 = sslUtility.EmptyAnimationArray()
	AnimCache22 = sslUtility.EmptyAnimationArray()
	AnimCache23 = sslUtility.EmptyAnimationArray()
	AnimCache24 = sslUtility.EmptyAnimationArray()
	AnimCache25 = sslUtility.EmptyAnimationArray()
	AnimCache26 = sslUtility.EmptyAnimationArray()
	AnimCache27 = sslUtility.EmptyAnimationArray()
	AnimCache28 = sslUtility.EmptyAnimationArray()
	AnimCache29 = sslUtility.EmptyAnimationArray()
	Log("AnimCache: Cleared!")
endFunction

bool function ValidateCache()
	if SlottedCache != Slotted
		Log("AnimCache: INVALIDATED! "+SlottedCache+" -> "+Slotted)
		ClearAnimCache()
		return false
	endIf
	; SlottedCache = Slotted
	return true
endFunction

bool function IsCached(string CacheName)
	return ValidateCache() && FilterCache.Find(CacheName) != -1
endFunction

sslBaseAnimation[] function CheckCache(string CacheName)
	sslBaseAnimation[] Output
	if ValidateCache() && CacheName
		int i = FilterCache.Find(CacheName)
		if i != -1
			Output = GetCacheSlot(i)
			Log("AnimCache: HIT["+i+"] -- "+CacheName+" -- Count["+Output.Length+"]")
			if Output.Length >= 125 ; To prevent the same list be used more than 2 times if have more animations avalible
				InvalidateBySlot(i)
			else
				CacheTimes[i] = Utility.GetCurrentGameTime()
			endIf
		else
			Log("AnimCache: MISS -- "+CacheName)
		endIf
	endIf
	return Output
endFunction

function CacheAnims(string CacheName, sslBaseAnimation[] Anims)
	if !CacheName || !Anims
		return
	endIf
	; Pick cache slot
	int i = FilterCache.Find(CacheName)
	if i != -1
		Log("AnimCache: Refreshing slot: "+i)
	else
		i = FilterCache.Find("")
		if i != -1
			Log("AnimCache: Using slot: "+i)
		else
			i = OldestCache()
			Log("AnimCache: Replacing oldest slot: "+i)
		endIf
	endIf
	; Set cache slot
	if i <= 9 && i >= 0
		if i == 0
			AnimCache0 = Anims
		elseIf i == 1
			AnimCache1 = Anims
		elseIf i == 2
			AnimCache2 = Anims
		elseIf i == 3
			AnimCache3 = Anims
		elseIf i == 4
			AnimCache4 = Anims
		elseIf i == 5
			AnimCache5 = Anims
		elseIf i == 6
			AnimCache6 = Anims
		elseIf i == 7
			AnimCache7 = Anims
		elseIf i == 8
			AnimCache8 = Anims
		elseIf i == 9
			AnimCache9 = Anims
		endIf
	elseIf i <= 19
		if i == 10
			AnimCache10 = Anims
		elseIf i == 11
			AnimCache11 = Anims
		elseIf i == 12
			AnimCache12 = Anims
		elseIf i == 13
			AnimCache13 = Anims
		elseIf i == 14
			AnimCache14 = Anims
		elseIf i == 15
			AnimCache15 = Anims
		elseIf i == 16
			AnimCache16 = Anims
		elseIf i == 17
			AnimCache17 = Anims
		elseIf i == 18
			AnimCache18 = Anims
		elseIf i == 19
			AnimCache19 = Anims
		endIf
	elseIf i <= 29
		if i == 20
			AnimCache20 = Anims
		elseIf i == 21
			AnimCache21 = Anims
		elseIf i == 22
			AnimCache22 = Anims
		elseIf i == 23
			AnimCache23 = Anims
		elseIf i == 24
			AnimCache24 = Anims
		elseIf i == 25
			AnimCache25 = Anims
		elseIf i == 26
			AnimCache26 = Anims
		elseIf i == 27
			AnimCache27 = Anims
		elseIf i == 28
			AnimCache28 = Anims
		elseIf i == 29
			AnimCache29 = Anims
		endIf
	else
		Log("AnimCache: Invalid cache slot. This shouldn't be possible!")
		return
	endIf
	FilterCache[i] = CacheName
	CacheTimes[i] = Utility.GetCurrentGameTime()
endFunction

sslBaseAnimation[] function GetCacheSlot(int i)
	if i <= 9 && i >= 0
		if i == 0
			return AnimCache0
		elseIf i == 1
			return AnimCache1
		elseIf i == 2
			return AnimCache2
		elseIf i == 3
			return AnimCache3
		elseIf i == 4
			return AnimCache4
		elseIf i == 5
			return AnimCache5
		elseIf i == 6
			return AnimCache6
		elseIf i == 7
			return AnimCache7
		elseIf i == 8
			return AnimCache8
		elseIf i == 9
			return AnimCache9
		endIf
	elseIf i <= 19
		if i == 10
			return AnimCache10
		elseIf i == 11
			return AnimCache11
		elseIf i == 12
			return AnimCache12
		elseIf i == 13
			return AnimCache13
		elseIf i == 14
			return AnimCache14
		elseIf i == 15
			return AnimCache15
		elseIf i == 16
			return AnimCache16
		elseIf i == 17
			return AnimCache17
		elseIf i == 18
			return AnimCache18
		elseIf i == 19
			return AnimCache19
		endIf
	elseIf i <= 29
		if i == 20
			return AnimCache20
		elseIf i == 21
			return AnimCache21
		elseIf i == 22
			return AnimCache22
		elseIf i == 23
			return AnimCache23
		elseIf i == 24
			return AnimCache24
		elseIf i == 25
			return AnimCache25
		elseIf i == 26
			return AnimCache26
		elseIf i == 27
			return AnimCache27
		elseIf i == 28
			return AnimCache28
		elseIf i == 29
			return AnimCache29
		endIf
	endIf
	Log("AnimCache: GetCacheSlot("+i+") - INVALID CACHE SLOT")
	return sslUtility.EmptyAnimationArray()
endFunction

int function OldestCache()
	float var = CacheTimes[0]
	int index = 0
	int i = 1
	while i < CacheTimes.Length
		if CacheTimes[i] < var
			var = CacheTimes[i]
			index = i
		endIf
		i += 1
	endWhile
	return index
endFunction

function InvalidateByAnimation(sslBaseAnimation removing)
	int i = 0
	while i < FilterCache.Length
		sslBaseAnimation[] arr = GetCacheSlot(i)
		if arr && FilterCache[i] != "" && arr.Find(removing) != -1
			Log("InvalidateByAnimation: Found invalid animation in slot["+i+"]: "+FilterCache[i])
			InvalidateBySlot(i)
		endIf
		i += 1
	endWhile
endFunction

function InvalidateByTags(string Tags)
	string[] Search   = StringSplit(Tags)
	Search = ClearEmpty(Search)
	if Tags == "" || Search.Length == 0
		return
	endIf
	int i = 0
	int n = 0
	while n < Search.Length
		while i < FilterCache.Length
			if FilterCache[i] != "" && StringUtil.Find(FilterCache[i], "\""+Search[n]+"\"") >= 0
				Log("InvalidateByTags: Found invalid tag in slot["+i+"]: "+FilterCache[i])
				InvalidateBySlot(i)
			endIf
			i += 1
		endWhile
		n += 1
	endWhile
endFunction

function InvalidateBySlot(int i)
	FilterCache[i] = ""
	CacheTimes[i] = 0.0
endFunction

string function CacheInfo(int i)
	sslBaseAnimation[] arr = GetCacheSlot(i)
	return "["+i+"] -- Name: "+FilterCache[i]+" -- Timestamp: "+CacheTimes[i]+" -- Count: "+arr.Length
endfunction

function OutputCacheLog()
	int i = 0
	while i < FilterCache.Length
		Log(CacheInfo(i))
		i += 1
	endWhile
endFunction


String Property CacheID Auto Hidden
string[] function GetTagCache(bool IgnoreCache = false)
	if IgnoreCache || !StorageUtil.StringListHas(Config, CacheID, "Vaginal") || ((Utility.GetCurrentRealTime() as int) - StorageUtil.GetIntValue(Config, CacheID, 0)) > 360
		DoCache()
	endIf
	return StorageUtil.StringListToArray(Config, CacheID)
endFunction

bool function HasTagCache(string Tag ,bool IgnoreCache = false)
	if !Tag || Tag == ""
		return False
	endIf
	if IgnoreCache || !StorageUtil.StringListHas(Config, CacheID, "Vaginal") || ((Utility.GetCurrentRealTime() as int) - StorageUtil.GetIntValue(Config, CacheID, 0)) > 360
		DoCache()
	endIf
	return StorageUtil.StringListHas(Config, CacheID, Tag)
endFunction

function ClearTagCache()
	StorageUtil.StringListClear(Config, CacheID)
	StorageUtil.UnsetIntValue(Config, CacheID)
endFunction

function DoCache()
	if !CacheID
		Log("FAILED TO CACHE TAGS, CACHEID NOT SET")
		return
	endIf

	float time = Utility.GetCurrentRealTime()

	; Tags to ignore and will be pushed to front of list later.
	string[] Override = new string[9]
	Override[0] = "Vaginal"
	Override[1] = "Anal"
	Override[2] = "Oral"
	Override[3] = "Cowgirl"
	Override[4] = "Laying"
	Override[5] = "Missionary"
	Override[6] = "Standing"
	Override[7] = "Dirty"
	Override[8] = "Loving"

	; Find unique tags
	StorageUtil.StringListClear(Config, CacheID)
	int Slot
	while Slot < Slotted
		if Objects[Slot]
			string[] Tags = (Objects[Slot] as sslBaseAnimation).GetRawTags()
			int t = Tags.Length
			while t > 0
				t -= 1
				if Tags[t] != "" && Override.Find(Tags[t]) == -1
					StorageUtil.StringListAdd(Config, CacheID, Tags[t], false)
				endIf
			endWhile
		endIf
		Slot += 1
	endWhile
	StorageUtil.StringListSort(Config, CacheID)
	
	; Push common/important tags to front
	int i = Override.Length
	while i
		i -= 1
		StorageUtil.StringListInsert(Config, CacheID, 0, Override[i])
	endWhile

	StorageUtil.SetIntValue(Config, CacheID, Utility.GetCurrentRealTime() as int)
	Log(CacheID+" finished caching ("+StorageUtil.StringListCount(Config, CacheID)+") tags in ("+(Utility.GetCurrentRealTime() - time)+") seconds -- ");+StorageUtil.StringListToArray(Config, CacheID))
endFunction