scriptname sslThreadLibrary extends sslSystemLibrary
{
	Generic Utility to simplify thread building
	It is recommended to call these functions through the main API
}

Keyword property FurnitureBedRoll Auto

; ------------------------------------------------------- ;
; --- Bed Utility			                                --- ;
; ------------------------------------------------------- ;

; 0 - No bed / 1 - Bedroll / 2 - Single Bed / 3 - Double Bed
int Function GetBedType(ObjectReference BedRef)
	If(!BedRef || !sslpp.IsBed(BedRef))
		return 0
	EndIf
	Form BaseRef = BedRef.GetBaseObject()
	If(BedRef.HasKeyword(FurnitureBedRoll))
		return 1
	ElseIf(StringUtil.Find(sslpp.GetEditorID(BaseRef), "Double") > -1 || StringUtil.Find(sslpp.GetEditorID(BaseRef), "Single") == -1)
		return 3
	EndIf
	return 2
EndFunction

bool Function IsBedAvailable(ObjectReference BedRef)
	If(!BedRef || BedRef.IsFurnitureInUse(true))
		return false
	EndIf
	int i = 0
	While(i < ThreadSlots.Threads.Length)
		If(ThreadSlots.Threads[i].BedRef == BedRef)
			return false
		EndIf
		i += 1
	Endwhile
	return true
EndFunction

ObjectReference Function FindBed(ObjectReference CenterRef, float Radius = 1000.0, bool IgnoreUsed = true, ObjectReference IgnoreRef1 = none, ObjectReference IgnoreRef2 = none)
	If(!CenterRef || Radius < 1.0)
		return none
	EndIf
	ObjectReference[] beds = sslpp.FindBeds(CenterRef, Radius)
	int i = 0
	While(i < beds.Length)
		If(beds[i] != IgnoreRef1 && beds[i] != IgnoreRef2 && (IgnoreUsed || !beds[i].IsFurnitureInUse()))
			return beds[i]
		EndIf
		i += 1
	EndWhile
	return none
endFunction

; ------------------------------------------------------- ;
; --- Position Sorting                                --- ;
; ------------------------------------------------------- ;

Function SortPositions(Actor[] akPositions) global
	int[] keys = sslActorData.BuildDataKeyArray(akPositions)
	SortPositionsByKeys(akPositions, keys)
EndFunction

Function SortPositionsByKeys(Actor[] akPositions, int[] aiKeys) global
	int i = 1
	While(i < aiKeys.Length)
		int it = aiKeys[i]
		Actor it_p = akPositions[i]
		int n = i - 1
		While(n >= 0 && sslActorData.IsLess(it, aiKeys[n]))
			aiKeys[n + 1] = aiKeys[n]
			akPositions[n + 1] = akPositions[n]
			n -= 1
		EndWhile
		aiKeys[n + 1] = it
		akPositions[n + 1] = it_p
		i += 1
	EndWhile
EndFunction

; ------------------------------------------------------- ;
; --- Cell Searching                              		--- ;
; ------------------------------------------------------- ;

; TODO: Move all of these "FindActor" functions into the dll zzzz
; NOTE: To do this properly Ill need Ashals dll sources first, or redefine RaceKeys in my own dll

Actor function FindAvailableActor(ObjectReference CenterRef, float Radius = 5000.0, int FindGender = -1, Actor IgnoreRef1 = none, Actor IgnoreRef2 = none, Actor IgnoreRef3 = none, Actor IgnoreRef4 = none, string RaceKey = "")
	if !CenterRef || FindGender > 3 || FindGender < -1 || Radius < 0.1
		return none ; Invalid args
	endIf
	; Normalize creature genders search
	if RaceKey != "" || FindGender >= 2
		if FindGender == 0 || !Config.UseCreatureGender
			FindGender = 2
		elseIf FindGender == 1
			FindGender = 3
		endIf
	endIf
	; Create supression list
	Form[] Suppressed = new Form[25]
	Suppressed[24] = CenterRef
	Suppressed[23] = IgnoreRef1
	Suppressed[22] = IgnoreRef2
	Suppressed[21] = IgnoreRef3
	Suppressed[20] = IgnoreRef4
	; Attempt 20 times before giving up.
	int i = Suppressed.Length - 5
	while i > 0
		i -= 1
		Actor FoundRef = Game.FindRandomActorFromRef(CenterRef, Radius)
		if !FoundRef || FoundRef == none || (Suppressed.Find(FoundRef) == -1 && CheckActor(FoundRef, FindGender) && (RaceKey == "" || sslCreatureAnimationSlots.GetAllRaceKeys(FoundRef.GetLeveledActorBase().GetRace()).Find(RaceKey) != -1))
			return FoundRef ; None means no actor in radius, give up now
		endIf
		Suppressed[i] = FoundRef
	endWhile
	; No actor found in attempts
	return none
