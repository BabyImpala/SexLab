ScriptName sslThreadModel extends Quest Hidden
{ Animation Thread Model: Runs storage and information about a thread. Access only through functions; NEVER create a Property directly to this. }

int thread_id
int Property tid hidden
	int Function get()
		return thread_id
	EndFunction
EndProperty

bool Property IsLocked hidden
	bool Function get()
		return GetState() != "Unlocked"
	EndFunction
EndProperty

; Constants
int Property POSITION_COUNT_MAX = 5 AutoReadOnly

; Library & Data
sslSystemConfig Property Config auto
sslActorLibrary Property ActorLib auto
sslThreadLibrary Property ThreadLib auto
sslAnimationSlots Property AnimSlots auto
sslCreatureAnimationSlots Property CreatureSlots auto

; Actor Info
sslActorAlias[] Property ActorAlias auto hidden
Actor[] Property Positions Auto Hidden

Actor Property PlayerRef auto hidden

; Thread status
; bool[] Property Status auto hidden
bool Property HasPlayer
	bool Function Get()
		return Positions.Find(PlayerRef) > -1
	EndFunction
EndProperty

bool Property AutoAdvance auto hidden
bool Property LeadIn auto hidden
bool Property FastEnd auto hidden

; Creature animation
Race Property CreatureRef auto hidden

; Animation Info
int Property Stage Auto Hidden
int Property ActorCount
	int Function Get()
		return Positions.Length
	EndFunction
EndProperty

Sound Property SoundFX auto hidden
string Property AdjustKey auto hidden
string[] Property AnimEvents auto hidden

sslBaseAnimation Property Animation auto hidden
sslBaseAnimation Property StartingAnimation auto hidden
sslBaseAnimation[] CustomAnimations
sslBaseAnimation[] PrimaryAnimations
sslBaseAnimation[] LeadAnimations
sslBaseAnimation[] Property Animations hidden
	sslBaseAnimation[] Function get()
		if CustomAnimations.Length > 0
			return CustomAnimations
		elseIf LeadIn
			return LeadAnimations
		else
			return PrimaryAnimations
		endIf
	EndFunction
EndProperty

; Stat Tracking Info
float[] Property SkillBonus auto hidden ; [0] Foreplay, [1] Vaginal, [2] Anal, [3] Oral, [4] Pure, [5] Lewd
float[] Property SkillXP auto hidden    ; [0] Foreplay, [1] Vaginal, [2] Anal, [3] Oral, [4] Pure, [5] Lewd

bool[] Property IsType auto hidden ; [0] IsAggressive, [1] IsVaginal, [2] IsAnal, [3] IsOral, [4] IsLoving, [5] IsDirty, [6] HadVaginal, [7] HadAnal, [8] HadOral
bool Property IsAggressive hidden
	bool Function get()
		return IsType[0]
	endfunction
	Function set(bool value)
		IsType[0] = value
	EndFunction
EndProperty
bool Property IsVaginal hidden
	bool Function get()
		return IsType[1]
	endfunction
	Function set(bool value)
		IsType[1] = value
	EndFunction
EndProperty
bool Property IsAnal hidden
	bool Function get()
		return IsType[2]
	endfunction
	Function set(bool value)
		IsType[2] = value
	EndFunction
EndProperty
bool Property IsOral hidden
	bool Function get()
		return IsType[3]
	endfunction
	Function set(bool value)
		IsType[3] = value
	EndFunction
EndProperty
bool Property IsLoving hidden
	bool Function get()
		return IsType[4]
	endfunction
	Function set(bool value)
		IsType[4] = value
	EndFunction
EndProperty
bool Property IsDirty hidden
	bool Function get()
		return IsType[5]
	endfunction
	Function set(bool value)
		IsType[5] = value
	EndFunction
EndProperty


; Timer Info
bool UseCustomTimers
float[] CustomTimers
float[] ConfigTimers
float[] Property Timers hidden
	float[] Function get()
		if UseCustomTimers
			return CustomTimers
		endIf
		return ConfigTimers
	EndFunction
	Function set(float[] value)
	;	if UseCustomTimers
	;		CustomTimers = value
	;	else
	;		ConfigTimers = value
	;	endIf
	if !value || value.Length < 1
		Log("Set() - Empty timers given for Property Timers.", "ERROR")
	else
		CustomTimers    = value
		UseCustomTimers = true
	endIf
	EndFunction
EndProperty

; Thread info
float[] Property CenterLocation Auto Hidden
ReferenceAlias Property CenterAlias Auto Hidden	; This is the Alias holding the object used as Center
ObjectReference Property CenterRef							; This is the ObjectReference the above alias holds
	ObjectReference Function Get()
		return CenterAlias.GetReference()
	EndFunction
	Function Set(ObjectReference akNewCenter)
		CenterOnObject(akNewCenter)
	EndFunction
EndProperty
ObjectReference _Center	; This is the actual center object the animation is using

float[] Property RealTime auto hidden
float Property StartedAt auto hidden
float Property TotalTime hidden
	float Function get()
		return RealTime[0] - StartedAt
	EndFunction
EndProperty

Actor[] property Victims auto hidden
Actor property VictimRef hidden
	Actor Function Get()
		If(Victims.Length)
			return Victims[0]
		EndIf
		return none
	EndFunction
	Function Set(Actor ActorRef)
		If(!ActorRef)
			return
		ElseIf(!Victims || Victims.Find(ActorRef) == -1)
			Victims = PapyrusUtil.PushActor(Victims, ActorRef)
		endIf
		IsAggressive = true
	EndFunction
EndProperty

bool property DisableOrgasms auto hidden

; Beds
int[] Property BedStatus auto hidden
; BedStatus[0] = -1 forbid, 0 allow, 1 force
; BedStatus[1] = 0 none, 1 bedroll, 2 single, 3 double
ObjectReference Property BedRef auto hidden
int Property BedTypeID hidden
	int Function get()
		return BedStatus[1]
	EndFunction
EndProperty
bool Property UsingBed hidden
	bool Function get()
		return BedStatus[1] > 0
	EndFunction
EndProperty
bool Property UsingBedRoll hidden
	bool Function get()
		return BedStatus[1] == 1
	EndFunction
EndProperty
bool Property UsingSingleBed hidden
	bool Function get()
		return BedStatus[1] == 2
	EndFunction
EndProperty
bool Property UsingDoubleBed hidden
	bool Function get()
		return BedStatus[1] == 3
	EndFunction
EndProperty
bool Property UseNPCBed hidden
	bool Function get()
		int NPCBed = Config.NPCBed
		return NPCBed == 2 || (NPCBed == 1 && (Utility.RandomInt(0, 1) as bool))
	EndFunction
EndProperty

; Genders
int[] Property Genders auto hidden
int Property Males hidden
	int Function get()
		return Genders[0]
	EndFunction
EndProperty
int Property Females hidden
	int Function get()
		return Genders[1]
	EndFunction
EndProperty

bool Property HasCreature hidden
	bool Function get()
		return Creatures > 0
	EndFunction
EndProperty
int Property Creatures hidden
	int Function get()
		return Genders[2] + Genders[3]
	EndFunction
EndProperty
int Property MaleCreatures hidden
	int Function get()
		return Genders[2]
	EndFunction
EndProperty
int Property FemaleCreatures hidden
	int Function get()
		return Genders[3]
	EndFunction
EndProperty

; Local readonly
string[] Hooks
string[] Tags
string ActorKeys

; Debug testing
bool Property DebugMode auto hidden
float Property t auto hidden

int[] Function GetAllPositionKeys()
	int[] ret = Utility.CreateIntArray(Positions.Length)
	int j = 0
	While(j < Positions.Length)
		ret[j] = ActorAlias[j].ActorKey
		j += 1
	EndWhile
	return ret
EndFunction

; ------------------------------------------------------- ;
; --- Thread Making API                               --- ;
; ------------------------------------------------------- ;

