package bg3d

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

debug_on := false

UpdateDebug :: proc() {
	if rl.IsKeyPressed(.F3) do debug_on = !debug_on
}

DrawDebugStat :: proc(name: string, index: int, args: ..any) {
	format_name := strings.concatenate({name, ": "})
		
	for arg in (args) {
		fmt_string := ""
		switch type in (arg) {
			case int,i32: fmt_string = "%d, "
			case f32: fmt_string = "%.4f, "
			case bool: fmt_string = "%t, "
			case string: fmt_string = "%s, "
			case: fmt_string = "%.4v, "
		}
		format_name = strings.concatenate({format_name, fmt_string})
	}
	
	rl.DrawText(fmt.ctprintf(format_name, ..args), 10, 10 + 40 * i32(index), 32, rl.LIGHTGRAY)
}

DrawDebugBreak :: proc(name: string, index: int) {
	rl.DrawText(strings.clone_to_cstring(strings.concatenate({"----- ", name, " -----"})), 10, 10 + 40 * i32(index), 32, rl.LIGHTGRAY)
}

DrawDebug :: proc() {
	if debug_on {
		DrawDebugStat("FPS", 0, rl.GetFPS())
		DrawDebugStat("Game State", 1, game_state)
		DrawDebugBreak("PLAYER", 2)
		DrawDebugStat("Speed", 3, player.speed)
		DrawDebugStat("Pos", 4, player.pos)
		DrawDebugStat("Vel", 5, player.vel)
		DrawDebugStat("Height", 6, player.height)
		DrawDebugStat("Rot", 7, player.rot)
		DrawDebugStat("Walljumps", 8, player.walljumps)
		DrawDebugStat("Colls", 9, player.collisions)
		DrawDebugStat("Close Objects", 10, len(near_objects[:]))
		DrawDebugStat("Upgrades", 11, run_upgrades)
	}
}