endFunction

Actor function FindAvailableActorInFaction(Faction FactionRef, ObjectReference CenterRef, float Radius = 5000.0, int FindGender = -1, Actor IgnoreRef1 = none, Actor IgnoreRef2 = none, Actor IgnoreRef3 = none, Actor IgnoreRef4 = none, bool HasFaction = True, string RaceKey = "", bool JustSameFloor = False)
	if !CenterRef || !FactionRef || FindGender > 3 || FindGender < -1 || Radius < 0.1
		return none ; Invalid args
	endIf
	; Normalize creature genders search
	if RaceKey != "" || FindGender >= 2
		if FindGender == 0 || !Config.UseCreatureGender
			FindGender = 2
		elseIf FindGender == 1
			FindGender = 3
		endIf
	endIf
	; Create supression list
	Form[] Suppressed = new Form[15] ; Reduce from 25 to 15 to gain speed
	Suppressed[14] = CenterRef
	Suppressed[13] = IgnoreRef1
	Suppressed[12] = IgnoreRef2
	Suppressed[11] = IgnoreRef3
	Suppressed[10] = IgnoreRef4
	; Attempt 20 times before giving up.
	float Z = CenterRef.GetPositionZ()
	int i = Suppressed.Length - 5
	while i > 0
		i -= 1
		Actor FoundRef = Game.FindRandomActorFromRef(CenterRef, Radius)
		if !FoundRef || (Suppressed.Find(FoundRef) == -1 && (!JustSameFloor || SameFloor(FoundRef, Z, 200)) && CheckActor(FoundRef, FindGender) && FoundRef.IsInFaction(FactionRef) == HasFaction && (RaceKey == "" || sslCreatureAnimationSlots.GetAllRaceKeys(FoundRef.GetLeveledActorBase().GetRace()).Find(RaceKey) != -1))
			return FoundRef ; None means no actor in radius, give up now
		endIf
		Suppressed[i] = FoundRef
	endWhile
	; No actor found in attempts
	return none
endFunction

Actor function FindAvailableActorWornForm(int slotMask, ObjectReference CenterRef, float Radius = 5000.0, int FindGender = -1, Actor IgnoreRef1 = none, Actor IgnoreRef2 = none, Actor IgnoreRef3 = none, Actor IgnoreRef4 = none, bool AvoidNoStripKeyword = True, bool HasWornForm = True, string RaceKey = "", bool JustSameFloor = False)
	if !CenterRef || slotMask < 1 || FindGender > 3 || FindGender < -1 || Radius < 0.1
		return none ; Invalid args
	endIf
	; Normalize creature genders search
	if RaceKey != "" || FindGender >= 2
		if FindGender == 0 || !Config.UseCreatureGender
			FindGender = 2
		elseIf FindGender == 1
			FindGender = 3
		endIf
	endIf
	; Create supression list
	Form[] Suppressed = new Form[15] ; Reduce from 25 to 15 to gain speed
	Suppressed[14] = CenterRef
	Suppressed[13] = IgnoreRef1
	Suppressed[12] = IgnoreRef2
	Suppressed[11] = IgnoreRef3
	Suppressed[10] = IgnoreRef4
	; Attempt 20 times before giving up.
	float Z = CenterRef.GetPositionZ()
	int i = Suppressed.Length - 5
	while i > 0
		i -= 1
		Actor FoundRef = Game.FindRandomActorFromRef(CenterRef, Radius)
		if !FoundRef || FoundRef == none
			return FoundRef ; None means no actor in radius, give up now
		endIf
		if (Suppressed.Find(FoundRef) == -1 && (!JustSameFloor || SameFloor(FoundRef, Z, 200)) && CheckActor(FoundRef, FindGender) && (RaceKey == "" || sslCreatureAnimationSlots.GetAllRaceKeys(FoundRef.GetLeveledActorBase().GetRace()).Find(RaceKey) != -1))
			
			Form ItemRef = FoundRef.GetWornForm(slotMask)
			if ((ItemRef && ItemRef != none) == HasWornForm) && (!AvoidNoStripKeyword || !SexLabUtil.HasKeywordSub(ItemRef, "NoStrip"))
				return FoundRef ; None means no actor in radius, give up now
			endIf
		endIf
		Suppressed[i] = FoundRef
	endWhile
	; No actor found in attempts
	return none