State Making
	Event OnBeginState()
		Log("Entering Making State")
		RegisterForSingleUpdate(60.0)
		; Action Events
		RegisterForModEvent(Key("RealignActors"), "RealignActors") ; To be used by the ConfigMenu without the CloseConfig issue
		RegisterForModEvent(Key(EventTypes[0]+"Done"), EventTypes[0]+"Done")
		; RegisterForModEvent(Key(EventTypes[1]+"Done"), EventTypes[1]+"Done")	; Sync
		RegisterForModEvent(Key(EventTypes[2]+"Done"), EventTypes[2]+"Done")
		RegisterForModEvent(Key(EventTypes[3]+"Done"), EventTypes[3]+"Done")
		RegisterForModEvent(Key(EventTypes[4]+"Done"), EventTypes[4]+"Done")
	EndEvent
	Event OnUpdate()
		ReportAndFail("Thread has timed out of the making process; resetting model for selection pool")
	EndEvent

	int Function AddActor(Actor ActorRef, bool IsVictim = false, sslBaseVoice Voice = none, bool ForceSilent = false)
		If(!ActorRef)
			ReportAndFail("Failed to add actor -- Actor is a figment of your imagination", "AddActor(NONE)")
			return -1
		ElseIf(ActorCount >= POSITION_COUNT_MAX)
			ReportAndFail("Failed to add actor -- Thread has reached actor limit", "AddActor(" + ActorRef.GetLeveledActorBase().GetName() + ")")
			return -1
		ElseIf(Positions.Find(ActorRef) != -1)
			ReportAndFail("Failed to add actor -- They have been already added to this thread", "AddActor(" + ActorRef.GetLeveledActorBase().GetName() + ")")
			return -1
		ElseIf(ActorLib.ValidateActor(ActorRef) < 0)
			ReportAndFail("Failed to add actor -- They are not a valid target for animation", "AddActor(" + ActorRef.GetLeveledActorBase().GetName() + ")")
			return -1
		EndIf
		sslActorAlias Slot = PickAlias(ActorRef)
		If(!Slot || !Slot.SetActorEx(ActorRef, IsVictim, Voice, ForceSilent))
			ReportAndFail("Failed to add actor -- They were unable to fill an actor alias", "AddActor(" + ActorRef.GetLeveledActorBase().GetName() + ")")
			return -1
		EndIf
		Positions = PapyrusUtil.PushActor(Positions, ActorRef)
		return Positions.Find(ActorRef)
	EndFunction

	bool Function AddActors(Actor[] ActorList, Actor VictimActor = none)
		int i = 0
		While(i < ActorList.Length)
			If(AddActor(ActorList[i], ActorList[i] == VictimActor) == -1)
				return false
			EndIf
			i += 1
		EndWhile
		return true
	EndFunction

	bool Function SetAnimationsByTags(String asTags, int aiUseBed)
		int[] keys = GetAllPositionKeys()
		If(!keys.Length)
			return false
		EndIf
		keys = sslActorKey.SortActorKeyArray(keys)
		sslBaseAnimation[] anims = AnimSlots.GetAnimationsByKeys(keys, asTags, aiUseBed - 1)
		If(anims.Length)
			SetAnimations(anims)
			return true
		EndIf
		return false
	EndFunction

	sslThreadController Function StartThread()
		SendThreadEvent("AnimationStarting")
		UnregisterForUpdate()

		ThreadHooks = Config.GetThreadHooks()
		HookAnimationStarting()

		; ------------------------- ;
		; --   Validate Thread   -- ;
		; ------------------------- ;

		Positions = PapyrusUtil.RemoveActor(Positions, none)
		If(Positions.Length < 1 || Positions.Length >= POSITION_COUNT_MAX)
			ReportAndFail("Failed to start Thread -- No valid actors available for animation")
			return none
		ElseIf(Positions.Find(none) != -1)
			ReportAndFail("Failed to start Thread -- Positions array contains invalid values")
			return none
		EndIf

		; Sort all positions
		int i = 1
		While(i < Positions.Length)
			sslActorAlias it_s = ActorAlias[i]
			int n = i - 1
			While(n >= 0 && !sslActorKey.IsLesserKey(ActorAlias[n].ActorKey, it_s.ActorKey))
				ActorAlias[n + 1] = ActorAlias[n]
				n -= 1
			EndWhile
			ActorAlias[n + 1] = it_s
			i += 1
		EndWhile
		int k = 0
		While(k < Positions.Length)
			Positions[k] = ActorAlias[k].GetReference() as Actor
			k +=1
		EndWhile

		; Legacy Data
		int[] g = ActorLib.GetGendersAll(Positions)
		Genders[0] = PapyrusUtil.CountInt(g, 0)
		Genders[1] = PapyrusUtil.CountInt(g, 1)
		Genders[2] = PapyrusUtil.CountInt(g, 2)
		Genders[3] = PapyrusUtil.CountInt(g, 3)

		; ------------------------- ;
		; -- Validate Animations -- ;
		; ------------------------- ;

		CustomAnimations = ValidateAnimations(CustomAnimations)
		If(CustomAnimations.Length)
			AddCommonTags(CustomAnimations)
			If(LeadIn)
				Log("WARNING: LeadIn detected on custom Animations. Disabling LeadIn")
				LeadIn = false
			EndIf
		Else
			; No Custom Animations. If there were thered be no point validating these
			PrimaryAnimations = ValidateAnimations(PrimaryAnimations)
			If(LeadIn)
				LeadAnimations = ValidateAnimations(LeadAnimations)
				If(!LeadAnimations.Length)
					LeadAnimations = AnimSlots._GetAnimations(GetAllPositionKeys(), Utility.CreateStringArray(0))
					LeadIn = LeadAnimations.Length
				EndIf
			Else
				; COMEBACK: This doesnt actually do anything, idk why its there or if I should remove it
				; float LeadInCoolDown = Math.Abs(SexLabUtil.GetCurrentGameRealTime() - StorageUtil.GetFloatValue(Config,"SexLab.LastLeadInEnd",0))
				; If(LeadInCoolDown < Config.LeadInCoolDown)
				; 	Log("LeadIn CoolDown " + LeadInCoolDown + "::" + Config.LeadInCoolDown)
				; 	DisableLeadIn(True)
				; ElseIf(Config.LeadInCoolDown > 0 && PrimaryAnimations && PrimaryAnimations.Length && AnimSlots.CountTag(PrimaryAnimations, "Anal,Vaginal") < 1)
				; 	Log("None of the PrimaryAnimations have 'Anal' or 'Vaginal' tags. Disabling LeadIn")
				; 	DisableLeadIn(True)
				; endIf
			EndIf
			If(PrimaryAnimations.Length + LeadAnimations.Length == 0)
				ReportAndFail("Failed to start Thread -- No valid animations for given actors")
				return none
			EndIf
			AddCommonTags(PrimaryAnimations)
		EndIf
		
		; ------------------------- ;
		; --    Locate Center    -- ;
		; ------------------------- ;

		If(!CenterRef)
			; Lil bit odd to read. 'CenterOnBed' return true if a center bed was set, thus never entering this branch
			If(ActorCount == Creatures || HasTag("Furniture") || !CenterOnBed(HasPlayer, 750.0))
				int n = Positions.Find(PlayerRef)
				If(n == -1)
					int j = 0
					While(j < Positions.Length)
						If(!Positions[j].GetFurnitureReference() && !Positions[i].IsSwimming() && !Positions[i].IsFlying())
							n = j
							j = Positions.Length
						Else
							j += 1
						endIf
					EndWhile
					If(n == -1)
						n = 0
					EndIf
				EndIf
				CenterOnObject(Positions[n])
			EndIf
		EndIf

		if Config.ShowInMap && !HasPlayer && PlayerRef.GetDistance(CenterRef) > 750
			SetObjectiveDisplayed(0, True)
		endIf
	
		; ------------------------- ;
		; --  Start Controller   -- ;
		; ------------------------- ;

		; NOTE: The below comment links to a thread that has been merged with this function,see below \o/
		; COMEBACK: I dont understand why this isnt just part of this codeblock here directly
		; Just massively harms readability and overcomplicates scene starting
		; Not to mention that the actual code executed here is in the child script, not the parent, not even as abstract func
		; see sslThreadController State 'Prepare'.OnBeginState() to see the second part of this function
		; GoToState("Prepare")
		
		; COMEBACK: Move this into some 'unsafe' startthread() func instead, to call with the new API which wont need above validation
		HookAnimationPrepare()
		; UpdateAdjustKey()	; TODO: Set adjust key AFTER deciding the animation | BEFORE placing actors
		; TODO: This here should be simplified. A lot
		if StartingAnimation && Animations.Find(StartingAnimation) != -1
			SetAnimation(Animations.Find(StartingAnimation))
		else
			SetAnimation()
			StartingAnimation = none
		endIf
		; Log(AdjustKey, "Adjustment Profile")
		; Begin actor prep
		SyncEvent(kPrepareActor, 40.0)
		If(HasPlayer)
			Config.ApplyFade()
		EndIf

		return self as sslThreadController
	EndFunction

	; Invoked after kPrepareActor is done for all actors
	Event PrepareDone()
		; TODO: Position adjustments, should be part of actual placement
		; int AdjustPos = Positions.Find(Config.TargetRef)
		; if AdjustPos == -1
		; 	AdjustPos   = (Positions.Length > 1) as int
		; 	if Positions[AdjustPos] != PlayerRef
		; 		Config.TargetRef = Positions[AdjustPos]
		; 	endIf
		; endIf
		; AdjustAlias = PositionAlias(AdjustPos)
		; Send starter events
		SendThreadEvent("AnimationStart")
		If(LeadIn)
			SendThreadEvent("LeadInStart")
		EndIf
		; Start time trackers ; NOTE: This is part of the child rn. TODO: move to parent or remove entirely, idk
		RealTime[0] = SexLabUtil.GetCurrentGameRealTime()
		SetTimeThings()
		; Start actor loops
		int i = 0
		While(i < Positions.Length)
			ActorAlias[i].CompletePreperation()
			i += 1
		EndWhile
		PlaceActors()
		; assert(Stage == 1)
		ProgressAnimationImpl()
		Config.RemoveFade()
	EndEvent
EndState

; ------------------------------------------------------- ;
; --- Actor Setup                                     --- ;
; ------------------------------------------------------- ;

bool Function UseLimitedStrip()
	bool LeadInNoBody = !(Config.StripLeadInMale[2] || Config.StripLeadInFemale[2])
	return (LeadIn && (!LeadInNoBody || AnimSlots.CountTag(Animations, "LimitedStrip") == Animations.Length)) || (Config.LimitedStrip && ((!LeadInNoBody && AnimSlots.CountTag(Animations, "Kissing,Foreplay,LeadIn,LimitedStrip") == Animations.Length) || (LeadInNoBody && AnimSlots.CountTag(Animations, "LimitedStrip") == Animations.Length)))
EndFunction

; Actor Overrides
Function SetStrip(Actor ActorRef, bool[] StripSlots)
	if StripSlots && StripSlots.Length == 33
		ActorAlias(ActorRef).OverrideStrip(StripSlots)
	else
		Log("Malformed StripSlots bool[] passed, must be 33 length bool array, "+StripSlots.Length+" given", "ERROR")
	endIf
EndFunction

Function SetNoStripping(Actor ActorRef)
	if ActorRef
		bool[] StripSlots = new bool[33]
		sslActorAlias Slot = ActorAlias(ActorRef)
		if Slot
			Slot.OverrideStrip(StripSlots)
			Slot.DoUndress = false
		endIf
	endIf
EndFunction

Function DisableUndressAnimation(Actor ActorRef = none, bool disabling = true)
	if ActorRef && Positions.Find(ActorRef) != -1
		ActorAlias(ActorRef).DoUndress = !disabling
	else
		ActorAlias[0].DoUndress = !disabling
		ActorAlias[1].DoUndress = !disabling
		ActorAlias[2].DoUndress = !disabling
		ActorAlias[3].DoUndress = !disabling
		ActorAlias[4].DoUndress = !disabling
	endIf
EndFunction

Function DisableRedress(Actor ActorRef = none, bool disabling = true)
	if ActorRef && Positions.Find(ActorRef) != -1
		ActorAlias(ActorRef).DoRedress = !disabling
	else
		ActorAlias[0].DoRedress = !disabling
		ActorAlias[1].DoRedress = !disabling
		ActorAlias[2].DoRedress = !disabling
		ActorAlias[3].DoRedress = !disabling
		ActorAlias[4].DoRedress = !disabling
	endIf
EndFunction

Function DisableRagdollEnd(Actor ActorRef = none, bool disabling = true)
	if ActorRef && Positions.Find(ActorRef) != -1
		ActorAlias(ActorRef).DoRagdoll = !disabling
	else
		ActorAlias[0].DoRagdoll = !disabling
		ActorAlias[1].DoRagdoll = !disabling
		ActorAlias[2].DoRagdoll = !disabling
		ActorAlias[3].DoRagdoll = !disabling
		ActorAlias[4].DoRagdoll = !disabling
	endIf
