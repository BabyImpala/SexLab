scriptname sslActorStats extends sslSystemLibrary
{
	Internal Scripts for Statistics access and manipulation
}

; TODO: RecordThread() is still functional
; TODO: Statistics Script is still used throughout the framework and should be updated to the new API
; TODO: The new API needs some kinda documentation
; TODO: SexLabFramework.psc still uses the old API to great extend
; !IMPORTANT When implementing the Cpp side, ensure the Sexuality is properly fittet to the old system
; NOTE: The old system uses...
; 				- Homo 		[0; 35]
;					-	Bi 			[36; 65]
;					- Hetero	[66; 100]
; !IMPORTANT Implementation AddEncounter() funcs should shift the new partner to end of array to signify they were most recently involved with the actor
;									-- Doing this with a timestamp
; COMEBACK: To reduce CoSave usage, might want to cut down on total stored partners for any non-player
; IDEA: Should the above also exclude followers?
; COMEBACK: Some translations are in this script, should prolly move them to MCM?
; NOTE: Some of these are no longer used, as related to purity/lewdness
; !IMPORTANT Delete NPC from the list if they are deleted/reset/dead
; TODO: Decide if the old skill functions should stay around and if they should be Papyrus or C++
; TODO: Some legacy funcs might still be relevant after converting the remaining frame to the new API

String Function ParseTime(int time) global
	If time < 0
		return "--:--:--"
	Endif
	return ZeroFill((time / 3600) as int) + ":" + ZeroFill(((time / 60) % 60) as int) + ":" + ZeroFill(time % 60 as int)
EndFunction

String Function ZeroFill(string num) global
	If StringUtil.GetLength(num) == 1
		return "0" + num
	EndIf
	return num
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

; --- Default Statistics
int Property LastUpdate_GameTime  = 0   AutoReadOnly
int Property SecondsInScene       = 1   AutoReadOnly
int Property XP_Anal              = 2   AutoReadOnly
int Property XP_Vaginal           = 3   AutoReadOnly
int Property XP_Oral              = 4   AutoReadOnly
int Property PartnersMale         = 5   AutoReadOnly
int Property PartnersFemale       = 6   AutoReadOnly
int Property PartnersFuta         = 7   AutoReadOnly
int Property PartnersCreature     = 8   AutoReadOnly
int Property TimesOral            = 9   AutoReadOnly
int Property TimesVaginal         = 10  AutoReadOnly
int Property TimesAnal            = 11  AutoReadOnly
int Property TimesMasturbated     = 12  AutoReadOnly
int Property TimesSubmissive      = 13  AutoReadOnly
int Property TimesDominant        = 14  AutoReadOnly
int Property TimesTotal           = 15  AutoReadOnly
int Property SadoMasochismus      = 16  AutoReadOnly
int Property Sexuality            = 17  AutoReadOnly
int Property Arousal              = 18  AutoReadOnly

; Returns an array of FormIDs of all currently tracked actors
int[] Function GetAllTrackedActors() native global
Function SetStatistic(Actor akActor, int id, int aiValue) native global
int Function GetStatistic(Actor akActor, int id) native global

; --- Custom Statistics
String[] Function GetAllCustomStatIDs(Actor akActor) native global
bool Function HasCustomStat(Actor akActor, String asStat) native global
Function SetCustomStatFlt(Actor akActor, String asStat, float afValue) native global
Function SetCustomStatStr(Actor akActor, String asStat, String asValue) native global
float Function GetCustomStatFlt(Actor akActor, String asStat, float afDefault = 0.0) native global
String Function GetCustomStatStr(Actor akActor, String asStat, String asDefault = "") native global
Function DeleteCustomStat(Actor akActor, String asStat) native global
Function DeleteAllCustomStats(Actor akActor) native global

; --- Encounter Statistics
int Property ENC_Neutral 	= 0	AutoReadOnly Hidden
int Property ENC_Victim		= 1	AutoReadOnly Hidden
int Property ENC_Assault	= 2	AutoReadOnly Hidden

; Return a list of all encounters with this actor, sorted and beginning with the least recent one
Actor[] Function GetAllEncounters(Actor akActor) native global
; Return an array of all actors that this actor assaulted
Actor[] Function GetAllEncounteredVictims(Actor akActor) native global
Actor[] Function GetAllEncounteredAssailants(Actor akActor) native global
Actor Function GetMostRecentEncounter(Actor akActor) native global
Function AddEncounter(Actor akActor, Actor akPartner, int aiEncounterType) native global
float Function GetLastEncounterTime(Actor akActor, Actor akPartner) native global
int Function GetTimesMet(Actor akActor, Actor akPartner) native global
int Function GetTimesVictimzed(Actor akActor, Actor akAssailant) native global
int Function GetTimesAssaulted(Actor akActor, Actor akVictim) native global
; Returns an array [total, victim, assaults, fst] containing meeting data between the two actors
; fst returns the index of the actor from which view the data is collected (E.g. fst = 0 => victim represents how often akActor has been victim to akPartner)
int[] Function GetEncounterTypesCount(Actor akActor, Actor akPartner) native global


; Deletes all statistics for this actor, default, custom and encounter related
Function ResetStatistics(Actor akActor) native global


; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* ;
; ----------------------------------------------------------------------------- ;
;               ██╗     ███████╗ ██████╗  █████╗  ██████╗██╗   ██╗              ;
;               ██║     ██╔════╝██╔════╝ ██╔══██╗██╔════╝╚██╗ ██╔╝              ;
;               ██║     █████╗  ██║  ███╗███████║██║      ╚████╔╝               ;
;               ██║     ██╔══╝  ██║   ██║██╔══██║██║       ╚██╔╝                ;
;               ███████╗███████╗╚██████╔╝██║  ██║╚██████╗   ██║                 ;
;               ╚══════╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝   ╚═╝                 ;
; ----------------------------------------------------------------------------- ;
; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* ;

; This function makes no sense anymore as custom stat order is no longer fixed
String[] Function GetEveryStatisticID() native global
; Uses old SkillNames[] ids and returns a result based on them 
int Function GetLegacyStatistic(Actor akActor, int id) native global
float[] Function GetAllLegycSkills(Actor akActor) native global
; Sets a statistic based on the value. May fail silently if the statistic is no longer supported
Function SetLegacyStatistic(Actor akActor, int id, int afValue) native global

; Titles
String[] Function StatTitles()
	String[] StatTitles = new String[7]
	StatTitles[0] = "$SSL_Unskilled"
	StatTitles[1] = "$SSL_Novice"
	StatTitles[2] = "$SSL_Apprentice"
	StatTitles[3] = "$SSL_Journeyman"
	StatTitles[4] = "$SSL_Expert"
	StatTitles[5] = "$SSL_Master"
	StatTitles[6] = "$SSL_GrandMaster"
	return StatTitles
EndFunction

String[] Function SkillNames()
	String[] SkillNames = new String[21]
	SkillNames[0] =  "Foreplay"
	SkillNames[1] =  "Vaginal"
	SkillNames[2] =  "Anal"
	SkillNames[3] =  "Oral"
	SkillNames[4] =  "Pure"
	SkillNames[5] =  "Lewd"
	SkillNames[6] =  "Males"
	SkillNames[7] =  "Females"
	SkillNames[8] =  "Creatures"
	SkillNames[9] =  "Masturbation"
	SkillNames[10] = "Aggressor"
	SkillNames[11] = "Victim"
	SkillNames[12] = "SexCount"
	SkillNames[13] = "PlayerSex"
	SkillNames[14] = "Sexuality"
	SkillNames[15] = "TimeSpent"
	SkillNames[16] = "LastSex.RealTime"
	SkillNames[17] = "LastSex.GameTime"
	SkillNames[18] = "VaginalCount"
	SkillNames[19] = "AnalCount"
	SkillNames[20] = "OralCount"
	return SkillNames
EndFunction

; ------------------------------------------------------- ;
; --- Manipulate Custom Stats                         --- ;
; ------------------------------------------------------- ;

int function FindStat(string Stat)
	return GetEveryStatisticID().Find(Stat)
endFunction
int function GetNumStats()
	return GetEveryStatisticID().Length
endFunction
string function GetNthStat(int i)
	return GetEveryStatisticID()[i]
endFunction

int function RegisterStat(string Stat, string Value, string Prepend = "", string Append = "")
	If (FindStat(Stat) == -1)
		SetCustomStatStr(PlayerRef, Stat, Value)
		SetCustomStatStr(PlayerRef, "Custom.Default." + Stat, Value)
		If (Prepend)
			SetCustomStatStr(PlayerRef, "Custom.Prepend." + Stat, Value)
		EndIf
		If (Append)
			SetCustomStatStr(PlayerRef, "Custom.Append." + Stat, Value)		
		EndIf
	EndIf
	return FindStat(Stat)
endFunction

function Alter(string Name, string NewName = "", string Value = "", string Prepend = "", string Append = "")
	If (FindStat(Name) == -1)
		return
	EndIf
	If (NewName != "")
		String v = GetCustomStatStr(PlayerRef, Name)
		String d = GetCustomStatStr(PlayerRef, "Custom.Default." + Name)
		String p = GetCustomStatStr(PlayerRef, "Custom.Prepend." + Name)
		String a = GetCustomStatStr(PlayerRef, "Custom.Append." + Name)
		DeleteCustomStat(PlayerRef, Name)
		SetCustomStatStr(PlayerRef, NewName, v)
		SetCustomStatStr(PlayerRef, "Custom.Default." + NewName, d)
		SetCustomStatStr(PlayerRef, "Custom.Prepend." + NewName, p)
		SetCustomStatStr(PlayerRef, "Custom.Append." + NewName, a)
		Name = NewName
	EndIf
	if Value != ""
		SetCustomStatStr(PlayerRef, "Custom.Default." + Name, Value)
	endIf
	if Prepend != ""
		SetCustomStatStr(PlayerRef, "Custom.Prepend." + Name, Prepend)
	endIf
	if Append != ""
		SetCustomStatStr(PlayerRef, "Custom.Append." + Name, Append)
	endIf
endFunction

bool function ClearStat(Actor ActorRef, string Stat)
	if HasStat(ActorRef, Stat)
		DeleteCustomStat(ActorRef, Stat)
		return true
	endIf
	return false
endFunction

function SetStat(Actor ActorRef, string Stat, string Value)
	SetCustomStatStr(ActorRef, Stat, Value)
endFunction
float function FloatAdjustBy(Actor ActorRef, string Stat, float Adjust)
	if !HasStat(ActorRef, Stat)
		return 0
	endIf
	float Value = GetStatFloat(ActorRef, Stat)
	Value += Adjust
	SetStat(ActorRef, Stat, (Value as string))
	return Value
