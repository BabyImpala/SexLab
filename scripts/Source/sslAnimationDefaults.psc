scriptname sslAnimationDefaults extends sslAnimationFactory

function LoadAnimations()
	Debug.TraceAndbox("Loading Animations")

	Register("ArrokOral")
	Register("ArrokAnal")
endFunction


function ArrokOral(string eventName, string id, float argNum, form sender)
	Name = "Arrok 69"

	SetContent(Sexual)
	SetSFX(Sucking)

	int a1 = AddPosition(Female, addCum=Oral)
	AddPositionStage(a1, "Arrok_Oral_A1_S1", 0)
	AddPositionStage(a1, "Arrok_Oral_A1_S2", 0)
	AddPositionStage(a1, "Arrok_Oral_A1_S3", 0, silent = true, openMouth = true)
	AddPositionStage(a1, "Arrok_Oral_A1_S3", 0, silent = true, openMouth = true)
	AddPositionStage(a1, "Arrok_Oral_A1_S4", 0)

	int a2 = AddPosition(Male)
	AddPositionStage(a2, "Arrok_Oral_A2_S1", 46, rotate = 180, silent = true, openMouth = true)
	AddPositionStage(a2, "Arrok_Oral_A2_S1", 46, rotate = 180, silent = true, openMouth = true)
	AddPositionStage(a2, "Arrok_Oral_A2_S2", 46, rotate = 180, silent = true, openMouth = true)
	AddPositionStage(a2, "Arrok_Oral_A2_S3", 46, rotate = 180, silent = true, openMouth = true)
	AddPositionStage(a2, "Arrok_Oral_A2_S3", 46, rotate = 180, silent = true, openMouth = true)

	AddTag("Arrok")
	AddTag("BBP")
	AddTag("Sex")
	AddTag("MF")
	AddTag("Oral")
	AddTag("Cunnilingus")
	AddTag("Blowjob")
	AddTag("69")

	Save()
endFunction

function ArrokAnal(string eventName, string id, float argNum, form sender)
	Name = "Arrok Anal"

	SetContent(Sexual)
	SetSFX(Squishing)

	int a1 = AddPosition(Female, addCum=Anal)
	AddPositionStage(a1, "Arrok_Anal_A1_S1", 0)
	AddPositionStage(a1, "Arrok_Anal_A1_S2", 0)
	AddPositionStage(a1, "Arrok_Anal_A1_S3", 0)
	AddPositionStage(a1, "Arrok_Anal_A1_S4", 0)

	int a2 = AddPosition(Male)
	AddPositionStage(a2, "Arrok_Anal_A2_S1", -117, silent = true, openMouth = true)
	AddPositionStage(a2, "Arrok_Anal_A2_S2", -103.5, sos = 3)
	AddPositionStage(a2, "Arrok_Anal_A2_S3", -121.5, sos = 4)
	AddPositionStage(a2, "Arrok_Anal_A2_S4", -123.5, sos = 3)

	AddTag("Arrok")
	AddTag("TBBP")
	AddTag("MF")
	AddTag("Anal")
	AddTag("Sex")
	AddTag("Dirty")

	Save()
endFunction