EndFunction

Function DisablePathToCenter(Actor ActorRef = none, bool disabling = true)
	if ActorRef && Positions.Find(ActorRef) != -1
		ActorAlias(ActorRef).DisablePathToCenter(disabling)
	else
		ActorAlias[0].DisablePathToCenter(disabling)
		ActorAlias[1].DisablePathToCenter(disabling)
		ActorAlias[2].DisablePathToCenter(disabling)
		ActorAlias[3].DisablePathToCenter(disabling)
		ActorAlias[4].DisablePathToCenter(disabling)
	endIf
EndFunction

Function ForcePathToCenter(Actor ActorRef = none, bool forced = true)
	if ActorRef && Positions.Find(ActorRef) != -1
		ActorAlias(ActorRef).ForcePathToCenter(forced)
	else
		ActorAlias[0].ForcePathToCenter(forced)
		ActorAlias[1].ForcePathToCenter(forced)
		ActorAlias[2].ForcePathToCenter(forced)
		ActorAlias[3].ForcePathToCenter(forced)
		ActorAlias[4].ForcePathToCenter(forced)
	endIf
EndFunction

Function SetStartAnimationEvent(Actor ActorRef, string EventName = "IdleForceDefaultState", float PlayTime = 0.1)
	ActorAlias(ActorRef).SetStartAnimationEvent(EventName, PlayTime)
EndFunction

Function SetEndAnimationEvent(Actor ActorRef, string EventName = "IdleForceDefaultState")
	ActorAlias(ActorRef).SetEndAnimationEvent(EventName)
EndFunction

; Orgasms
Function DisableAllOrgasms(bool OrgasmsDisabled = true)
	DisableOrgasms = OrgasmsDisabled
EndFunction

Function DisableOrgasm(Actor ActorRef, bool OrgasmDisabled = true)
	if ActorRef
		ActorAlias(ActorRef).DisableOrgasm(OrgasmDisabled)
	endIf
EndFunction

bool Function IsOrgasmAllowed(Actor ActorRef)
	return ActorAlias(ActorRef).IsOrgasmAllowed()
EndFunction

bool Function NeedsOrgasm(Actor ActorRef)
	return ActorAlias(ActorRef).NeedsOrgasm()
EndFunction

Function ForceOrgasm(Actor ActorRef)
	if ActorRef
		ActorAlias(ActorRef).DoOrgasm(true)
	endIf
EndFunction

; Voice
Function SetVoice(Actor ActorRef, sslBaseVoice Voice, bool ForceSilent = false)
	ActorAlias(ActorRef).SetVoice(Voice, ForceSilent)
EndFunction

sslBaseVoice Function GetVoice(Actor ActorRef)
	return ActorAlias(ActorRef).GetVoice()
EndFunction

; Actor Strapons
bool Function IsUsingStrapon(Actor ActorRef)
	return ActorAlias(ActorRef).IsUsingStrapon()
EndFunction

Function EquipStrapon(Actor ActorRef)
	ActorAlias(ActorRef).EquipStrapon()
EndFunction

Function UnequipStrapon(Actor ActorRef)
	ActorAlias(ActorRef).UnequipStrapon()
EndFunction

Function SetStrapon(Actor ActorRef, Form ToStrapon)
	ActorAlias(ActorRef).SetStrapon(ToStrapon)
endfunction

Form Function GetStrapon(Actor ActorRef)
	return ActorAlias(ActorRef).GetStrapon()
endfunction

; Expressions
Function SetExpression(Actor ActorRef, sslBaseExpression Expression)
	ActorAlias(ActorRef).SetExpression(Expression)
EndFunction
sslBaseExpression Function GetExpression(Actor ActorRef)
	return ActorAlias(ActorRef).GetExpression()
EndFunction

; Enjoyment/Pain
int Function GetEnjoyment(Actor ActorRef)
	return ActorAlias(ActorRef).GetEnjoyment()
EndFunction
int Function GetPain(Actor ActorRef)
	return ActorAlias(ActorRef).GetPain()
EndFunction

; Actor Information
int Function GetPlayerPosition()
	return Positions.Find(PlayerRef)
EndFunction

int Function GetPosition(Actor ActorRef)
	return Positions.Find(ActorRef)
EndFunction

bool Function IsPlayerActor(Actor ActorRef)
	return ActorRef == PlayerRef
EndFunction

bool Function IsPlayerPosition(int Position)
	return Position == Positions.Find(PlayerRef)
EndFunction

bool Function HasActor(Actor ActorRef)
	return ActorRef && Positions.Find(ActorRef) != -1
EndFunction

bool Function PregnancyRisk(Actor ActorRef, bool AllowFemaleCum = false, bool AllowCreatureCum = false)
	return ActorRef && HasActor(ActorRef) && ActorCount > 1 && ActorAlias(ActorRef).PregnancyRisk() \
		&& (Males > 0 || (AllowFemaleCum && Females > 1 && Config.AllowFFCum) || (AllowCreatureCum && MaleCreatures > 0))
EndFunction

; Aggressive/Victim Setup
Function SetVictim(Actor ActorRef, bool Victimize = true)
	ActorAlias(ActorRef).SetVictim(Victimize)
EndFunction

bool Function IsVictim(Actor ActorRef)
	return HasActor(ActorRef) && Victims && Victims.Find(ActorRef) != -1
EndFunction

bool Function IsAggressor(Actor ActorRef)
	return HasActor(ActorRef) && Victims && Victims.Find(ActorRef) == -1
EndFunction

int Function GetHighestPresentRelationshipRank(Actor ActorRef)
	if ActorCount == 1
		return SexLabUtil.IntIfElse(ActorRef == Positions[0], 0, ActorRef.GetRelationshipRank(Positions[0]))
	endIf
	int out = -4 ; lowest possible
	int i = ActorCount
	while i > 0 && out < 4
		i -= 1
		if Positions[i] != ActorRef
			int rank = ActorRef.GetRelationshipRank(Positions[i])
			if rank > out
				out = rank
			endIf
		endIf
	endWhile
	return out
EndFunction

int Function GetLowestPresentRelationshipRank(Actor ActorRef)
	if ActorCount == 1
		return SexLabUtil.IntIfElse(ActorRef == Positions[0], 0, ActorRef.GetRelationshipRank(Positions[0]))
	endIf
	int out = 4 ; highest possible
	int i = ActorCount
	while i > 0 && out > -4
		i -= 1
		if Positions[i] != ActorRef
			int rank = ActorRef.GetRelationshipRank(Positions[i])
			if rank < out
				out = rank
			endIf
		endIf
	endWhile
	return out
EndFunction