endFunction
int function AdjustBy(Actor ActorRef, string Stat, int Adjust)
	if !HasStat(ActorRef, Stat)
		return 0
	endIf
	int Value = GetStatInt(ActorRef, Stat)
	Value += Adjust
	SetStat(ActorRef, Stat, (Value as string))
	return Value
endFunction

bool function HasStat(Actor ActorRef, string Stat)
	return HasCustomStat(ActorRef, Stat)
endFunction

string function GetStat(Actor ActorRef, string Stat)
	if !HasStat(ActorRef, Stat)
		return GetStatDefault(Stat)
	endIf
	return GetCustomStatStr(ActorRef, Stat)
endFunction
string function GetStatString(Actor ActorRef, string Stat)
	return GetStat(ActorRef, Stat)
endFunction
float function GetStatFloat(Actor ActorRef, string Stat)
	return GetStat(ActorRef, Stat) as float
endFunction
int function GetStatInt(Actor ActorRef, string Stat)
	return GetStat(ActorRef, Stat) as int
endFunction

string function GetStatDefault(string Stat)
	return GetCustomStatStr(PlayerRef, "Custom.Default." + Stat)
endFunction
string function GetStatPrepend(string Stat)
	return GetCustomStatStr(PlayerRef, "Custom.Prepend." + Stat)
endFunction
string function GetStatAppend(string Stat)
	return GetCustomStatStr(PlayerRef, "Custom.Append." + Stat)
endFunction
string function GetStatFull(Actor ActorRef, string Stat)
	return GetStatPrepend(Stat) + GetStat(ActorRef, Stat) + GetStatAppend(Stat)
endFunction

int function GetStatLevel(Actor ActorRef, string Stat, float Curve = 0.85)
	return CalcLevel(GetStatInt(ActorRef, Stat), Curve)
endFunction
string function GetStatTitle(Actor ActorRef, string Stat, float Curve = 0.85)
	return StatTitles()[PapyrusUtil.ClampInt(CalcLevel(GetStatFloat(ActorRef, Stat), Curve), 0, 6)]
endFunction

; ------------------------------------------------------- ;
; --- Calculators & Parsers                           --- ;
; ------------------------------------------------------- ;

int function CalcSexuality(bool IsFemale, int Males, int Females)
	; Calculate "sexuality ratio" 0 = full homosexual, 100 = full heterosexual
	if IsFemale
		return (((Males + 1.0) / ((Males + Females + 1) as float)) * 100.0) as int
	else
		return (((Females + 1.0) / ((Males + Females + 1) as float)) * 100.0) as int
	endIf
endFunction

float function CalcLevelFloat(float Total, float Curve = 0.85)
	if Total > 0.0
		return Math.Sqrt((Math.Abs(Total) / 2.0) * Curve)
	endIf
	return 0.0
endFunction

int function CalcLevel(float Total, float Curve = 0.85)
	return CalcLevelFloat(Total, Curve) as int
endFunction

; ------------------------------------------------------- ;
; --- Sex Skills                                      --- ;
; ------------------------------------------------------- ;

bool function IsSkilled(Actor ActorRef) global
	return true
EndFunction

function _SeedActor(Actor ActorRef, float RealTime, float GameTime) global
EndFunction
function SeedActor(Actor ActorRef)
endFunction

float function _GetSkill(Actor ActorRef, int Stat) global
	return GetLegacyStatistic(ActorRef, Stat)
EndFunction
int function GetSkill(Actor ActorRef, string Skill)
	return GetSkillFloat(ActorRef, Skill) as int
endFunction
float function GetSkillFloat(Actor ActorRef, string Skill)
	return _GetSkill(ActorRef, SkillNames().Find(Skill))
endFunction

function _SetSkill(Actor ActorRef, int Stat, float Value) global
	SetLegacyStatistic(ActorRef, Stat, Value as int)
EndFunction
function SetSkill(Actor ActorRef, string Skill, int Amount)
	_SetSkill(ActorRef, SkillNames().Find(Skill), Amount as float)
endFunction
function SetSkillFloat(Actor ActorRef, string Skill, float Amount)
	_SetSkill(ActorRef, SkillNames().Find(Skill), Amount)
endFunction

float function _AdjustSkill(Actor ActorRef, int Stat, float By) global
	float v = _GetSkill(ActorRef, Stat)
	v += By
	_SetSkill(ActorRef, Stat, v)
	return v
EndFunction
function AdjustSkill(Actor ActorRef, string Skill, int Amount)
	_AdjustSkill(ActorRef, SkillNames().Find(Skill), Amount as float)
endfunction
function AdjustSkillFloat(Actor ActorRef, string Skill, float Amount)
	_AdjustSkill(ActorRef, SkillNames().Find(Skill), Amount)
endFunction

int function GetSkillLevel(Actor ActorRef, string Skill, float Curve = 0.85)
	return CalcLevel(GetSkill(ActorRef, Skill), Curve)
endFunction

string function GetSkillTitle(Actor ActorRef, string Skill, float Curve = 0.85)
	return StatTitles()[PapyrusUtil.ClampInt(GetSkillLevel(ActorRef, Skill, Curve), 0, 6)]
endFunction
string function GetTitle(int Level)
	return StatTitles()[PapyrusUtil.ClampInt(Level, 0, 6)]
endFunction

