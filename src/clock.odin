package bg3d

import rl "vendor:raylib"

CLOCK_START_TIME :: 100
clock_timer: Timer

InitClock :: proc() { clock_timer = NewTimer(CLOCK_START_TIME, false, false, true) }
ResetClock :: proc() { ActivateTimer(&clock_timer) }
AddClockSeconds :: proc(secs: f32) { if(GetRemainingClockTime() > 0) do clock_timer.start_time += secs }
SetClockSeconds :: proc(secs: f32) { clock_timer.start_time = f32(rl.GetTime()) - (clock_timer.duration - secs)}
GetRemainingClockTime :: proc() -> f32 { return GetRemainingTime(&clock_timer) }

UpdateClock :: proc() {
	clock_timer.active = true if(IsInMainGame()) else false
	UpdateTimer(&clock_timer)
	if(!clock_timer.active) do clock_timer.start_time += rl.GetFrameTime()
}

DrawClock :: proc() {
	mins := int(floor(GetRemainingTime(&clock_timer) / 60))
	secs := int(floor(GetRemainingTime(&clock_timer))) % 60
	mins = clamp_low(mins, 0)
	secs = clamp_low(secs, 0)
	
	str := string(rl.TextFormat("%2d:%02d", mins, secs))
	color := rl.WHITE
	shakiness := rl.Vector2{3, 2}
	shake_length: f32 = 2 
	if(GetRemainingClockTime() <= 0) { 
		str = "XX:XX"
		color = rl.RED
		shakiness = {20, 17}
		shake_length = 1.4
	}
	
	FONT_SIZE :: 48
	FONT_SPACING :: 7
	text_size := MeasureText(str, FONT_SIZE, FONT_SPACING, .CHANGA_ONE, .REGULAR)
	DrawTextIndividiShakyBordered(str, {SCREEN_SIZE.x / 2 - text_size.x / 2, 100}, FONT_SIZE, FONT_SPACING, 3, .CHANGA_ONE, .REGULAR, color, 
		rl.BLACK, shakiness, shake_length)
}