Function ChangeActors(Actor[] NewPositions)
	NewPositions = PapyrusUtil.RemoveActor(NewPositions, none)
	if NewPositions.Length < 1 || NewPositions.Length > 5 || GetState() == "Ending" || GetState() == "Frozen" ; || Positions == NewPositions
		return
	endIf
	int[] NewGenders = ActorLib.GenderCount(NewPositions)
	if PapyrusUtil.AddIntValues(NewGenders) == 0 ; || HasCreature || NewGenders[2] > 0
		return
	endIf
	int NewCreatures = NewGenders[2] + NewGenders[3]
	; Enter making state for alterations
	UnregisterforUpdate()
	GoToState("Frozen")
	SendThreadEvent("ActorChangeStart")
	
	; Remove actors no longer present
	int i = ActorCount
	while i > 0
		i -= 1
		sslActorAlias Slot = ActorAlias(Positions[i])
		if Slot
			if NewPositions.Find(Positions[i]) == -1
				if Slot.GetState() == "Prepare" || Slot.GetState() == "Animating"
					Slot.ResetActor()
				else
					Slot.ClearAlias()
				endIf
			else
				Slot.StopAnimating(true)
				Slot.UnlockActor()
			endIf
			UnregisterforUpdate()
		endIf
	endWhile
	int aid = -1
	; Select new animations for changed actor count
	if CustomAnimations && CustomAnimations.Length > 0
		if CustomAnimations[0].PositionCount != NewPositions.Length
			Log("ChangeActors("+NewPositions+") -- Failed to force valid animation for the actors and now is trying to revert the changes if possible", "ERROR")
			NewPositions = Positions
			NewGenders = ActorLib.GenderCount(NewPositions)
			NewCreatures = NewGenders[2] + NewGenders[3]
		else
			Actor[] OldPositions = Positions
			int[] OldGenders = Genders
			if Positions != NewPositions ; Temporaly changin the values to help FilterAnimations()
				Positions  = NewPositions
				Genders    = NewGenders
			endIf
			if Positions != OldPositions ; Temporaly changin the values to help FilterAnimations()
				Positions  = OldPositions
				Genders    = OldGenders
			endIf
			aid = Utility.RandomInt(0, (CustomAnimations.Length - 1))
			Animation = CustomAnimations[aid]
			if NewCreatures > 0
				NewPositions = ThreadLib.SortCreatures(NewPositions) ; required even if is already on the SetAnimation fuction but just the general one
		;	else ; not longer needed since is already on the SetAnimation fuction
		;		NewPositions = ThreadLib.SortActorsByAnimation(NewPositions, Animation)
			endIf
		endIf
	elseIf !PrimaryAnimations || PrimaryAnimations.Length < 1 || PrimaryAnimations[0].PositionCount != NewPositions.Length
		if PrimaryAnimations.Length > 0
			PrimaryAnimations[0].PositionCount
		endIf
		if NewCreatures > 0
			SetAnimations(CreatureSlots.GetByCreatureActors(NewPositions.Length, NewPositions))
		else
			SetAnimations(AnimSlots.GetByDefault(NewGenders[0], NewGenders[1], IsAggressive, (BedRef != none), Config.RestrictAggressive))
		endIf
		if !PrimaryAnimations || PrimaryAnimations.Length < 1
			Log("ChangeActors("+NewPositions+") -- Failed to find valid animation for the actors", "FATAL")
			Stage   = Animation.StageCount
			FastEnd = true
			if HasPlayer
				MiscUtil.SetFreeCameraState(false)
				if Game.GetCameraState() == 0
					Game.ForceThirdPerson()
				endIf
			endIf
			Utility.WaitMenuMode(0.5)
			GoToState("Ending")
			return
		elseIf PrimaryAnimations[0].PositionCount != NewPositions.Length
			Log("ChangeActors("+NewPositions+") -- Failed to find valid animation for the actors and now is trying to revert the changes if possible", "ERROR")
			NewPositions = Positions
			NewGenders = ActorLib.GenderCount(NewPositions)
			NewCreatures = NewGenders[2] + NewGenders[3]
		else
			Actor[] OldPositions = Positions
			int[] OldGenders = Genders
			if Positions != NewPositions ; Temporaly changin the values to help FilterAnimations()
				Positions  = NewPositions
				Genders    = NewGenders
			endIf
			if FilterAnimations() < 0
				Log("ChangeActors("+NewPositions+") -- Failed to filter the animations for the actors", "ERROR")
				if Positions != OldPositions
					Positions  = OldPositions
					Genders    = OldGenders
					if FilterAnimations() < 0
						Log("ChangeActors("+NewPositions+") -- Failed to revert the changes", "FATAL")
						Stage   = Animation.StageCount
						FastEnd = true
						if HasPlayer
							MiscUtil.SetFreeCameraState(false)
							if Game.GetCameraState() == 0
								Game.ForceThirdPerson()
							endIf
						endIf
						Utility.WaitMenuMode(0.5)
						GoToState("Ending")
						return
					else
						NewPositions  = OldPositions
						NewGenders    = OldGenders
					endIf
				endIf
			endIf
			if Positions != OldPositions ; Temporaly changin the values to help FilterAnimations()
				Positions  = OldPositions
				Genders    = OldGenders
			endIf
			aid = Utility.RandomInt(0, (PrimaryAnimations.Length - 1))
			Animation = PrimaryAnimations[aid]
			if NewCreatures > 0
				NewPositions = ThreadLib.SortCreatures(NewPositions) ; required even if is already on the SetAnimation fuction but just the general one
		;	else ; not longer needed since is already on the SetAnimation fuction
		;		NewPositions = ThreadLib.SortActorsByAnimation(NewPositions, Animation)
			endIf
		endIf
	endIf
	; Prepare actors who weren't present before
	i = NewPositions.Length
	while i > 0
		i -= 1
		int SlotID = FindSlot(NewPositions[i])
		if SlotID == -1
			if ActorLib.ValidateActor(NewPositions[i]) < 0
				Log("ChangeActors("+NewPositions+") -- Failed to add new actor '"+NewPositions[i].GetLeveledActorBase().GetName()+"' -- The actor is not valid", "ERROR")
				NewPositions = PapyrusUtil.RemoveActor(NewPositions, NewPositions[i])
				int g      = ActorLib.GetGender(NewPositions[i])
				NewGenders[g] = NewGenders[g] - 1
			else
				; Slot into alias
				sslActorAlias Slot = PickAlias(NewPositions[i])
				if !Slot || !Slot.SetActor(NewPositions[i])
					Log("ChangeActors("+NewPositions+") -- Failed to add new actor '"+NewPositions[i].GetLeveledActorBase().GetName()+"' -- They were unable to fill an actor alias", "ERROR")
					NewPositions = PapyrusUtil.RemoveActor(NewPositions, NewPositions[i])
					int g      = Slot.GetGender()
					NewGenders[g] = NewGenders[g] - 1
				else
					; Update position info
					Positions  = PapyrusUtil.PushActor(Positions, NewPositions[i])
					; Update gender counts
					int g      = Slot.GetGender()
					Genders[g] = Genders[g] + 1
					; Flag as victim
					Slot.SetVictim(False)
					Slot.DoUndress = false
					Slot.PrepareActor()
					UnregisterforUpdate()
				;	Slot.StartAnimating()
				endIf
			endIf
		else
			sslActorAlias Slot = ActorAlias[SlotID]
			if Slot
				Slot.LockActor()
			endIf
		endIf
	endWhile
	; Save new positions information
	Positions  = NewPositions
	; Double Checking the Positions for actors without Slots
	i = NewPositions.Length
	while i > 0
		i -= 1
		if FindSlot(NewPositions[i]) == -1
			Positions = PapyrusUtil.RemoveActor(Positions, NewPositions[i])
			Log("ChangeActors("+NewPositions+") -- Failed to add new actor '"+NewPositions[i].GetLeveledActorBase().GetName()+"' -- They were unable to fill an actor alias", "WARNING")
		endIf
	endWhile
	
	Genders    = NewGenders
	UpdateAdjustKey()
	Log(AdjustKey, "Adjustment Profile")
	; Reset the animation for changed actor count
	GoToState("Animating")
	if aid >= 0
		; End lead in if thread was in it and can't be now
		if LeadIn && Positions.Length != 2
			UnregisterForUpdate()
			Stage  = 1
			LeadIn = false
			QuickEvent("Strip")
			StorageUtil.SetFloatValue(Config,"SexLab.LastLeadInEnd", SexLabUtil.GetCurrentGameRealTime())
			SendThreadEvent("LeadInEnd")
			SetAnimation(aid)
		;	Action("Advancing")
		else
			Stage  = 1
			SetAnimation(aid)
		;	Action("Advancing")
		endIf
	else
		; Reposition actors
		RealignActors()
	endIf
;	RegisterForSingleUpdate(0.1)
	SendThreadEvent("ActorChangeEnd")
EndFunction

; ------------------------------------------------------- ;
; --- Animation Setup                                 --- ;
; ------------------------------------------------------- ;

Function SetForcedAnimations(sslBaseAnimation[] AnimationList)
	if AnimationList && AnimationList.Length > 0
		CustomAnimations = AnimationList
	endIf
EndFunction

sslBaseAnimation[] Function GetForcedAnimations()
	sslBaseAnimation[] Output = sslUtility.AnimationArray(CustomAnimations.Length)
	int i = CustomAnimations.Length
	while i > 0
		i -= 1
		Output[i] = CustomAnimations[i]
	endWhile
	return Output
EndFunction

Function ClearForcedAnimations()
	CustomAnimations = sslUtility.AnimationArray(0)
EndFunction

Function SetAnimations(sslBaseAnimation[] AnimationList)
	if AnimationList && AnimationList.Length > 0
		PrimaryAnimations = AnimationList
	endIf
EndFunction

sslBaseAnimation[] Function GetAnimations()
	sslBaseAnimation[] Output = sslUtility.AnimationArray(PrimaryAnimations.Length)
	int i = PrimaryAnimations.Length
	while i > 0
		i -= 1
		Output[i] = PrimaryAnimations[i]
	endWhile
	return Output
EndFunction

Function ClearAnimations()
	PrimaryAnimations = sslUtility.AnimationArray(0)
EndFunction

Function SetLeadAnimations(sslBaseAnimation[] AnimationList)
	if AnimationList && AnimationList.Length > 0
		LeadIn = true
		LeadAnimations = AnimationList
	endIf
EndFunction

sslBaseAnimation[] Function GetLeadAnimations()
	sslBaseAnimation[] Output = sslUtility.AnimationArray(LeadAnimations.Length)
	int i = LeadAnimations.Length
	while i > 0
		i -= 1
		Output[i] = LeadAnimations[i]
	endWhile
	return Output
EndFunction

Function ClearLeadAnimations()
	LeadAnimations = sslUtility.AnimationArray(0)
EndFunction

Function AddAnimation(sslBaseAnimation AddAnimation, bool ForceTo = false)
	if AddAnimation
		sslBaseAnimation[] Adding = new sslBaseAnimation[1]
		Adding[0] = AddAnimation
		PrimaryAnimations = sslUtility.MergeAnimationLists(PrimaryAnimations, Adding)
	endIf
EndFunction

Function SetStartingAnimation(sslBaseAnimation FirstAnimation)
	StartingAnimation = FirstAnimation
EndFunction

; ------------------------------------------------------- ;
; --- Thread Settings                                 --- ;
; ------------------------------------------------------- ;

Function DisableLeadIn(bool disabling = true)
	LeadIn = !disabling
EndFunction

Function DisableBedUse(bool disabling = true)
	BedStatus[0] = 0 - (disabling as int)
EndFunction

Function SetBedFlag(int flag = 0)
	BedStatus[0] = flag
EndFunction

Function SetFurnitureIgnored(bool disabling = true)
	If(!BedRef)
		return
	EndIf
	BedRef.SetDestroyed(disabling)
	;	CenterRef.ClearDestruction()
	BedRef.BlockActivation(disabling)
	BedRef.SetNoFavorAllowed(disabling)
EndFunction

Function SetTimers(float[] SetTimers)
	if !SetTimers || SetTimers.Length < 1
		Log("SetTimers() - Empty timers given.", "ERROR")
	else
		CustomTimers    = SetTimers
		UseCustomTimers = true
	endIf
EndFunction

float Function GetStageTimer(int maxstage)
	int last = ( Timers.Length - 1 )
	if stage == maxstage
		return Timers[last]
	elseIf stage < last
		return Timers[(stage - 1)]
	endIf
	return Timers[(last - 1)]
endfunction

int Function AreUsingFurniture(Actor[] ActorList)
	if !ActorList || ActorList.Length < 1
		return -1
	endIf
	
	int i = ActorList.Length
	ObjectReference TempFurnitureRef
	while i > 0
		i -= 1
		TempFurnitureRef = ActorList[i].GetFurnitureReference()
		if TempFurnitureRef && TempFurnitureRef != none
			int FurnitureType = ThreadLib.GetBedType(TempFurnitureRef)
			if FurnitureType > 0
				return FurnitureType
			endIf
		endIf
	endWhile
	return -1
EndFunction

