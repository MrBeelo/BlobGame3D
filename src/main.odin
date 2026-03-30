package bb3d

import "core:fmt"
import "core:math"
import rl "vendor:raylib" 

// Helper Functions
sin :: math.sin
cos :: math.cos
min :: math.min
max :: math.max
clamp :: math.clamp
abs :: math.abs
round :: proc(x: f32, n: f32) -> f32 { return n * ((x + n / 2) / n) }

// Global Constants
SCREEN_SIZE :: rl.Vector2{1920, 1080}
SIM_FPS :: 60
RELATIVE_MAP_SIZE :: 50

// Global Constants that WILL BE REMOVED
GRID_SPACING :: 0.2

main :: proc() {
	rl.SetConfigFlags({.VSYNC_HINT, .WINDOW_HIGHDPI, .MSAA_4X_HINT})
	rl.InitWindow(i32(SCREEN_SIZE.x), i32(SCREEN_SIZE.y), "Blob Game 3D")
	defer rl.CloseWindow()
	rl.DisableCursor()

	player := NewPlayer()

	for(!rl.WindowShouldClose()) {
		// Updating Area
		UpdatePlayer(&player)

		// Drawing Area
		rl.BeginDrawing()
		defer rl.EndDrawing()

		rl.ClearBackground(rl.SKYBLUE)

		rl.BeginMode3D(player.camera)

		// This stuff WILL BE REMOVED (except maybe the plane)
		rl.DrawGrid(RELATIVE_MAP_SIZE / GRID_SPACING, GRID_SPACING)
		rl.DrawPlane({round(player.pos.x, 10), -0.01, round(player.pos.z, 10)}, {RELATIVE_MAP_SIZE, RELATIVE_MAP_SIZE}, rl.WHITE)
		rl.DrawCube({}, 1, 1, 1, rl.RED)

		rl.EndMode3D()

		// Debug info (might move this somewhere else)
		rl.DrawText(fmt.ctprintf("FPS: %d", rl.GetFPS()), 10, 10, 32, rl.LIGHTGRAY)
		rl.DrawText(fmt.ctprintf("Speed: %f", player.speed), 10, 10 + 40 * 1, 32, rl.LIGHTGRAY)
		rl.DrawText(fmt.ctprintf("FOV: %f", player.fov), 10, 10 + 40 * 2, 32, rl.LIGHTGRAY)
		rl.DrawText(fmt.ctprintf("Pos: %f, %f, %f", player.pos.x, player.pos.y, player.pos.z), 10, 10 + 40 * 3, 32, rl.LIGHTGRAY)
		rl.DrawText(fmt.ctprintf("Vel: %f, %f, %f", player.vel.x, player.vel.y, player.vel.z), 10, 10 + 40 * 4, 32, rl.LIGHTGRAY)
	}
}