float[] function GetSkills(Actor ActorRef) global
	return GetAllLegycSkills(ActorRef)
EndFunction

float[] function GetSkillLevels(Actor ActorRef)
	float[] Output = new float[6]
	float[] Skills = GetSkills(ActorRef)
	if Skills && Skills.Length >= 6
		Output[0] = CalcLevelFloat(Skills[0], 0.85)
		Output[1] = CalcLevelFloat(Skills[1], 0.85)
		Output[2] = CalcLevelFloat(Skills[2], 0.85)
		Output[3] = CalcLevelFloat(Skills[3], 0.85)
		Output[4] = CalcLevelFloat(Skills[4], 0.30)
		Output[5] = CalcLevelFloat(Skills[5], 0.30)
	endIf
	return Output
endFunction

function AddSkillXP(Actor ActorRef, float Foreplay = 0.0, float Vaginal = 0.0, float Anal = 0.0, float Oral = 0.0)
	_AdjustSkill(ActorRef, kForeplay, Foreplay)
	_AdjustSkill(ActorRef, kVaginal, Vaginal)
	_AdjustSkill(ActorRef, kAnal, Anal)
	_AdjustSkill(ActorRef, kOral, Oral)
endFunction

; ------------------------------------------------------- ;
; --- Purity/Impurty Stat                             --- ;
; ------------------------------------------------------- ;

; NOTE: Purity is no longer supported, SLP+ V2.5

int function GetPure(Actor ActorRef)
	return _GetSkill(ActorRef, kPure) as int
endFunction

int function GetPureLevel(Actor ActorRef)
	return CalcLevel(GetPure(ActorRef), 0.3)
endFunction

string function GetPureTitle(Actor ActorRef)
	String[] titles = new string[7]
	titles[0] = "$SSL_Neutral"
	titles[1] = "$SSL_Unsullied"
	if ActorRef.GetLeveledActorBase().GetSex() == 1	; female
		titles[2] = "$SSL_PrimProper"
		titles[3] = "$SSL_Virtuous"
		titles[4] = "$SSL_EverFaithful"
		titles[5] = "$SSL_Ladylike"
		titles[6] = "$SSL_Saintly"
	else	; male
		titles[2] = "$SSL_CleanCut"
		titles[3] = "$SSL_Virtuous"
		titles[4] = "$SSL_EverFaithful"
		titles[5] = "$SSL_Lordly"
		titles[6] = "$SSL_Saintly"
	endIf
	return titles[PapyrusUtil.ClampInt(GetPureLevel(ActorRef), 0, 6)]
endFunction

int function GetLewd(Actor ActorRef)
	return _GetSkill(ActorRef, kLewd) as int
endFunction

int function GetLewdLevel(Actor ActorRef)
	return CalcLevel(GetLewd(ActorRef), 0.3)
endFunction

string function GetLewdTitle(Actor ActorRef)
	String[] titles = new string[7]
	titles[0] = "$SSL_Neutral"
	titles[1] = "$SSL_Experimenting"
	titles[2] = "$SSL_UnusuallyHorny"
	titles[3] = "$SSL_Promiscuous"
	titles[4] = "$SSL_SexualDeviant"
	if ActorRef.GetLeveledActorBase().GetSex() == 1	; female
		titles[5] = "$SSL_Debaucherous"
		titles[6] = "$SSL_Nymphomaniac"
	else	; male
		titles[5] = "$SSL_Depraved"
		titles[6] = "$SSL_Hypersexual"
	endIf
	return titles[PapyrusUtil.ClampInt(GetLewdLevel(ActorRef), 0, 6)]
endFunction

bool function IsPure(Actor ActorRef)
	return GetPurity(ActorRef) >= 0.0
endFunction

bool function IsLewd(Actor ActorRef)
	return GetPurity(ActorRef) < 0.0
endFunction

float function GetPurity(Actor ActorRef)
	return ((GetPure(ActorRef) - GetLewd(ActorRef)) as float) * 1.5
endFunction

float function AdjustPurity(Actor ActorRef, float Adjust)
	string type = "Pure"
	if Adjust < 0.0
		type = "Lewd"
	endIf
	AdjustSkillFloat(ActorRef, type, Math.Abs(Adjust))
	return GetSkillFloat(ActorRef, type)
endFunction

string function GetPurityTitle(Actor ActorRef)
	if IsLewd(ActorRef)
		return GetLewdTitle(ActorRef)
	else
		return GetPureTitle(ActorRef)
	endIf
endFunction

int function GetPurityLevel(Actor ActorRef)
	return CalcLevel(Math.Abs(GetPurity(ActorRef)), 0.3)
endFunction

function AddPurityXP(Actor ActorRef, float Pure, float Lewd, bool IsAggressive, bool IsVictim, bool WithCreature, int ActorCount, int HadRelation)
	; Aggressive modifier for victim/aggressor
	if IsAggressive && IsVictim
		_AdjustSkill(ActorRef, kVictim, 1)
		Pure -= 1.0
		Lewd += 1.0
	elseIf IsAggressive
		_AdjustSkill(ActorRef, kAggressor, 1)
		Pure -= 2.0
		Lewd += 2.0
	endIf
	; Creature modifier
	if WithCreature
		Pure -= 1.0
		Lewd += 2.0
	endIf
	; Actor count modifier
	if ActorCount == 1
		Lewd += 1.0
	elseIf ActorCount > 2
		Pure -= (ActorCount - 1) * 2.0
		Lewd += (ActorCount - 1) * 2.0
	endIf
	; Relationship modifier
	int HighestRelation = ActorRef.GetHighestRelationshipRank()
	if HighestRelation == 4 && HadRelation == 4
		Pure += 4.0
	elseIf HighestRelation == 4 && !IsVictim
		Pure -= 2.0
		Lewd += 2.0
	endIf
	; Save adjustments
	_AdjustSkill(ActorRef, kPure, Pure)
	_AdjustSkill(ActorRef, kLewd, Lewd)