Function CenterOnObject(ObjectReference CenterOn, bool resync = true)
	If(!CenterOn)
		return
	EndIf
	_Center = CenterOn.PlaceAtMe(Config.BaseMarker)
	CenterAlias.ForceRefTo(CenterOn)
	; Check if center is one of our actors and lock them in place if so
	int Pos = Positions.Find(CenterOn as Actor)
	If(Pos >= 0)
		int SlotID = FindSlot(Positions[Pos])
		If(SlotID != -1)
			ActorAlias[SlotID].LockActor()
		EndIf
		If(CenterOn == VictimRef as ObjectReference)
			Log("CenterRef == VictimRef: " + VictimRef)
		ElseIf CenterOn == PlayerRef as ObjectReference
			Log("CenterRef == PlayerRef: " + PlayerRef)
		Else
			Log("CenterRef == Positions[" + Pos + "]: " + CenterRef)
		EndIf
	EndIf
	CenterLocation[0] = CenterOn.GetPositionX()
	CenterLocation[1] = CenterOn.GetPositionY()
	CenterLocation[2] = CenterOn.GetPositionZ()
	CenterLocation[3] = CenterOn.GetAngleX()
	CenterLocation[4] = CenterOn.GetAngleY()
	CenterLocation[5] = CenterOn.GetAngleZ()
	If(sslpp.IsBed(CenterOn))
		BedStatus[1] = ThreadLib.GetBedType(CenterOn)
		BedRef = CenterOn
		SetFurnitureIgnored(true)
		float offsetX
		float offsetY
		float offsetZ
		float offsAnZ
		If(BedStatus[1] == 1)
			offsetZ = 7.5 ; Average Z offset for bedrolls
			offsAnZ = 180 ; bedrolls are usually rotated 180° on Z
		Else
			int offset = -31 ; + ((_Positions_var.find(playerref) > -1) as int) * 36
			offsetX = Math.Cos(sslUtility.TrigAngleZ(CenterLocation[5])) * offset
			offsetY = Math.Sin(sslUtility.TrigAngleZ(CenterLocation[5])) * offset
			offsetZ = 45 ; Z offset for beds
		EndIf
		float scale = CenterOn.GetScale()
		If(scale != 1.0)
			offsetX *= scale
			offsetY *= scale
			If(CenterLocation[2] < 0)
				offsetZ *= (2 - scale) ; Assming Scale will always be in [0; 2)
			Else
				offsetZ *= scale
			EndIf
		EndIf
		CenterLocation[0] = CenterLocation[0] + offsetX
		CenterLocation[1] = CenterLocation[1] + offsetY
		CenterLocation[2] = CenterLocation[2] + offsetZ
		CenterLocation[5] = CenterLocation[5] - offsAnZ
		CenterRef.SetPosition(CenterLocation[0], CenterLocation[1], CenterLocation[2])
		CenterRef.SetAngle(CenterLocation[3], CenterLocation[4], CenterLocation[5])
	Else
		BedStatus[1] = 0
		BedRef = none
	EndIf
	Log("Creating new Center Ref from = " + CenterOn + " at Coordinates = " + CenterLocation + "( New Center is Bed Type = " + BedStatus[1] + " )")
EndFunction

; COMEBACK: This here should be completely pointless but might wanna check that it doesnt break anythin just to be sure
Function CenterOnCoords(float LocX = 0.0, float LocY = 0.0, float LocZ = 0.0, float RotX = 0.0, float RotY = 0.0, float RotZ = 0.0, bool resync = true)
	CenterLocation[0] = LocX
	CenterLocation[1] = LocY
	CenterLocation[2] = LocZ
	CenterLocation[3] = RotX
	CenterLocation[4] = RotY
	CenterLocation[5] = RotZ
EndFunction

bool Function CenterOnBed(bool AskPlayer = true, float Radius = 750.0)
	If(BedStatus[0] == -1)
		return false
	EndIf
	bool InStart = GetState() == "Making"
	int AskBed = Config.AskBed
	if InStart && (!HasPlayer && Config.NPCBed == 0) || (HasPlayer && AskBed == 0)
		return false ; Beds forbidden by flag or starting bed check/prompt disabled
	endIf
	bool BedScene = BedStatus[0] == 1
 	ObjectReference FoundBed
	int i = 0
	While (i < Positions.Length)
		FoundBed = Positions[i].GetFurnitureReference()
		; This returns 0 if FoundBed isnt a Bed
		int BedType = ThreadLib.GetBedType(FoundBed)
		if BedType > 0 && (ActorCount < 4 || BedType != 2)
			CenterOnObject(FoundBed)
			return true ; Bed found and approved for use
		endIf
		i += 1
	EndWhile
	; Double radius if bedscene is forced (BedStatus[0] == 1)
	Radius *= 1 + BedStatus[0]
	if HasPlayer && (!InStart || AskBed == 1 || (AskBed == 2 && (!IsVictim(PlayerRef) || UseNPCBed)))
		FoundBed = sslpp.GetNearestUnusedBed(PlayerRef, Radius)
		AskPlayer = AskPlayer && (!InStart || !(AskBed == 2 && IsVictim(PlayerRef))) ; Disable prompt if bed found but shouldn't ask
	elseIf !HasPlayer && UseNPCBed
		FoundBed = sslpp.GetNearestUnusedBed(PlayerRef, Radius)
	endIf
	; Found a bed AND EITHER forced use OR don't care about players choice OR or player approved
	if FoundBed && (BedStatus[0] == 1 || (!AskPlayer || (AskPlayer && (Config.UseBed.Show() as bool))))
		CenterOnObject(FoundBed)
		return true ; Bed found and approved for use
	endIf
	return false ; No bed found
EndFunction

; ------------------------------------------------------- ;
; --- Event Hooks                                     --- ;
; ------------------------------------------------------- ;

Function SetHook(string AddHooks)
	string[] Setting = PapyrusUtil.StringSplit(AddHooks)
	int i = Setting.Length
	while i
		i -= 1
		if Setting[i] != "" && Hooks.Find(Setting[i]) == -1
			AddTag(Setting[i])
			Hooks = PapyrusUtil.PushString(Hooks, Setting[i])
		endIf
	endWhile
EndFunction

string Function GetHook()
	return Hooks[0] ; v1.35 Legacy support, pre multiple hooks
EndFunction

string[] Function GetHooks()
	return Hooks
EndFunction

Function RemoveHook(string DelHooks)
	string[] Removing = PapyrusUtil.StringSplit(DelHooks)
	string[] NewHooks
	int i = Hooks.Length
	while i
		i -= 1
		if Removing.Find(Hooks[i]) != -1
			RemoveTag(Hooks[i])
		else
			NewHooks = PapyrusUtil.PushString(NewHooks, Hooks[i])
		endIf
	endWhile
	Hooks = NewHooks
EndFunction

; ------------------------------------------------------- ;
; --- Tagging System                                  --- ;
; ------------------------------------------------------- ;

bool Function HasTag(string Tag)
	return Tags.Find(Tag) != -1
EndFunction

bool Function AddTag(string Tag)
	if Tag != "" && Tags.Find(Tag) == -1
		Tags = PapyrusUtil.PushString(Tags, Tag)
		return true
	endIf
	return false
EndFunction

bool Function AddTags(String[] asTags)
	Tags = sslpp.MergeStringArrayEx(Tags, asTags, true)
EndFunction

bool Function RemoveTag(string Tag)
	if Tag != "" && Tags.Find(Tag) != -1
		Tags = PapyrusUtil.RemoveString(Tags, Tag)
		return true
	endIf
	return false
EndFunction

bool Function ToggleTag(string Tag)
	return (RemoveTag(Tag) || AddTag(Tag)) && HasTag(Tag)
EndFunction

bool Function AddTagConditional(string Tag, bool AddTag)
	if AddTag
		return AddTag(Tag)
	else
		return RemoveTag(Tag)
	endIf
EndFunction

; Because PapyrusUtil don't Remove Dupes from the Array
string[] Function AddString(string[] ArrayValues, string ToAdd, bool RemoveDupes = true)
	if ToAdd != ""
		string[] Output = ArrayValues
		if !RemoveDupes || Output.length < 1
			return PapyrusUtil.PushString(Output, ToAdd)
		elseIf Output.Find(ToAdd) == -1
			int i = Output.Find("")
			if i != -1
				Output[i] = ToAdd
			else
				Output = PapyrusUtil.PushString(Output, ToAdd)
			endIf
		endIf
		return Output
	endIf
	return ArrayValues
EndFunction

string[] Function GetTags()
	return PapyrusUtil.ClearEmpty(Tags)
EndFunction

; ------------------------------------------------------- ;
; --- Actor Alias                                     --- ;
; ------------------------------------------------------- ;

int Function FindSlot(Actor ActorRef)
	if !ActorRef
		return -1
	endIf
	int i
	while i < 5
		if ActorAlias[i].ActorRef == ActorRef
			return i
		endIf
		i += 1
	endWhile
	return -1
EndFunction

sslActorAlias Function ActorAlias(Actor ActorRef)
	int SlotID = FindSlot(ActorRef)
	if SlotID != -1
		return ActorAlias[SlotID]
	endIf
	return none
EndFunction

sslActorAlias Function PositionAlias(int Position)
	if Position < 0 || !(Position < Positions.Length)
		return none
	endIf
	return ActorAlias[FindSlot(Positions[Position])]
EndFunction

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

Function ProgressAnimationImpl()
	If(Stage < 1)
		Stage = 1
	ElseIf(Stage > Animation.StageCount)
		If(LeadIn)
			EndLeadInImpl()
		Else
			GoToState("Ending")
		EndIf
		return
	EndIf
	int i = 0
	While(i < Positions.Length)
		ActorAlias[i].SyncThread()
		i += 1
	EndWhile

	SendThreadEvent("StageStart")
	HookStageStart()

	; TODO: Rewrite this as part of this function, playing all necessary Animations n stuff
	Action("Animating")
EndFunction

; End leadin -> Start default animation
Function EndLeadInImpl()
	Stage  = 1
	LeadIn = false
	SetAnimation()
	; Add runtime to foreplay skill xp
	SkillXP[0] = SkillXP[0] + (TotalTime / 10.0)
	; Restrip with new strip options
	QuickEvent("Strip")
	; Start primary animations at stage 1
	StorageUtil.SetFloatValue(Config, "SexLab.LastLeadInEnd", SexLabUtil.GetCurrentGameRealTime())
	SendThreadEvent("LeadInEnd")
	ProgressAnimationImpl()
EndFunction

Function SendThreadEvent(string HookEvent)
	Log(HookEvent, "Event Hook")
	SetupThreadEvent(HookEvent)
	int i = Hooks.Length
	while i
		i -= 1
		SetupThreadEvent(HookEvent+"_"+Hooks[i])
	endWhile
	; Legacy support for < v1.50 - To be removed eventually
	if HasPlayer
		SendModEvent("Player"+HookEvent, thread_id)
	endIf
EndFunction

Function SetupThreadEvent(string HookEvent)
	int eid = ModEvent.Create("Hook"+HookEvent)
	if eid
		ModEvent.PushInt(eid, thread_id)
		ModEvent.PushBool(eid, HasPlayer)
		ModEvent.Send(eid)
		; Log("Thread Hook Sent: "+HookEvent)
	endIf
	SendModEvent(HookEvent, thread_id)
EndFunction

sslThreadHook[] ThreadHooks
Function HookAnimationStarting()
	; Log("HookAnimationStarting() - "+ThreadHooks)
	int i = Config.GetThreadHookCount()
	while i > 0
		i -= 1
		if ThreadHooks[i] && ThreadHooks[i].CanRunHook(Positions, Tags) && ThreadHooks[i].AnimationStarting(self)
			Log("Global Hook AnimationStarting("+self+") - "+ThreadHooks[i])
		; else
		; 	Log("HookAnimationStarting() - Skipping["+i+"]: "+ThreadHooks[i])
		endIf
	endWhile
