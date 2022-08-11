-- Created by Mauro Pantin © 2018
--
-- License for usage is CC BY-NC-SA 4.0 (Creative Commons Attribution-NonCommercial-ShareAlike 4.0)
-- https://creativecommons.org/licenses/by-nc-sa/4.0/
--
-- TLDR:
-- You may use this code, share it and modify it in any way you see fit, as long as you provide attribution, 
-- and don't exploit it commercially. You may use the tool itself in a commercial project (film music, etc). 
-- Should you modify the tool and choose to redistribute the code, you must do it under the same license.

FrameRate = reaper.TimeMap_curFrameRate(0)
ProjectTempo = reaper.Master_GetTempo()
Tempo = 0
InputInicial = "180,4,8"
IncrementoFrames = (1/FrameRate)*2
Error = 0
MarkerCant = reaper.CountProjectMarkers(0)
FirstMarker, Garbage0, Offset = reaper.EnumProjectMarkers3(0,0)

function SaveMarkers()
	markers_pos = {}
	i=0
	repeat
		iRetval, bIsrgnOut, iPosOut, iRgnendOut, sNameOut, iMarkrgnindexnumberOut, iColorOur = reaper.EnumProjectMarkers3(0,i)
		if iRetval >= 1 then
			if bIsrgnOut == false then
				table.insert(markers_pos, iPosOut)
			end
			i = i+1
		end
	until iRetval == 0
	table.sort(markers_pos)
	return markers_pos
end


function DialogoInput()
	retval, Input = reaper.GetUserInputs ("Preferences", 3, "Target Tempo,Beats Per Measure,Subdivision", InputInicial)
	TargetTempo, BPM, SubD = string.match(Input, "([^,]+),([^,]+),([^,]+)")
end

function Candidatos()
	TargetTempo = tonumber(TargetTempo)
	MaxTempo = TargetTempo + 30
	MinTempo = TargetTempo - 30
	MaxTempo = tonumber(MaxTempo)
	MinTempo = tonumber(MinTempo)
	Tempo = MinTempo
	TempoCand = {}
	repeat
		table.insert(TempoCand, Tempo)
		Tempo = Tempo + IncrementoFrames
	until Tempo > MaxTempo
	table.sort(TempoCand)
	return TempoCand
end

function ClosestBeat(eventos, tempos)
	Resolucion = SubD/4
	i=0
	TablaError = {}
	for i,v in ipairs(tempos) do
		Interval = 0
		Error = 0     
		TotalError = 0
		ErrorSeconds = 0
		Hits = 0
		BeatRedondeado = tonumber(string.format("%.3f", v))
		for j,w in ipairs (eventos) do
			Interval = 60/(v*Resolucion)
			Beat, Error = math.modf(((w-Offset)/Interval)+1)
			if Error >= 0.9 then
				Beat = Beat+1
				Error = 0
			end
			if Error > 0 and Error <= 0.1 then
				Beat = Beat-1
				Error = 0
			end
			ErrorSeconds = (Error*(60/v))/Resolucion
			if ErrorSeconds < (1/FrameRate)/2 then
				ErrorSeconds = 0
			end
			if ErrorSeconds == 0 then
				Hits = Hits + 1
			end
			TotalError = tonumber(string.format("%.3f", TotalError + ErrorSeconds))

		end
		if TotalError <= (1/FrameRate)*MarkerCant or Hits >= MarkerCant*0.4 then
			table.insert (TablaError, v)
			table.insert (TablaError, TotalError)
			table.insert (TablaError, Hits)
			reaper.ShowConsoleMsg(BeatRedondeado.." BPM \t Total Error:"..TotalError.." seconds \t Amount of Hits: "..Hits)
			reaper.ShowConsoleMsg("\n")
		end
	end
	return TablaError
end

SaveMarkers()
DialogoInput()
Candidatos()
ClosestBeat(markers_pos, TempoCand)

reaper.UpdateArrange()