endFunction

; TODO: probably needs some love
Actor[] function FindAvailablePartners(actor[] Positions, int total, int males = -1, int females = -1, float radius = 10000.0)
	int ActorCount = Positions.Length
	int needed = (total - ActorCount)
	if needed <= 0
		return Positions ; Nothing to do
	endIf
	actor[] ActorsRef = Positions
	; Get needed gender counts based on current counts
	int[] Genders = ActorLib.GenderCount(ActorsRef)
	males -= Genders[0]
	females -= Genders[1]
	; Loop through until filled or we give up
	int attempts = 30
	while needed && attempts
		; Determine needed gender
		int findGender = -1
		if males > 0 && females < 1
			findGender = 0
		elseif females > 0 && males < 1
			findGender = 1
		endIf
		; Locate actor
		actor FoundRef
		if ActorCount == 2
			FoundRef = FindAvailableActor(ActorsRef[0], radius, findGender, ActorsRef[1])
		elseif ActorCount == 3
			FoundRef = FindAvailableActor(ActorsRef[0], radius, findGender, ActorsRef[1], ActorsRef[2])
		elseif ActorCount == 4
			FoundRef = FindAvailableActor(ActorsRef[0], radius, findGender, ActorsRef[1], ActorsRef[2], ActorsRef[3])
		else
			FoundRef = FindAvailableActor(ActorsRef[0], radius, findGender)
		endIf
		; Validate/Add them
		if !FoundRef
			return ActorsRef ; None means no actor in radius, give up now
		elseIf ActorsRef.Find(FoundRef) == -1
			; Add actor
			ActorsRef = PapyrusUtil.PushActor(ActorsRef, FoundRef)
			; Update search counts
			int gender = ActorLib.GetGender(FoundRef)
			males   -= (gender == 0) as int
			females -= (gender == 1) as int
			needed  -= 1
		endIf
		attempts -= 1
	endWhile
	; Output whatever we have at this point
	return ActorsRef
endFunction

Actor[] function FindAnimationPartners(sslBaseAnimation Animation, ObjectReference CenterRef, float Radius = 5000.0, Actor IncludedRef1 = none, Actor IncludedRef2 = none, Actor IncludedRef3 = none, Actor IncludedRef4 = none)
	if !Animation || !CenterRef
		return PapyrusUtil.ActorArray(0)
	endIf
	
	Actor[] IncludedActors = sslUtility.MakeActorArray(IncludedRef1, IncludedRef2, IncludedRef3, IncludedRef4)
	Actor[] Positions = PapyrusUtil.ActorArray(5)
	int i
	while i < Animation.PositionCount
		; Determine needed gender and race
		string RaceKey = ""
		int FindGender = Animation.GetGender(i)
		if FindGender > 1
			RaceKey = Animation.GetRaceTypes()[i]
		elseif FindGender > 0 && !(Animation.HasTag("Vaginal") || Animation.HasTag("Pussy") || Animation.HasTag("Cunnilingus") || Animation.HasTag("Futa"))
			FindGender = -1
		elseif FindGender == 0 && Config.UseStrapons && Animation.UseStrapon(i, 1)
			FindGender = -1
		endIf

		; Locate the actor between the included actors
		int a = IncludedActors.Length
		while a > 0 
			a -= 1
			if CheckActor(IncludedActors[a], FindGender) && (RaceKey == "" || sslCreatureAnimationSlots.GetAllRaceKeys(IncludedActors[a].GetLeveledActorBase().GetRace()).Find(RaceKey) != -1)
				Positions[i] = IncludedActors[a]
				IncludedActors = PapyrusUtil.RemoveActor(IncludedActors, IncludedActors[a])
				a = 0
			endIf
		endWhile
		
		; Find the nearby actor
		if !Positions[i] || Positions[i] == none
			Positions[i] = FindAvailableActor(CenterRef, Radius, FindGender, Positions[1], Positions[2], Positions[3], Positions[4], RaceKey)
			; One more time just in case
			if !Positions[i] || Positions[i] == none
				Positions[i] = FindAvailableActor(CenterRef, Radius, FindGender, Positions[1], Positions[2], Positions[3], Positions[4], RaceKey)
			endIf
		endIf
		
		if !Positions[i] || Positions[i] == none
			return PapyrusUtil.RemoveActor(Positions, none)
		elseIf IncludedActors.Length > 0
			IncludedActors = PapyrusUtil.RemoveActor(IncludedActors, Positions[i])
		endIf
		i += 1
	endWhile
	; Output whatever we have at this point
	return PapyrusUtil.RemoveActor(Positions, none)
