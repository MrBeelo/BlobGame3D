package bb3d

import "core:fmt"
import rl "vendor:raylib"
import "core:strings"

f3 := true

UpdateDebug :: proc() {
	if(rl.IsKeyPressed(.F3)) do f3 = !f3
}

DrawDebugStat :: proc(name: string, index: int, args: ..any) {
	concat :: strings.concatenate
	format := concat({name, ": "})
		
	for arg in (args) {
		fmt_string := ""
		switch type in (arg) {
			case int,i32: fmt_string = "%d, "
			case f32: fmt_string = "%.2f, "
			case bool: fmt_string = "%t, "
			case string: fmt_string = "%s, "
			case: fmt_string = "%.2v, "
		}
		format = concat({format, fmt_string})
	}
	
	rl.DrawText(fmt.ctprintf(format, ..args), 10, 10 + 40 * i32(index), 32, rl.LIGHTGRAY)
}

DrawDebug :: proc() {
	if(f3) {
		DrawDebugStat("FPS", 0, rl.GetFPS())
		DrawDebugStat("Speed", 1, player.speed)
		DrawDebugStat("FOV", 2, player.fov)
		DrawDebugStat("Pos", 3, player.pos)
		DrawDebugStat("Vel", 4, player.vel)
		DrawDebugStat("Size", 5, player.size)
		DrawDebugStat("Walljumps", 6, player.walljumps)
	}
}