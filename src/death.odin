package bb3d

import rl "vendor:raylib"

death_sequence_timer: Timer

InitDeathSequence :: proc() {
	death_sequence_timer = NewTimer(10, false, false)
}

BeginDeathSequence :: proc() {
	ActivateTimer(&death_sequence_timer)
	ChangeGameState(.DEAD)
}

UpdateDeathSequence :: proc() {
	if(game_state == .DEAD) do UpdateTimer(&death_sequence_timer)
}

DrawDeathSequence :: proc() {
	rem_time := GetRemainingTime(&death_sequence_timer)
	
	if(rem_time > 8) {
		rl.DrawRectangle(0, 0, i32(SCREEN_SIZE.x), i32(SCREEN_SIZE.y), rl.BLACK)
	} else {
		rl.DrawRectangle(0, 0, i32(SCREEN_SIZE.x), i32(SCREEN_SIZE.y), rl.DARKGRAY) // TO BE REPLACED WITH BLOBS!
	}
	
	DrawStatText(StatString(6.5, "Time Survived", GetTimeSurvived()), 0)
	DrawStatText(StatString(5.5, "Points", to_string(run_stats.points)), 1)
	DrawStatText(StatString(4.5, "Saferooms", to_string(run_stats.saferooms)), 2)
}

StatString :: proc(appear_time: f32, name: string, value: string) -> string {
	rem_time := GetRemainingTime(&death_sequence_timer)
	VALUE_APPEAR_DELAY :: 0.5
	str := ""
	if(rem_time <= appear_time) do str = concat({name, ": "})
	if(rem_time <= appear_time - VALUE_APPEAR_DELAY) do str = concat({str, value})
	return str
}

DrawStatText :: proc(stat_string: string, index: int) {
	FONT_SIZE :: 48
	FONT_SPACING :: 5
	stat_string_size := MeasureText(stat_string, FONT_SIZE, FONT_SPACING, .CHANGA_ONE, .ITALIC)
	DrawText(stat_string, {SCREEN_SIZE.x / 2 - stat_string_size.x / 2, 300 + 70 * f32(index)}, FONT_SIZE, FONT_SPACING, .CHANGA_ONE, .ITALIC)
}