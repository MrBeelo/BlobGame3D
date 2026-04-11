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
		DrawDebugBreak("PLAYER", 1)
		DrawDebugStat("Speed", 2, player.speed)
		DrawDebugStat("Pos", 3, player.pos)
		DrawDebugStat("Vel", 4, player.vel)
		DrawDebugStat("Size", 5, player.size)
		DrawDebugStat("Rot", 6, player.rot)
		DrawDebugStat("Walljumps", 7, player.walljumps)
		DrawDebugBreak("CAMERA", 8)
		DrawDebugStat("FOVY", 9, player.camera.fovy)
		DrawDebugStat("Pos", 10, player.camera.position)
		DrawDebugStat("Target", 11, player.camera.target)
		DrawDebugStat("Up", 12, player.camera.up)
		DrawDebugBreak("TEMPORARY", 13)
		DrawDebugStat("Death Sequence Time", 14, GetRemainingTime(&death_sequence_timer))
		DrawDebugStat("Remaining Time", 15, GetRemainingClockTime())
		DrawDebugStat("Clock Active", 16, clock_timer.active)
		DrawDebugStat("Static Playing", 17, rl.IsSoundPlaying(static_sound))
	}
}