endFunction

; ------------------------------------------------------- ;
; --- Sex Counters                                    --- ;
; ------------------------------------------------------- ;

function AddSex(Actor ActorRef, float TimeSpent = 0.0, bool WithPlayer = false, bool IsAggressive = false, int Males = 0, int Females = 0, int Creatures = 0)
	_AdjustSkill(ActorRef, kTimeSpent, TimeSpent)
	_SetSkill(ActorRef, kLastGameTime, Utility.GetCurrentGameTime())
	_SetSkill(ActorRef, kLastRealTime, SexLabUtil.GetCurrentGameRealTime())

	int ActorCount = (Males + Females + Creatures)
	if ActorCount > 1
		int Gender = GetGender(ActorRef)
		Males -= (Gender == 0) as int
		Females -= (Gender == 1) as int
		_AdjustSkill(ActorRef, kMales, Males)
		_AdjustSkill(ActorRef, kFemales, Females)
		_AdjustSkill(ActorRef, kCreatures, Creatures)
		_AdjustSkill(ActorRef, kSexCount, 1)
		if ActorRef != PlayerRef
			if !IsAggressive
				AdjustSexuality(ActorRef, Males * 2, Females * 2)
			else
				AdjustSexuality(ActorRef, Males, Females)
			endIf
		endIf
	else
		_AdjustSkill(ActorRef, kMasturbation, 1)
	endIf
	if WithPlayer && ActorRef != PlayerRef
		_AdjustSkill(ActorRef, kPlayerSex, 1)
		AddEncounter(PlayerRef, ActorRef, ENC_Neutral)
	endIf
endFunction

int function SexCount(Actor ActorRef)
	return _GetSkill(ActorRef, kSexCount) as int
endFunction

bool function HadSex(Actor ActorRef)
	return _GetSkill(ActorRef, kSexCount) >= 1.0
endFunction

int function PlayerSexCount(Actor ActorRef)
	return _GetSkill(ActorRef, kPlayerSex) as int
endFunction

bool function HadPlayerSex(Actor ActorRef)
	return _GetSkill(ActorRef, kPlayerSex) >= 1.0
endFunction

Actor function LastSexPartner(Actor ActorRef)
	return GetMostRecentEncounter(ActorRef)
endFunction
bool function HasHadSexTogether(Actor ActorRef1, Actor ActorRef2)
	return GetAllEncounters(ActorRef1).Find(ActorRef2) > -1
endfunction

Actor function LastAggressor(Actor ActorRef)
	Actor[] list = GetAllEncounteredAssailants(ActorRef)
	If (!list.Length)
		return none
	EndIf
	return list[list.Length - 1]
endFunction
bool function WasVictimOf(Actor VictimRef, Actor AggressorRef)
	return GetAllEncounteredAssailants(VictimRef).Find(AggressorRef) > -1
endFunction

Actor function LastVictim(Actor ActorRef)
	Actor[] list = GetAllEncounteredVictims(ActorRef)
	If (!list.Length)
		return none
	EndIf
	return list[list.Length - 1]
endFunction
bool function WasAggressorTo(Actor AggressorRef, Actor VictimRef)
	return GetAllEncounteredVictims(AggressorRef).Find(VictimRef) > -1
endFunction

Form[] function CleanActorList(Actor ActorRef, string List)
	StorageUtil.FormListRemove(ActorRef, List, none, true)
	Form[] ActorList = StorageUtil.FormListToArray(ActorRef, List)
	if ActorList && ActorList.Length > 0
		bool cleaned = false
		int[] Types  = new int[3]
		Types[0] = 43 ; kNPC
		Types[1] = 44 ; kLeveledCharacter
		Types[2] = 62 ; kCharacter
		int i = ActorList.Length
		while i > 0
			i -= 1
			if !ActorList[i] || Types.Find(ActorList[i].GetType()) == -1
				StorageUtil.FormListRemoveAt(ActorRef, List, i)
				cleaned = true
			endIf
		endWhile
		if cleaned
			return StorageUtil.FormListToArray(ActorRef, List)
		endIf
	endIf
	return ActorList
endfunction
Actor function LastActorInList(Actor ActorRef, string List)
	if ActorRef
		Form[] ActorList = CleanActorList(ActorRef, List)
		if ActorList
			return ActorList[(ActorList.Length - 1)] as Actor
		endIf
	endIf
	return none
endFunction

Actor function MostUsedPlayerSexPartner()
	Actor[] list = GetAllEncounters(PlayerRef)
	Actor ret = none
	int max = 0
	int i = 0
	While (i < list.Length)
		int met = GetTimesMet(PlayerRef, list[i])
		If (met > max)
			max = met
			ret = list[i]
		EndIf
		i += 1
	EndWhile
	return ret
endFunction
Actor function MostUsedPlayerSexPartner2()
	return MostUsedPlayerSexPartner()	; Original code was 1:1 the same as above
