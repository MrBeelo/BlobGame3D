package bb3d

import "core:math"
import rl "vendor:raylib"

death_sequence_timer: Timer
blob_strip: rl.Texture2D

LoadDeathSequence :: proc() {
	blob_strip = LoadTexture("blob_strip.png")
	death_sequence_timer = NewTimer(10, false, false)
}

UnloadDeathSequence :: proc() {
	rl.UnloadTexture(blob_strip)
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
	
	rl.DrawRectangle(0, 0, i32(SCREEN_SIZE.x), i32(SCREEN_SIZE.y), rl.BLACK)
	
	if(rem_time <= 8) {
		for i in 0..=16 {
			offset_y := sin((rem_time + f32(i)) * math.PI)
			rl.DrawTexturePro(blob_strip, {0, 0, 64, 1024}, {128 * f32(i), -offset_y * 32 - 64, 128, 2048}, {}, 0, {50, 50, 50, 255})
		}
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