EndFunction

Function HookAnimationPrepare()
	; Log("HookAnimationPrepare() - "+ThreadHooks)
	int i = Config.GetThreadHookCount()
	while i > 0
		i -= 1
		if ThreadHooks[i] && ThreadHooks[i].CanRunHook(Positions, Tags) && ThreadHooks[i].AnimationPrepare(self as sslThreadController)
			Log("Global Hook AnimationPrepare("+self+") - "+ThreadHooks[i])
		; else
		; 	Log("HookAnimationPrepare() - Skipping["+i+"]: "+ThreadHooks[i])
		endIf
	endWhile
EndFunction

Function HookStageStart()
	int i = Config.GetThreadHookCount()
	while i > 0
		i -= 1
		if ThreadHooks[i] && ThreadHooks[i].CanRunHook(Positions, Tags) && ThreadHooks[i].StageStart(self as sslThreadController)
			Log("Global Hook StageStart("+self+") - "+ThreadHooks[i])
		; else
		; 	Log("HookStageStart() - Skipping["+i+"]: "+ThreadHooks[i])
		endIf
	endWhile
EndFunction

Function HookStageEnd()
	int i = Config.GetThreadHookCount()
	while i > 0
		i -= 1
		if ThreadHooks[i] && ThreadHooks[i].CanRunHook(Positions, Tags) && ThreadHooks[i].StageEnd(self as sslThreadController)
			Log("Global Hook StageEnd("+self+") - "+ThreadHooks[i])
		; else
		; 	Log("HookStageEnd() - Skipping["+i+"]: "+ThreadHooks[i])
		endIf
	endWhile
EndFunction

Function HookAnimationEnding()
	int i = Config.GetThreadHookCount()
	while i > 0
		i -= 1
		if ThreadHooks[i] && ThreadHooks[i].CanRunHook(Positions, Tags) && ThreadHooks[i].AnimationEnding(self as sslThreadController)
			Log("Global Hook AnimationEnding("+self+") - "+ThreadHooks[i])
		; else
		; 	Log("HookAnimationEnding() - Skipping["+i+"]: "+ThreadHooks[i])
		endIf
	endWhile
EndFunction

Function HookAnimationEnd()
	int i = Config.GetThreadHookCount()
	while i > 0
		i -= 1
		if ThreadHooks[i] && ThreadHooks[i].CanRunHook(Positions, Tags) && ThreadHooks[i].AnimationEnd(self as sslThreadController)
			Log("Global Hook AnimationEnd("+self+") - "+ThreadHooks[i])
		; else
		; 	Log("HookAnimationEnd() - Skipping["+i+"]: "+ThreadHooks[i])
		endIf
	endWhile
EndFunction


; ------------------------------------------------------- ;
; --- Alias Events - SYSTEM USE ONLY                  --- ;
; ------------------------------------------------------- ;

string[] EventTypes
float[] AliasTimer
int[] AliasDone
float SyncTimer
int SyncDone

int Property kPrepareActor = 0 autoreadonly hidden
int Property kSyncActor    = 1 autoreadonly hidden
int Property kResetActor   = 2 autoreadonly hidden
int Property kRefreshActor = 3 autoreadonly hidden
int Property kStartup      = 4 autoreadonly hidden

string Function Key(string Callback)
	return "SSL_"+thread_id+"_"+Callback
EndFunction

Function QuickEvent(string Callback)
	ModEvent.Send(ModEvent.Create(Key(Callback)))
endfunction

Function SyncEvent(int id, float WaitTime)
	if AliasTimer[id] <= 0 || AliasTimer[id] < Utility.GetCurrentRealTime()
		AliasDone[id]  = 0
		AliasTimer[id] = Utility.GetCurrentRealTime() + WaitTime
		RegisterForSingleUpdate(WaitTime)
 		ModEvent.Send(ModEvent.Create(Key(EventTypes[id])))
	else
		Log(EventTypes[id]+" sync Event attempting to start during previous wait sync")
		RegisterForSingleUpdate(WaitTime * 0.25)
	endIf
EndFunction

bool SyncLock
Function SyncEventDone(int id)
	while SyncLock
		Log("SyncLock("+id+")")
		Utility.WaitMenuMode(0.01)
	endWhile
	SyncLock = true
	float TimeNow = Utility.GetCurrentRealTime()
	if AliasTimer[id] > 0.0 && AliasDone[id] < ActorCount ; || AliasTimer[id] < TimeNow
		AliasDone[id] = AliasDone[id] + 1
		if AliasDone[id] >= ActorCount
			UnregisterforUpdate()
			if DebugMode
				Log("Lag Timer: " + (AliasTimer[id] - TimeNow), "SyncDone("+EventTypes[id]+")")
			endIf
			AliasDone[id]  = 0
			AliasTimer[id] = 0.0
			if id >= kSyncActor && id <= kRefreshActor
				RemoveFade()
			endIf
			ModEvent.Send(ModEvent.Create(Key(EventTypes[id]+"Done")))
		endIf
	else
		Log("WARNING: SyncEventDone("+id+") OUT OF TURN")
	endIf
	SyncLock = false
EndFunction

Function SendTrackedEvent(Actor ActorRef, string Hook = "")
	; Append hook type, global if empty
	if Hook != ""
		Hook = "_"+Hook
	endIf
	; Send generic player callback Event
	if ActorRef == PlayerRef
		SetupActorEvent(PlayerRef, "PlayerTrack"+Hook)
	endIf
	; Send actor callback events
	int i = StorageUtil.StringListCount(ActorRef, "SexLabEvents")
	while i
		i -= 1
		SetupActorEvent(ActorRef, StorageUtil.StringListGet(ActorRef, "SexLabEvents", i)+Hook)
	endWhile
	; Send faction callback events
	i = StorageUtil.FormListCount(Config, "TrackedFactions")
	while i
		i -= 1
		Faction FactionRef = StorageUtil.FormListGet(Config, "TrackedFactions", i) as Faction
		if FactionRef && ActorRef.IsInFaction(FactionRef)
			int n = StorageUtil.StringListCount(FactionRef, "SexLabEvents")
			while n
				n -= 1
				SetupActorEvent(ActorRef, StorageUtil.StringListGet(FactionRef, "SexLabEvents", n)+Hook)
			endwhile
		endIf
	endWhile
EndFunction

Function SetupActorEvent(Actor ActorRef, string Callback)
	int eid = ModEvent.Create(Callback)
	ModEvent.PushForm(eid, ActorRef)
	ModEvent.PushInt(eid, thread_id)
	ModEvent.Send(eid)
EndFunction

; ------------------------------------------------------- ;
; --- Thread Setup - SYSTEM USE ONLY                  --- ;
; ------------------------------------------------------- ;

Function Log(string msg, string src = "")
	msg = "Thread["+thread_id+"] "+src+" - "+msg
	Debug.Trace("SEXLAB - " + msg)
	If(DebugMode)
		SexLabUtil.PrintConsole(msg)
		Debug.TraceUser("SexLabDebug", msg)
	EndIf
EndFunction

Function ReportAndFail(string msg, string src = "", bool halt = true)
	msg = "FATAL - Thread["+thread_id+"] "+src+" - "+msg
	Debug.TraceStack("SEXLAB - " + msg)
	SexLabUtil.PrintConsole(msg)
	If(DebugMode)
		Debug.TraceUser("SexLabDebug", msg)
	EndIf
	Initialize()
EndFunction

Function UpdateAdjustKey()
	if !Config.RaceAdjustments && Config.ScaleActors
		AdjustKey = "Global"
	else
		int i
		string NewKey
		while i < ActorCount
			NewKey += PositionAlias(i).GetActorKey()
			i += 1
			if i < ActorCount
				NewKey += "."
			endIf
		endWhile
		AdjustKey = NewKey
	endIf
EndFunction

sslActorAlias Function PickAlias(Actor ActorRef)
	int i
	while i < 5
		if ActorAlias[i].ForceRefIfEmpty(ActorRef)
			return ActorAlias[i]
		endIf
		i += 1
	endWhile
	return none
EndFunction

Function ResolveTimers()
	if !UseCustomTimers
		if LeadIn
			ConfigTimers = Config.StageTimerLeadIn
		elseIf IsAggressive
			ConfigTimers = Config.StageTimerAggr
		else
			ConfigTimers = Config.StageTimer
		endIf
	endIf
EndFunction

Function SetTID(int id)
	thread_id = id
	PlayerRef = Game.GetPlayer()
	DebugMode = Config.DebugMode

	Log(self, "Setup")
	; Reset Function Libraries - SexLabQuestFramework
	if !Config || !ThreadLib || !ActorLib
		Form SexLabQuestFramework = Game.GetFormFromFile(0xD62, "SexLab.esm")
		if SexLabQuestFramework
			Config    = SexLabQuestFramework as sslSystemConfig
			ThreadLib = SexLabQuestFramework as sslThreadLibrary
			ActorLib  = SexLabQuestFramework as sslActorLibrary
		endIf
	endIf
	; Reset secondary object registry - SexLabQuestRegistry
	if !CreatureSlots
		Form SexLabQuestRegistry = Game.GetFormFromFile(0x664FB, "SexLab.esm")
		if SexLabQuestRegistry
			CreatureSlots = SexLabQuestRegistry as sslCreatureAnimationSlots
		endIf
	endIf
	; Reset animation registry - SexLabQuestAnimations
	if !AnimSlots
		Form SexLabQuestAnimations = Game.GetFormFromFile(0x639DF, "SexLab.esm")
		if SexLabQuestAnimations
			AnimSlots = SexLabQuestAnimations as sslAnimationSlots
		endIf
	endIf

	
	; Init thread info
	EventTypes = new string[5]
	EventTypes[0] = "Prepare"
	EventTypes[1] = "Sync"
	EventTypes[2] = "Reset"
	EventTypes[3] = "Refresh"
	EventTypes[4] = "Startup"

	CenterAlias = GetNthAlias(5) as ReferenceAlias

	ActorAlias = new sslActorAlias[5]
	ActorAlias[0] = GetNthAlias(0) as sslActorAlias
	ActorAlias[1] = GetNthAlias(1) as sslActorAlias
	ActorAlias[2] = GetNthAlias(2) as sslActorAlias
	ActorAlias[3] = GetNthAlias(3) as sslActorAlias
	ActorAlias[4] = GetNthAlias(4) as sslActorAlias

	ActorAlias[0].Setup()
	ActorAlias[1].Setup()
	ActorAlias[2].Setup()
	ActorAlias[3].Setup()
	ActorAlias[4].Setup()
	
	InitShares()
	Initialize()