endFunction
Actor[] function MostUsedPlayerSexPartners(int MaxActors = 5)
	Actor[] act = GetAllEncounters(PlayerRef)
	If (act.Length >= MaxActors)
		return act
	EndIf
	int[] timesmet = Utility.CreateIntArray(act.Length)
	int k = 0
	While (k < act.Length)
		timesmet[k] = GetTimesMet(PlayerRef, act[k])
		k += 1
	EndWhile
	; Sort times met s.t. highest is at [0]
  int i = 1
  While(i < act.Length)
    Actor it = act[i]
    int _it = timesmet[i]
    int n = i - 1
    While(n >= 0 && _it >= timesmet[n])
      act[n + 1] = act[n]
      timesmet[n + 1] = timesmet[n]
      n -= 1
    EndWhile
    act[n + 1] = it
    timesmet[n + 1] = _it
    i += 1
  EndWhile
	Actor[] ret = PapyrusUtil.ActorArray(MaxActors)
	int j = 0
	While (j < ret.Length)
		ret[j] = act[j]
		j += 1
	EndWhile
	return ret
endFunction

; ------------------------------------------------------- ;
; --- Sexuality Stats                                 --- ;
; ------------------------------------------------------- ;

; COMEBACK: These might want an explicit port

function AdjustSexuality(Actor ActorRef, int Males, int Females)
	bool IsFemale = GetGender(ActorRef) == 1
	float Ratio = _GetSkill(ActorRef, kSexuality)
	if Ratio == 0.0
		Ratio = 80.0
	endIf
	if IsFemale
		Ratio += (Males - Females)
	else
		Ratio += (Females - Males)
	endIf
	_SetSkill(ActorRef, kSexuality, PapyrusUtil.ClampFloat(Ratio, 1.0, 100.0) as float)
endFunction

int function GetSexuality(Actor ActorRef)
	return _GetSkill(ActorRef, kSexuality) as int
endFunction

; COMEBACK: Prbly want to move this into MCM Menu
string function GetSexualityTitle(Actor ActorRef)
	float ratio = _GetSkill(ActorRef, kSexuality)
	; Return sexuality title
	if ratio >= 65.0 || ratio == 0.0
		return "$SSL_Heterosexual"
	elseif ratio < 65.0 && ratio > 35.0
		return "$SSL_Bisexual"
	elseif GetGender(ActorRef) == 1
		return "$SSL_Lesbian"
	else
		return "$SSL_Gay"
	endIf
endFunction

bool function IsStraight(Actor ActorRef)
	return _GetSkill(ActorRef, kSexuality) >= 65.0
endFunction

bool function IsBisexual(Actor ActorRef)
	float ratio = _GetSkill(ActorRef, kSexuality)
	return ratio < 65.0 && ratio > 35.0
endFunction

bool function IsGay(Actor ActorRef)
	return _GetSkill(ActorRef, kSexuality) <= 35.0
endFunction

; ------------------------------------------------------- ;
; --- Time Based Stats                                --- ;
; ------------------------------------------------------- ;

; Last sex - Game time1 - float days
float function LastSexGameTime(Actor ActorRef)
	return _GetSkill(ActorRef, kLastGameTime)
endFunction

float function DaysSinceLastSex(Actor ActorRef)
	return Utility.GetCurrentGameTime() - LastSexGameTime(ActorRef)
endFunction

float function HoursSinceLastSex(Actor ActorRef)
	return DaysSinceLastSex(ActorRef) * 24.0
endFunction

float function MinutesSinceLastSex(Actor ActorRef)
	return DaysSinceLastSex(ActorRef) * 1440.0
endFunction

float function SecondsSinceLastSex(Actor ActorRef)
	return DaysSinceLastSex(ActorRef) * 86400.0
endFunction

string function LastSexTimerString(Actor ActorRef)
	return ParseTime(SecondsSinceLastSex(ActorRef) as int)
endFunction

; Last sex - Real Time - float seconds
float function LastSexRealTime(Actor ActorRef)
	return _GetSkill(ActorRef, kLastRealTime)
endFunction

float function SecondsSinceLastSexRealTime(Actor ActorRef)
	float LastSex = LastSexRealTime(ActorRef)
	if LastSex > 0.0
		return SexLabUtil.GetCurrentGameRealTime() - LastSex
	endIf
	return 0.0
endFunction

float function MinutesSinceLastSexRealTime(Actor ActorRef)
	return SecondsSinceLastSexRealTime(ActorRef) / 60.0
endFunction

float function HoursSinceLastSexRealTime(Actor ActorRef)
	return SecondsSinceLastSexRealTime(ActorRef) / 3600.0
endFunction

float function DaysSinceLastSexRealTime(Actor ActorRef)
	return SecondsSinceLastSexRealTime(ActorRef) / 86400.0
endFunction

string function LastSexTimerStringRealTime(Actor ActorRef)
	return ParseTime(SecondsSinceLastSexRealTime(ActorRef) as int)
endFunction

; ------------------------------------------------------- ;
; --- Other Actor Info                                --- ;
; ------------------------------------------------------- ;