endFunction

; COMEBACK: This here should also become Legacy once things are moved into dll :)
bool function SameFloor(ObjectReference BedRef, float Z, float Tolerance = 15.0)
	return BedRef && Math.Abs(Z - BedRef.GetPositionZ()) <= Tolerance
endFunction

; COMEBACK: ??? - Make this redundant once no longer called here
bool function CheckActor(Actor CheckRef, int CheckGender = -1)
	if !CheckRef
		return false
	endIf
	int IsGender = ActorLib.GetGender(CheckRef)
	return ((CheckGender < 2 && IsGender < 2) || (CheckGender >= 2 && IsGender >= 2)) && (CheckGender == -1 || IsGender == CheckGender) && ActorLib.IsValidActor(CheckRef)
endFunction

; ------------------------------------------------------- ;
; --- Actor Tracking                                  --- ;
; ------------------------------------------------------- ;

function TrackActor(Actor ActorRef, string Callback)
	StorageUtil.FormListAdd(Config, "TrackedActors", ActorRef, false)
	StorageUtil.StringListAdd(ActorRef, "SexLabEvents", Callback, false)
endFunction

function TrackFaction(Faction FactionRef, string Callback)
	If(FactionRef)
		StorageUtil.FormListAdd(Config, "TrackedFactions", FactionRef, false)
		StorageUtil.StringListAdd(FactionRef, "SexLabEvents", Callback, false)
	EndIf
endFunction

function UntrackActor(Actor ActorRef, string Callback)
	StorageUtil.StringListRemove(ActorRef, "SexLabEvents", Callback, true)
	if StorageUtil.StringListCount(ActorRef, "SexLabEvents") < 1
		StorageUtil.FormListRemove(Config, "TrackedActors", ActorRef, true)
	endif
endFunction

function UntrackFaction(Faction FactionRef, string Callback)
	StorageUtil.StringListRemove(FactionRef, "SexLabEvents", Callback, true)
	if StorageUtil.StringListCount(FactionRef, "SexLabEvents") < 1
		StorageUtil.FormListRemove(Config, "TrackedFactions", FactionRef, true)
	endif
endFunction

bool function IsActorTracked(Actor ActorRef)
	if ActorRef == PlayerRef || StorageUtil.StringListCount(ActorRef, "SexLabEvents") > 0
		return true
	endIf
	Form[] f = StorageUtil.FormListToArray(Config, "TrackedFactions")
	int i = 0
	While(i < f.Length)
		If(ActorRef.IsInFaction(f[i] as Faction))
			return true
		EndIf
		i += 1
	EndWhile
	return false
endFunction