EndFunction

Function InitShares()
	DebugMode      = Config.DebugMode
	AnimEvents     = new string[5]
	IsType         = new bool[9]
	BedStatus      = new int[2]
	AliasDone      = new int[6]
	RealTime       = new float[1]
	AliasTimer     = new float[6]
	SkillXP        = new float[6]
	SkillBonus     = new float[6]
	CenterLocation = new float[6]
	if EventTypes.Length != 5 || EventTypes.Find("") != -1
		EventTypes = new string[5]
		EventTypes[0] = "Prepare"
		EventTypes[1] = "Sync"
		EventTypes[2] = "Reset"
		EventTypes[3] = "Refresh"
		EventTypes[4] = "Startup"
	endIf
	if !CenterAlias
		CenterAlias = GetAliasByName("CenterAlias") as ReferenceAlias
	endIf
EndFunction

bool Initialized
Function Initialize()
	UnregisterForUpdate()
	; Clear aliases
	ActorAlias[0].ClearAlias()
	ActorAlias[1].ClearAlias()
	ActorAlias[2].ClearAlias()
	ActorAlias[3].ClearAlias()
	ActorAlias[4].ClearAlias()
	if CenterAlias
	;	SetObjectiveDisplayed(0, False)
		CenterAlias.Clear()
	endIf
	; Forms
	Animation      = none
	CenterRef      = none
	SoundFX        = none
	BedRef         = none
	StartingAnimation = none
	; Boolean
	AutoAdvance    = true
	LeadIn         = false
	FastEnd        = false
	UseCustomTimers= false
	DisableOrgasms = false
	; Floats
	SyncTimer      = 0.0
	StartedAt      = 0.0
	; Integers
	SyncDone       = 0
	Stage          = 1
	; StartAID       = -1
	; Storage Data
	Genders           = new int[4]
	Victims           = PapyrusUtil.ActorArray(0)
	Positions         = PapyrusUtil.ActorArray(0)
	CustomAnimations  = sslUtility.AnimationArray(0)
	PrimaryAnimations = sslUtility.AnimationArray(0)
	LeadAnimations    = sslUtility.AnimationArray(0)
	Hooks             = Utility.CreateStringArray(0)
	Tags              = Utility.CreateStringArray(0)
	CustomTimers      = Utility.CreateFloatArray(0)
	; Enter thread selection pool
	GoToState("Unlocked")
	Initialized = true
EndFunction

; ------------------------------------------------------- ;
; --- State Restricted                                --- ;
; ------------------------------------------------------- ;

State Unlocked
	sslThreadModel Function Make()
		InitShares()
		if !Initialized
			Initialize()
		endIf
		Initialized = false
		GoToState("Making")
		return self
	EndFunction
EndState

; Making
sslThreadModel Function Make()
	Log("Cannot enter make on a locked thread", "Make() ERROR")
	return none
EndFunction
sslThreadController Function StartThread()
	Log("Cannot start thread while not in a Making State", "StartThread() ERROR")
	return none
EndFunction
int Function AddActor(Actor ActorRef, bool IsVictim = false, sslBaseVoice Voice = none, bool ForceSilent = false)
	Log("Cannot add an actor to a locked thread", "AddActor() ERROR")
	return -1
EndFunction
bool Function AddActors(Actor[] ActorList, Actor VictimActor = none)
	Log("Cannot add a list of actors to a locked thread", "AddActors() ERROR")
	return false
EndFunction
; State varied
Function FireAction()
EndFunction
Function EndAction()
EndFunction
Function SyncDone()
EndFunction
Function RefreshDone()
EndFunction
Function PrepareDone()
EndFunction
Function ResetDone()
EndFunction
Function StripDone()
EndFunction
Function OrgasmDone()
EndFunction
Function StartupDone()
EndFunction
Function SetAnimation(int aid = -1)
EndFunction
bool Function SetAnimationsByTags(String asTags, int aiUseBed)
EndFunction
; Animating
Event OnKeyDown(int keyCode)
EndEvent
Function EnableHotkeys(bool forced = false)
EndFunction
Function RealignActors()
EndFunction
; TEMPORARY
Function SetTimeThings()
EndFunction

sslBaseAnimation[] Function ValidateAnimations(sslBaseAnimation[] akAnimations)
	If(!akAnimations.Length)
		return akAnimations
	EndIf
	; Bit clunky but w/e do we do if Papyrus doesnt let us allocate arrays with dynamic size
	int[] valids = Utility.CreateIntArray(akAnimations.Length, -1)
	int[] pkeys = GetAllPositionKeys()
	int n = 0
	While(n < akAnimations.Length)
		If(akAnimations[i] && akAnimations[i].MatchKeys(pkeys) && akAnimations[i].MatchTags(Tags))
			valids[n] = n
		EndIf
		n += 1
	EndWhile
	valids = PapyrusUtil.RemoveInt(valids, -1)
	If(valids.Length == akAnimations.Length)
		return akAnimations
	EndIf
	sslBaseAnimation[] ret = sslUtility.AnimationArray(valids.Length)
	int i = 0
	While(i < ret.Length)
		ret[i] = akAnimations[valids[i]]
	EndWhile
	return ret
EndFunction

Function AddCommonTags(sslBaseAnimation[] akAnimations)
	String[] commons = akAnimations[0].GetTags()
	int i = 1
	While(i < akAnimations.Length)
		String[] animtags = akAnimations[i].GetTags()
		int k = commons.Length
		While(k > 0)
			k -= 1
			If(animtags.Find(commons[k]))
				commons = sslpp.RemoveStringEx(commons, commons[k])
				If(!commons.Length)
					return
				EndIf
			EndIf
		EndWhile
		i += 1
	EndWhile
	AddTags(commons)
EndFunction

Function PlaceActors()
	float w = 0.0
	int i = 0
	While(i < Positions.Length)
		; Lock Actor in place & get them ready to animate
		float ww = ActorAlias[i].PlaceActor()
		If(ww > w)
			w = ww
		EndIf
		Positions[i].SetVehicle(_Center)
		; Apply Scale after SetVehicle cuz SetVehicle norms ActorScale
		ActorAlias[i].ApplyScale()
		Debug.SendAnimationEvent(Positions[i], "sosfasterect")
		i += 1
	EndWhile
	; If placing includes an animation, wait for longest to finish
	If(w > 0)
		Utility.Wait(w)
	EndIf
	sslpp.SetPositions(Positions, _Center)
EndFunction

Function UnplaceActors()
	int i = 0
	While(i < Positions.Length)
		Positions[i].SetVehicle(none)
		ActorAlias[i].UnlockActor()
		ActorAlias[i].SendDefaultAnimEvent()
		i += 1
	EndWhile
EndFunction

Function LogRedundant(String asFunction)
	Debug.MessageBox("[SEXLAB]\nState '" + GetState() + "'; Function '" + asFunction + "' is an internal function made redundant.\nNo mod should ever be calling this. If you see this, the mod starting this scene integrates into SexLab in undesired ways.")
EndFunction

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

bool Function HasPlayer()
	return HasPlayer
EndFunction
Actor Function GetPlayer()
	return PlayerRef
EndFunction
Actor Function GetVictim()
	return VictimRef
EndFunction
float Function GetTime()
	return StartedAt
endfunction
Function SetBedding(int flag = 0)
	SetBedFlag(flag)
EndFunction

; Unnecessary, just use OnBeginState()/OnEndState()
Function Action(string FireState)
	UnregisterForUpdate()
	EndAction()
	GoToState(FireState)
	FireAction()
endfunction

Function RemoveFade()
	if HasPlayer
		Config.RemoveFade()
	endIf
EndFunction

Function ApplyFade()
	if HasPlayer
		Config.ApplyFade()
	endIf
EndFunction

bool Function CheckTags(string[] CheckTags, bool RequireAll = true, bool Suppress = false)
	int i = CheckTags.Length
	while i
		i -= 1
		if CheckTags[i] != ""
			bool Check = Tags.Find(CheckTags[i]) != -1
			if (Suppress && Check) || (!Suppress && RequireAll && !Check)
				return false ; Stop if we need all and don't have it, or are supressing the found tag
			elseIf !Suppress && !RequireAll && Check
				return true ; Stop if we don't need all and have one
			endIf
		endIf
	endWhile
	; If still here than we require all and had all
	return true
EndFunction