int function GetHighestRelationshipRankInList(Actor ActorRef, Actor[] ActorList) global
	int i = ActorList.Length
	if i == 1
		if ActorRef == ActorList[0]
			return 0
		else
			return ActorRef.GetRelationshipRank(ActorList[0])
		endIf
	endIf
	int out = -4 ; lowest possible
	while i > 0
		i -= 1
		if ActorList[i] != ActorRef && out < 4
			int rank = ActorRef.GetRelationshipRank(ActorList[i])
			if rank > out
				out = rank
			endIf
		endIf
	endWhile
	return out
endFunction

; ------------------------------------------------------- ;
; --- System Use                                      --- ;
; ------------------------------------------------------- ;

function RecordThread(Actor ActorRef, int Gender, int HadRelation, float StartedAt, float RealTime, float GameTime, bool WithPlayer, Actor VictimRef, int[] Genders, float[] SkillXP) global native
function AddPartners(Actor ActorRef, Actor[] AllPositions, Actor[] Victims)
	if !ActorRef || AllPositions.Length < 2 || AllPositions.Find(none) != -1
		return ; No Positions
	endIf
	bool IsVictim = Victims.Find(ActorRef) > -1
	bool IsAggressor = Victims.Length && !IsVictim
	Actor[] Positions = PapyrusUtil.RemoveActor(AllPositions, ActorRef)

	int i = 0
	While (i < Positions.Length)
		If (IsVictim && Victims.Find(Positions[i]) == -1)
			AddEncounter(ActorRef, Positions[i], ENC_Victim)
		ElseIf (IsAggressor && Victims.Find(Positions[i]) > -1)
			AddEncounter(ActorRef, Positions[i], ENC_Assault)
		Else
			AddEncounter(ActorRef, Positions[i], ENC_Neutral)
		EndIf
		i += 1
	EndWhile
EndFunction
function TrimList(Actor ActorRef, string List, int count)
	count = StorageUtil.FormListCount(ActorRef, List) - count
	while count > 0
		count -= 1
		StorageUtil.FormListRemoveAt(ActorRef, List, 0)
	endwhile
endFunction

function _ResetStats(Actor ActorRef) global
	ResetStatistics(ActorRef)
EndFunction
function ResetStats(Actor ActorRef)
	_ResetStats(ActorRef)
endFunction

function EmptyStats(Actor ActorRef)
endFunction

Actor[] function GetAllSkilledActors()
	int[] list = GetAllTrackedActors()
	Actor[] ret = PapyrusUtil.ActorArray(list.Length)
	int i = 0
	While (i < list.Length)
		ret[i] = Game.GetForm(list[i]) as Actor
		i += 1
	EndWhile
	return PapyrusUtil.RemoveActor(ret, none)
EndFunction
function ClearNPCSexSkills()
	Actor[] list = GetAllSkilledActors()
	int i = 0
	While (i < list.Length)
		If (list[i] != PlayerRef)
			ResetStatistics(list[i])
		EndIf
		i += 1
	EndWhile
EndFunction

function ClearCustomStats(Form FormRef)
	Actor act = FormRef as Actor
	If (!act)
		return
	EndIf
	DeleteAllCustomStats(act)
endFunction

int function GetGender(Actor ActorRef)
	return SexLabUtil.GetAPI().GetGender(ActorRef)
endFunction

; ------------------------------------------------------- ;
; --- Skill Type IDs
; ------------------------------------------------------- ;

int function StatID(string Name)
	return SkillNames().Find(Name)
endFunction
int property kForeplay hidden
	int function get()
		return 0
	endFunction
endProperty
int property kVaginal hidden
	int function get()
		return 1
	endFunction
endProperty
int property kAnal hidden
	int function get()
		return 2
	endFunction
endProperty
int property kOral hidden
	int function get()
		return 3
	endFunction
endProperty
int property kPure hidden
	int function get()
		return 4
	endFunction
endProperty
int property kLewd hidden
	int function get()
		return 5
	endFunction
endProperty
int property kMales hidden
	int function get()
		return 6
	endFunction
endProperty
int property kFemales hidden
	int function get()
		return 7
	endFunction
endProperty
int property kCreatures hidden
	int function get()
		return 8
	endFunction
endProperty
int property kMasturbation hidden
	int function get()
		return 9
	endFunction
endProperty
int property kAggressor hidden
	int function get()
		return 10
	endFunction
endProperty
int property kVictim hidden
	int function get()
		return 11
	endFunction
endProperty
int property kSexCount hidden
	int function get()
		return 12
	endFunction
endProperty
int property kPlayerSex hidden
	int function get()
		return 13
	endFunction
endProperty
int property kSexuality hidden
	int function get()
		return 14
	endFunction
endProperty
int property kTimeSpent hidden
	int function get()
		return 15
	endFunction
endProperty
int property kLastRealTime hidden
	int function get()
		return 16
	endFunction
endProperty
int property kLastGameTime hidden
	int function get()
		return 17
	endFunction
endProperty
int property kVaginalCount hidden
	int function get()
		return 18
	endFunction
endProperty
int property kAnalCount hidden
	int function get()
		return 19
	endFunction
endProperty
int property kOralCount hidden
	int function get()
		return 20
	endFunction
endProperty
int property kStatCount hidden
	int function get()
		return 21
	endFunction
endProperty


