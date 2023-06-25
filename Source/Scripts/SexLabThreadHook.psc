ScriptName SexLabThreadHook Hidden
{
  Interface Script to manipulate a thread execution during its runtime

  **WHEN TO USE**
  Thread Hooks are blocking, explicit hooks to read and write SexLab threads at runtime, altering their behavior as needed
  Unlike regular. non blocking, Hooks which use mod events the interface here will block the execution of a SL thread, allowing for time sensitive information
  to be injected or altered. The blocking nature of these hooks also makes them potentially harmful to the users experience as they will pause the threads execution
  essentially leaving the user clueless about the current state of their scene, so use them with caution and beware of the amount of time you spend processing information here

  **HOW TO USE**
  1) Create a some form object that should receive the incoming events. The object may be any form so long it can hold a script
  2) Create YOUR OWN custom script and have it extend "SexLabThreadHook", attach it to the Formy you created
  3) Copy the "@Interface" functions you see in this script and paste them into the script you just created and implement them
  4) Call the Register() function (in this script) to register your Hook to SexLab to receive incoming hook events, e.g. in an OnInit Event or similar
  5) Youre done \o/. Now every time a SexLab Thread reaches specific key points in its execution, it will call back into the interface functions listed here

  **BEST PRACTICES**
  1) Due to the time sensitive nature of this feature, it is highly recommended to cache some variable that tells you if you really want to monitor some running thread
      And example on how to accomplish this is given below
}

; ------------------------------------------------------- ;
; --- Interface                                       --- ;
; ------------------------------------------------------- ;
;/
  The following scripts are to be implemented by some other script extending this one
/;

; Called when all of the threads data is set, before the active animation is chosen
Function AnimationStarting(SexLabThread akThread)
EndFunction

; Called whenever a new stage is picked, including the very first one
Function StageStart(SexLabThread akThread)
EndFunction

; Called whenever a stage ends, including the very last one
Function StageEnd(SexLabThread akThread)
EndFunction

; Called once the animation has ended
Function AnimationEnd(SexLabThread akThread)
EndFunction

; ------------------------------------------------------- ;
; --- Registration                                    --- ;
; ------------------------------------------------------- ;
;/
  Shorthands to register and unregister the hook
/;

; Register the given Hook to no receive events
; Registration is only recognized for newly started threads. You wont receive events for already running threads
Function Register()
  SexLabUtil.GetAPI().RegisterHook(self)
EndFunction

; Unregister the given Hook to no longer receive events
; Removal of the registration status is recognized for any following animations. You will still receive events for currently running threads
Function Unregister()
  SexLabUtil.GetAPI().UnregisterHook(self)
EndFunction

; ------------------------------------------------------- ;
; --- Lock                                            --- ;
; ------------------------------------------------------- ;
;/
  Example implementation for a simple locking system
  There is no need to implement this system if you only care about hooking some one specific function
  Ensure that OnInit() can be called here, i.e. if you overwrite OnInit() call "parent.OnInit()" at before exiting the OnInit event

  **USAGE**
  Function AnimationStarting(SexLabThread akThread)
    bool ignore_thread_events = ...
    SetLocked(ignore_thread_events)

    ...
  EndFunction

  Function StageStart(SexLabThread akThread)
    If (Islocked(akThread))
      return
    EndIf

    ...
  EndFunction
/;

bool[] _m
Event OnInit()
  _m = Utility.CreateBoolArray(sslThreadSlots.GetTotalThreadCount(), false)
EndEvent

; Return if the calling thread is locked or not
bool Function IsLocked(SexLabThread akThread)
  return _m[akThread.GetThreadID()]
EndFunction

; Set the locked state of this specific thread
Function SetLocked(SexLabThread akThread, bool abLocked)
  _m[akThread.GetThreadID()] = abLocked
EndFunction