int Function FilterAnimations()
	; Filter animations based on user settings and scene
	if !CustomAnimations || CustomAnimations.Length < 1
		Log("FilterAnimations() BEGIN - LeadAnimations="+LeadAnimations.Length+", PrimaryAnimations="+PrimaryAnimations.Length)
		string[] Filters
		string[] BasicFilters
		string[] BedFilters
		sslBaseAnimation[] FilteredPrimary
		sslBaseAnimation[] FilteredLead
		int[] Futas = ActorLib.TransCount(Positions)
		int i

		; Filter tags for Male Vaginal restrictions
		if (Futas[0] + Futas[1]) < 1 && ((!Config.UseCreatureGender && ActorCount == Males) || (Config.UseCreatureGender && ActorCount == (Males + MaleCreatures)))
			BasicFilters = AddString(BasicFilters, "Vaginal")
		elseIf (HasTag("Vaginal") || HasTag("Pussy") || HasTag("Cunnilingus"))
			if FemaleCreatures <= 0
				Filters = AddString(Filters, "CreatureSub")
			endIf
		endIf

		if IsAggressive && Config.FixVictimPos
			if VictimRef == Positions[0] && ActorLib.GetGender(VictimRef) == 0 && ActorLib.GetTrans(VictimRef) == -1
				BasicFilters = AddString(BasicFilters, "Vaginal")
			endIf
			if Males > 0 && ActorLib.GetGender(VictimRef) == 1 && ActorLib.GetTrans(VictimRef) == -1
				Filters = AddString(Filters, "FemDom")
			elseIf Creatures > 0 && !ActorLib.IsCreature(VictimRef) && Males <= 0 && (!Config.UseCreatureGender || (Males + MaleCreatures) <= 0)
				Filters = AddString(Filters, "CreatureSub")
			endIf
		endIf
		
		; Filter tags for same sex restrictions
		if ActorCount == 2 && Creatures == 0 && (Males == 0 || Females == 0) && Config.RestrictSameSex
			BasicFilters = AddString(BasicFilters, SexLabUtil.StringIfElse(Females == 2, "FM", "Breast"))
		endIf
		if Config.UseStrapons && Config.RestrictStrapons && (ActorCount - Creatures) == Females && Females > 0
			Filters = AddString(Filters, "Straight")
			Filters = AddString(Filters, "Gay")
		endIf
		if BasicFilters.Find("Breast") >= 0
			Filters = AddString(Filters, "Boobjob")
		endIf

		;Remove filtered basic tags from primary
		FilteredPrimary = sslUtility.FilterTaggedAnimations(PrimaryAnimations, BasicFilters, false)
		if PrimaryAnimations.Length > FilteredPrimary.Length
			Log("Filtered out '"+(PrimaryAnimations.Length - FilteredPrimary.Length)+"' primary animations with tags: "+BasicFilters)
			PrimaryAnimations = FilteredPrimary
		endIf

		; Filter tags for non-bed friendly animations
		if BedRef
			BedFilters = AddString(BedFilters, "Furniture")
			BedFilters = AddString(BedFilters, "NoBed")
			if Config.BedRemoveStanding
				BedFilters = AddString(BedFilters, "Standing")
			endIf
			if UsingBedRoll
				BedFilters = AddString(BedFilters, "BedOnly")
			elseIf UsingSingleBed
				BedFilters = AddString(BedFilters, "DoubleBed") ; For bed animations made specific for DoubleBed or requiring too mush space to use single beds
			elseIf UsingDoubleBed
				BedFilters = AddString(BedFilters, "SingleBed") ; For bed animations made specific for SingleBed
			endIf
		else
			BedFilters = AddString(BedFilters, "BedOnly")
		endIf

		; Remove any animations with filtered tags
		Filters = PapyrusUtil.RemoveString(Filters, "")
		BasicFilters = PapyrusUtil.RemoveString(BasicFilters, "")
		BedFilters = PapyrusUtil.RemoveString(BedFilters, "")
		
		; Get default creature animations if none
		if HasCreature
			if Config.UseCreatureGender
				if ActorCount != Creatures 
					PrimaryAnimations = CreatureSlots.FilterCreatureGenders(PrimaryAnimations, Genders[2], Genders[3])
				else
					;TODO: Find bether solution instead of Exclude CC animations from filter  
				endIf
			endIf
			; Pick default creature animations if currently empty (none or failed above check)
			if PrimaryAnimations.Length == 0 ; || (BasicFilters.Length > 1 && PrimaryAnimations[0].CheckTags(BasicFilters, False))
				Log("Selecting new creature animations - "+PrimaryAnimations)
				Log("Creature Genders: "+Genders)
				SetAnimations(CreatureSlots.GetByCreatureActorsTags(ActorCount, Positions, "", PapyrusUtil.StringJoin(BasicFilters, ",")))
				if PrimaryAnimations.Length == 0
					SetAnimations(CreatureSlots.GetByCreatureActors(ActorCount, Positions))
					if PrimaryAnimations.Length == 0
						ReportAndFail("Failed to find valid creature animations.")
						return -1
					endIf
				endIf
			endIf
			; Sort the actors to creature order
		;	Positions = ThreadLib.SortCreatures(Positions, Animations[0]) ; not longer needed since is already on the SetAnimation fuction

		; Get default primary animations if none
		elseIf PrimaryAnimations.Length == 0 ; || (BasicFilters.Length > 1 && PrimaryAnimations[0].CheckTags(BasicFilters, False))
			SetAnimations(AnimSlots.GetByDefaultTags(Males, Females, IsAggressive, (BedRef != none), Config.RestrictAggressive, "", PapyrusUtil.StringJoin(BasicFilters, ",")))
			if PrimaryAnimations.Length == 0
				SetAnimations(AnimSlots.GetByDefault(Males, Females, IsAggressive, (BedRef != none), Config.RestrictAggressive))
				if PrimaryAnimations.Length == 0
					ReportAndFail("Unable to find valid default animations")
					return -1
				endIf
			endIf
		endIf

		; Remove any animations without filtered gender tags
		if Config.RestrictGenderTag
			string DefGenderTag = ""
			i = ActorCount
			int[] GendersAll = ActorLib.GetGendersAll(Positions)
			int[] FutasAll = ActorLib.GetTransAll(Positions)
			while i ;Make Position Gender Tag
				i -= 1
				if GendersAll[i] == 0
					DefGenderTag = "M" + DefGenderTag
				elseIf GendersAll[i] == 1
					DefGenderTag = "F" + DefGenderTag
				elseIf GendersAll[i] >= 2
					DefGenderTag = "C" + DefGenderTag
				endIf
			endWhile
			if DefGenderTag != ""
				string[] GenderTag = Utility.CreateStringArray(1, DefGenderTag)
				;Filtering Futa animations
				if (Futas[0] + Futas[1]) < 1
					BasicFilters = AddString(BasicFilters, "Futa")
				elseIf (Futas[0] + Futas[1]) != (Genders[0] + Genders[1])
					Filters = AddString(Filters, "AllFuta")
				endIf
				;Make Extra Position Gender Tag if actor is Futanari or female use strapon
				i = ActorCount
				while i
					i -= 1
					if (Config.UseStrapons && GendersAll[i] == 1) || (FutasAll[i] == 1)
						if StringUtil.GetNthChar(DefGenderTag, ActorCount - i) == "F"
							GenderTag = AddString(GenderTag, StringUtil.Substring(DefGenderTag, 0, ActorCount - i) + "M" + StringUtil.Substring(DefGenderTag, (ActorCount - i) + 1))
						endIf
					elseIf (FutasAll[i] == 0)
						if StringUtil.GetNthChar(DefGenderTag, ActorCount - i) == "M"
							GenderTag = AddString(GenderTag, StringUtil.Substring(DefGenderTag, 0, ActorCount - i) + "F" + StringUtil.Substring(DefGenderTag, (ActorCount - i) + 1))
						endIf
					endIf
				endWhile
				if Config.UseStrapons
					DefGenderTag = ActorLib.GetGenderTag(0, Males + Females, Creatures)
					GenderTag = AddString(GenderTag, DefGenderTag)
				endIf
				DefGenderTag = ActorLib.GetGenderTag(Females, Males, Creatures)
				GenderTag = AddString(GenderTag, DefGenderTag)
				
				DefGenderTag = ActorLib.GetGenderTag(Females + Futas[0] - Futas[1], Males - Futas[0] + Futas[1], Creatures)
				GenderTag = AddString(GenderTag, DefGenderTag)
				; Remove filtered gender tags from primary
				FilteredPrimary = sslUtility.FilterTaggedAnimations(PrimaryAnimations, GenderTag, true)
				if FilteredPrimary.Length > 0 && PrimaryAnimations.Length > FilteredPrimary.Length
					Log("Filtered out '"+(PrimaryAnimations.Length - FilteredPrimary.Length)+"' primary animations without tags: "+GenderTag)
					PrimaryAnimations = FilteredPrimary
				endIf
				; Remove filtered gender tags from lead in
				if LeadAnimations && LeadAnimations.Length > 0
					FilteredLead = sslUtility.FilterTaggedAnimations(LeadAnimations, GenderTag, true)
					if LeadAnimations.Length > FilteredLead.Length
						Log("Filtered out '"+(LeadAnimations.Length - FilteredLead.Length)+"' lead in animations without tags: "+GenderTag)
						LeadAnimations = FilteredLead
					endIf
				endIf
			endIf
		endIf
		
		; Remove filtered tags from primary step by step
		FilteredPrimary = sslUtility.FilterTaggedAnimations(PrimaryAnimations, BedFilters, false)
		if FilteredPrimary.Length > 0 && PrimaryAnimations.Length > FilteredPrimary.Length
			Log("Filtered out '"+(PrimaryAnimations.Length - FilteredPrimary.Length)+"' primary animations with tags: "+BedFilters)
			PrimaryAnimations = FilteredPrimary
		endIf
		FilteredPrimary = sslUtility.FilterTaggedAnimations(PrimaryAnimations, BasicFilters, false)
		if FilteredPrimary.Length > 0 && PrimaryAnimations.Length > FilteredPrimary.Length
			Log("Filtered out '"+(PrimaryAnimations.Length - FilteredPrimary.Length)+"' primary animations with tags: "+BasicFilters)
			PrimaryAnimations = FilteredPrimary
		endIf
		FilteredPrimary = sslUtility.FilterTaggedAnimations(PrimaryAnimations, Filters, false)
		if FilteredPrimary.Length > 0 && PrimaryAnimations.Length > FilteredPrimary.Length
			Log("Filtered out '"+(PrimaryAnimations.Length - FilteredPrimary.Length)+"' primary animations with tags: "+Filters)
			PrimaryAnimations = FilteredPrimary
		endIf
		; Remove filtered tags from lead in
		if LeadAnimations && LeadAnimations.Length > 0
			Filters = PapyrusUtil.MergeStringArray(Filters, BasicFilters, true)
			Filters = PapyrusUtil.MergeStringArray(Filters, BedFilters, true)
			FilteredLead = sslUtility.FilterTaggedAnimations(LeadAnimations, Filters, false)
			if LeadAnimations.Length > FilteredLead.Length
				Log("Filtered out '"+(LeadAnimations.Length - FilteredLead.Length)+"' lead in animations with tags: "+Filters)
				LeadAnimations = FilteredLead
			endIf
		endIf
		; Remove Dupes
		if LeadAnimations && PrimaryAnimations && PrimaryAnimations.Length > LeadAnimations.Length
			PrimaryAnimations = sslUtility.RemoveDupesFromList(PrimaryAnimations, LeadAnimations)
		endIf
		; Make sure we are still good to start after all the filters
		if !LeadAnimations || LeadAnimations.Length < 1
			LeadIn = false
		endIf
		if !PrimaryAnimations || PrimaryAnimations.Length < 1
			ReportAndFail("Empty primary animations after filters")
			return -1
		endIf
		Log("FilterAnimations() END - LeadAnimations="+LeadAnimations.Length+", PrimaryAnimations="+PrimaryAnimations.Length)
		return 1
	endIf
	return 0
EndFunction

state Advancing
	Event OnBeginState()
		ProgressAnimationImpl()
	EndEvent
	Function SyncDone()
		LogRedundant("SyncDone")
	EndFunction
	event OnUpdate()
		LogRedundant("OnUpdate")
	endEvent
endState
