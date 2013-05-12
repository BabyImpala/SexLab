scriptname sslAnimArrokReverseCowgirl extends sslBaseAnimation

; Actor 1 (Female)
idle property Arrok_ReverseCowgirl_A1_S1 auto
idle property Arrok_ReverseCowgirl_A1_S2 auto
idle property Arrok_ReverseCowgirl_A1_S3 auto
idle property Arrok_ReverseCowgirl_A1_S4 auto
; Actor 2 (Male)
idle property Arrok_ReverseCowgirl_A2_S1 auto
idle property Arrok_ReverseCowgirl_A2_S2 auto
idle property Arrok_ReverseCowgirl_A2_S3 auto
idle property Arrok_ReverseCowgirl_A2_S4 auto

function LoadAnimation()
	name = "Arrok Reverse Cowgirl"

	SetContent(Sexual)
	SetSFX(Squishing)

	int a1 = AddPosition(Female, 0, addCum=VaginalAnal)
	AddPositionStage(a1, Arrok_ReverseCowgirl_A1_S1)
	AddPositionStage(a1, Arrok_ReverseCowgirl_A1_S2)
	AddPositionStage(a1, Arrok_ReverseCowgirl_A1_S3)
	AddPositionStage(a1, Arrok_ReverseCowgirl_A1_S4)

	int a2 = AddPosition(Male, -105)
	AddPositionStage(a2, Arrok_ReverseCowgirl_A2_S1)
	AddPositionStage(a2, Arrok_ReverseCowgirl_A2_S2)
	AddPositionStage(a2, Arrok_ReverseCowgirl_A2_S3)
	AddPositionStage(a2, Arrok_ReverseCowgirl_A2_S4)

	AddTag("Arrok")
	AddTag("BBP")
	AddTag("Sex")
	AddTag("MF")
	AddTag("Dirty")
	AddTag("Cowgirl")
	AddTag("Anal")
endFunction