function SendTrackedEvent(Actor ActorRef, string Hook = "", int id = -1)
	If(Hook)
		Hook = "_" + Hook
	EndIf
	If(ActorRef == PlayerRef)
		SetupActorEvent(PlayerRef, "PlayerTrack" + Hook, id)
	EndIf
	String[] genericcallbacks = StorageUtil.StringListToArray(ActorRef, "SexLabEvents")
	int i = 0
	While(i < genericcallbacks.Length)
		SetupActorEvent(PlayerRef, genericcallbacks[i] + Hook, id)
		i += 1
	EndWhile
	Form[] factioncallbacks = StorageUtil.FormListToArray(Config, "TrackedFactions")
	int n = 0
	While(n < factioncallbacks.Length)
		If(ActorRef.IsInFaction(factioncallbacks[n] as Faction))
			String[] factionevents = StorageUtil.StringListToArray(factioncallbacks[n], "SexLabEvents")
			int k = 0
			While(k < factionevents.Length)
				SetupActorEvent(PlayerRef, factionevents[k] + Hook, id)
				k += 1
			EndWhile
		EndIf
		n += 1
	EndWhile
EndFunction

function SetupActorEvent(Actor ActorRef, string Callback, int id = -1)
	int eid = ModEvent.Create(Callback)
	ModEvent.PushForm(eid, ActorRef)
	ModEvent.PushInt(eid, id)
	ModEvent.Send(eid)
endFunction

; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*	;
;																																											;
;									██╗     ███████╗ ██████╗  █████╗  ██████╗██╗   ██╗									;
;									██║     ██╔════╝██╔════╝ ██╔══██╗██╔════╝╚██╗ ██╔╝									;
;									██║     █████╗  ██║  ███╗███████║██║      ╚████╔╝ 									;
;									██║     ██╔══╝  ██║   ██║██╔══██║██║       ╚██╔╝  									;
;									███████╗███████╗╚██████╔╝██║  ██║╚██████╗   ██║   									;
;									╚══════╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝   ╚═╝   									;
;																																											;
; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*	;

FormList property BedsList Auto
FormList property DoubleBedsList Auto
FormList property BedRollsList Auto

Actor[] Function SortActors(Actor[] Positions, bool FemaleFirst = true)
	Log("Sort Actors | Original Array = " + Positions)
	int[] genders = ActorLib.GetGendersAll(Positions)
	int i = 1
	While(i < Positions.Length)
		Actor it = Positions[i]
		int _it = genders[i]
		int n = i - 1
		While(n >= 0 && !IsLesserGender(genders[n], _it, FemaleFirst))
			Positions[n + 1] = Positions[n]
			genders[n + 1] = genders[n]
			n -= 1
		EndWhile
		Positions[n + 1] = it
		genders[n + 1] = _it
		i += 1
	EndWhile
	Log("Sort Actors | Sorted Array = " + Positions)
	return Positions
EndFunction
bool Function IsLesserGender(int i, int n, bool abFemaleFirst)
	return n != i && (i == (abFemaleFirst as int) || i == 3 && n == 2 || i < n)
EndFunction

bool Function IsBedRoll(ObjectReference BedRef)
	return GetBedType(BedRef) == 1
EndFunction

bool function IsDoubleBed(ObjectReference BedRef)
	return GetBedType(BedRef) == 3
endFunction

bool function IsSingleBed(ObjectReference BedRef)
	return GetBedType(BedRef) == 2
endFunction

; w/e this these are even good for
int function FindNext(Actor[] Positions, sslBaseAnimation Animation, int offset, bool FindCreature)
	while offset
		offset -= 1
		if Animation.HasRace(Positions[offset].GetLeveledActorBase().GetRace()) == FindCreature
			return offset
		endIf
	endwhile
	return -1
endFunction
bool function CheckBed(ObjectReference BedRef, bool IgnoreUsed = true)
	return BedRef && BedRef.IsEnabled() && BedRef.Is3DLoaded() && (!IgnoreUsed || (IgnoreUsed && IsBedAvailable(BedRef)))
endFunction
bool function LeveledAngle(ObjectReference ObjectRef, float Tolerance = 5.0)
	return ObjectRef && Math.Abs(ObjectRef.GetAngleX()) <= Tolerance && Math.Abs(ObjectRef.GetAngleY()) <= Tolerance
endFunction

Actor[] function SortActorsByAnimation(actor[] Positions, sslBaseAnimation Animation = none)
	SortPositions(Positions)
	return Positions
endFunction

Actor[] function SortCreatures(actor[] Positions, sslBaseAnimation Animation = none)
	SortPositions(Positions)
	return Positions
endFunction
