scriptname sslThreadSlots extends Quest

sslThreadController[] Slots
sslThreadController[] property Threads hidden
	sslThreadController[] function get()
		return Slots
	endFunction
endProperty

sslThreadModel function PickModel(float TimeOut = 30.0)
	int i
	while i < Slots.Length
		if !Slots[i].IsLocked
			return Slots[i].Make()
		endIf
		i += 1
	endWhile
	return none
endFunction

sslThreadController function GetController(int tid)
	if tid < 0 || tid >= Slots.Length
		return none
	endIf
	return Slots[tid]
endfunction

int function FindActorController(Actor ActorRef)
	int i
	while i < Slots.Length
		if Slots[i].Positions.Find(ActorRef) != -1
			return i
		endIf
		i += 1
	endWhile
	return -1
endFunction

sslThreadController function GetActorController(Actor ActorRef)
	return GetController(FindActorController(ActorRef))
endFunction

function StopAll()
	int i = Slots.Length
	while i
		i -= 1
		Slots[i].EndAnimation(true)
	endWhile
endFunction

; ------------------------------------------------------- ;
; --- System Use Only                                 --- ;
; ------------------------------------------------------- ;

function Setup()
	GoToState("Locked")
	; Init variables
	Slots = new sslThreadController[15]
	int i = Slots.Length
	while i
		i -= 1
		if i > 9
			Slots[i] = Quest.GetQuest("SexLabThread"+i) as sslThreadController
		else
			Slots[i] = Quest.GetQuest("SexLabThread0"+i) as sslThreadController
		endIf
		Slots[i].ThreadInit(i)
	endWhile
	Debug.Trace("SexLab Threads: "+Slots)
	StorageUtil.FormListClear(none, "SexLabActors")
	GoToState("")
endFunction

state Locked
	function Setup()
	endFunction
endState

