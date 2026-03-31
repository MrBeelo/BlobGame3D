package bb3d

import "core:fmt"
import rl "vendor:raylib"

f3 := true

UpdateDebug :: proc() {
	if(rl.IsKeyPressed(.F3)) do f3 = !f3
}

DrawDebug :: proc() {
	if(f3) {
		rl.DrawText(fmt.ctprintf("FPS: %d", rl.GetFPS()), 10, 10, 32, rl.LIGHTGRAY)
		rl.DrawText(fmt.ctprintf("Speed: %f", player.speed), 10, 10 + 40 * 1, 32, rl.LIGHTGRAY)
		rl.DrawText(fmt.ctprintf("FOV: %f", player.fov), 10, 10 + 40 * 2, 32, rl.LIGHTGRAY)
		rl.DrawText(fmt.ctprintf("Pos: %f, %f, %f", player.pos.x, player.pos.y, player.pos.z), 10, 10 + 40 * 3, 32, rl.LIGHTGRAY)
		rl.DrawText(fmt.ctprintf("Vel: %f, %f, %f", player.vel.x, player.vel.y, player.vel.z), 10, 10 + 40 * 4, 32, rl.LIGHTGRAY)
	}
}