package bg3d

import rl "vendor:raylib"
import "core:strings"

f3 := false

UpdateDebug :: proc() {
	if(rl.IsKeyPressed(.F3)) do f3 = !f3
}

DrawDebugStat :: proc(name: string, index: int, args: ..any) {
	format_name := concat({name, ": "})
		
	for arg in (args) {
		fmt_string := ""
		switch type in (arg) {
			case int,i32: fmt_string = "%d, "
			case f32: fmt_string = "%.4f, "
			case bool: fmt_string = "%t, "
			case string: fmt_string = "%s, "
			case: fmt_string = "%.4v, "
		}
		format_name = concat({format_name, fmt_string})
	}
	
	rl.DrawText(formatc(format_name, ..args), 10, 10 + 40 * i32(index), 32, rl.LIGHTGRAY)
}

DrawDebugBreak :: proc(name: string, index: int) {
	rl.DrawText(to_cstr(concat({"----- ", name, " -----"})), 10, 10 + 40 * i32(index), 32, rl.LIGHTGRAY)
}

DrawDebug :: proc() {
	if(f3) {
		DrawDebugStat("FPS", 0, rl.GetFPS())
		DrawDebugStat("Game State", 1, game_state)
		DrawDebugBreak("PLAYER", 2)
		DrawDebugStat("Speed", 3, player.speed)
		DrawDebugStat("Pos", 4, player.pos)
		DrawDebugStat("Vel", 5, player.vel)
		DrawDebugStat("Size", 6, player.size)
		DrawDebugStat("Rot", 7, player.rot)
		DrawDebugStat("Walljumps", 8, player.walljumps)
		DrawDebugStat("Colls", 9, player.collisions)
		DrawDebugBreak("TEMP", 10)
		DrawDebugStat("Saferoom Begin", 11, saferoom_start_sequence_timer.duration, (f32(rl.GetTime()) - saferoom_start_sequence_timer.start_time))
		DrawDebugStat("Saferoom Begin 2", 12, GetRemainingTime(&saferoom_start_sequence_timer))
	}
}