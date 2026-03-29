package bb3d

import "core:fmt"
import "core:math"
import rl "vendor:raylib" 

sin :: math.sin
cos :: math.cos
min :: math.min
max :: math.max
clamp :: math.clamp
round :: proc(x: f32, n: f32) -> f32 { return n * ((x + n / 2) / n) }

main :: proc() {
	screenWidth :: 1920
	screenHeight :: 1080

	rl.SetConfigFlags({.VSYNC_HINT, .WINDOW_HIGHDPI, .MSAA_4X_HINT})

	rl.InitWindow(screenWidth, screenHeight, "Blob Game 3D")
	defer rl.CloseWindow()
	
	rl.DisableCursor()

	map_size :: 50
	grid_spacing :: 0.2

	player := NewPlayer()

	for !rl.WindowShouldClose() {
		UpdatePlayer(&player)

		rl.BeginDrawing()
		defer rl.EndDrawing()

		rl.ClearBackground(rl.SKYBLUE)

		rl.BeginMode3D(player.camera)

		rl.DrawGrid(map_size / grid_spacing, grid_spacing)
		rl.DrawPlane({round(player.pos.x, 10), -0.01, round(player.pos.z, 10)}, {map_size, map_size}, rl.WHITE)

		rl.EndMode3D()

		rl.DrawText(fmt.ctprintf("FPS: %d", rl.GetFPS()), 10, 10, 32, rl.LIGHTGRAY)
		rl.DrawText(fmt.ctprintf("Speed: %f", player.speed), 10, 10 + 40 * 1, 32, rl.LIGHTGRAY)
		rl.DrawText(fmt.ctprintf("FOV: %f", player.fov), 10, 10 + 40 * 2, 32, rl.LIGHTGRAY)
	}
}