string function PrintSkills(Actor ActorRef)
	float[] Skills = GetSkills(ActorRef)
	string Output
	Output += " -- "+ActorRef.GetLeveledActorBase().GetName()+" -- \n"
	Output += "\tForeplay: "+Skills[kForeplay] + "\n"
	Output += "\tVaginal: "+Skills[kVaginal] + "\n"
	Output += "\tVaginalCount: "+Skills[kVaginalCount] + "\n"
	Output += "\tAnal: "+Skills[kAnal] + "\n"
	Output += "\tAnalCount: "+Skills[kAnalCount] + "\n"
	Output += "\tOral: "+Skills[kOral] + "\n"
	Output += "\tOralCount: "+Skills[kOralCount] + "\n"
	Output += "\tPure: "+Skills[kPure] + "\n"
	Output += "\tLewd: "+Skills[kLewd] + "\n"
	Output += "\tMales: "+Skills[kMales] + "\n"
	Output += "\tFemales: "+Skills[kFemales] + "\n"
	Output += "\tCreatures: "+Skills[kCreatures] + "\n"
	Output += "\tMasturbation: "+Skills[kMasturbation] + "\n"
	Output += "\tAggressor: "+Skills[kAggressor] + "\n"
	Output += "\tVictim: "+Skills[kVictim] + "\n"
	Output += "\tSexCount: "+Skills[kSexCount] + "\n"
	Output += "\tPlayerSex: "+Skills[kPlayerSex] + "\n"
	Output += "\tSexuality: "+Skills[kSexuality] + "\n"
	Output += "\tTimeSpent: "+Skills[kTimeSpent] + "\n"
	Output += "\tLastRealTime: "+Skills[kLastRealTime] + "\n"
	Output += "\tLastGameTime: "+Skills[kLastGameTime] + "\n"
	Output += " --- "
	return Output
endFunction

; ------------------------------------------------------- ;
; --- DEPRECATED - DO NOT USE                         --- ;
; ------------------------------------------------------- ;

function UpgradeLegacyStats(Form FormRef, bool IsImportant)
endFunction

function ClearLegacyStats(Form FormRef)
endFunction

; v1.59b NOTICE:
; SexLab native skills storage has changed to use lists for storage
; instead of values. This allows for faster access internally and
; significantly shrinks the amount of data StorageUtil has to store.

; These functions will now reroute to their appropiate new/updated functions if
; they are used to attempt to access the native skills. If accessing if they
; are not used for native skills they will resort to old functionality

bool function HasInt(Actor ActorRef, string Stat)
	return HasStat(ActorRef, Stat)
endFunction
bool function HasFloat(Actor ActorRef, string Stat)
	return HasStat(ActorRef, Stat)
endFunction
bool function HasStr(Actor ActorRef, string Stat)
	return HasStat(ActorRef, Stat)
endFunction

int function GetInt(Actor ActorRef, string Stat)
	if SkillNames().Find(Stat) == -1
		return GetStatInt(ActorRef, Stat)
	endIf
	return GetSkill(ActorRef, Stat)
endFunction
float function GetFloat(Actor ActorRef, string Stat)
	if SkillNames().Find(Stat) == -1
		return GetStatFloat(ActorRef, Stat)
	endIf
	return GetSkillFloat(ActorRef, Stat)
endFunction
string function GetStr(Actor ActorRef, string Stat)
	return GetStat(ActorRef, Stat)
endFunction

function SetInt(Actor ActorRef, string Stat, int Value)
	if SkillNames().Find(Stat) != -1
		_SetSkill(ActorRef, SkillNames().Find(Stat), value as int)
	else
		SetStat(ActorRef, Stat, Value)
	endIf
endFunction
function SetFloat(Actor ActorRef, string Stat, float Value)
	if SkillNames().Find(Stat) != -1
		_SetSkill(ActorRef, SkillNames().Find(Stat), 0.0)
	else
		SetStat(ActorRef, Stat, Value)
	endIf
endFunction
function SetStr(Actor ActorRef, string Stat, string Value)
	SetStat(ActorRef, Stat, Value)
endFunction

function ClearInt(Actor ActorRef, string Stat)
	_SetSkill(ActorRef, SkillNames().Find(Stat), 0.0)
	ClearStat(ActorRef, Stat)
endFunction
function ClearFloat(Actor ActorRef, string Stat)
	_SetSkill(ActorRef, SkillNames().Find(Stat), 0.0)
	ClearStat(ActorRef, Stat)
endFunction
function ClearStr(Actor ActorRef, string Stat)
	ClearStat(ActorRef, Stat)
endFunction

function AdjustInt(Actor ActorRef, string Stat, int Amount)
	if Amount != 0 && ActorRef && Stat != ""
		if SkillNames().Find(stat) != -1
			AdjustSkill(ActorRef, Stat, Amount)
		else
			AdjustBy(ActorRef, Stat, Amount)
		endIf
	endIf
endfunction
function AdjustFloat(Actor ActorRef, string Stat, float Amount)
	if Amount != 0.0 && ActorRef && Stat != ""
		if SkillNames().Find(stat) != -1
			AdjustSkillFloat(ActorRef, Stat, Amount)
		else
			FloatAdjustBy(ActorRef, Stat, Amount)
		endIf
	endIf
endfunction

bool locked = false
state Testing
	event OnUpdate()
		Tester()
	endEvent
	function Tester()
		while locked
			utility.wait(0.5)
			Log("ActorStats Locked...")
		endWhile
		locked = true

		int i = 500
		while i
			i -= 1
			Debug.Trace("ACTORSTATS Lock Spin: "+i)
			Utility.WaitMenuMode(0.5)
		endWhile

		locked = false
	endFunction
endState
function Tester()
endFunction
