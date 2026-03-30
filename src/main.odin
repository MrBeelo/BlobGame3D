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
floor :: math.floor
round :: proc(x: f32, n: f32) -> f32 { return n * ((x + n / 2) / n) }

// Helper Structs
Pair :: struct($T: typeid, $U: typeid) { first: T, second: U }

// Global Constants
SCREEN_SIZE :: rl.Vector2{1920, 1080}

player : Player

main :: proc() {
	rl.SetConfigFlags({.VSYNC_HINT, .WINDOW_HIGHDPI, .MSAA_4X_HINT})
	rl.InitWindow(i32(SCREEN_SIZE.x), i32(SCREEN_SIZE.y), "Blob Game 3D")
	defer rl.CloseWindow()
	rl.DisableCursor()
	
	LoadGameResources()
	defer UnloadGameResources()
	
	player = NewPlayer()
	
	LoadShader()

	for(!rl.WindowShouldClose()) {
		// Updating Area
		UpdatePlayer(&player)
		UpdateShader()
		
		if(rl.IsKeyPressed(.N)) do use_normal_map = (use_normal_map == 0) ? 1 : 0

		// Drawing Area
		rl.BeginDrawing()
		defer rl.EndDrawing()

		rl.ClearBackground(rl.SKYBLUE)

		rl.BeginMode3D(player.camera)
		rl.BeginShaderMode(shader)
		
		// Drawing the floor
		REPS :: 10
		for x in (-REPS..=REPS) { for z in (-REPS..=REPS) {
			rl.DrawModel(floor_model, {floor(player.pos.x) + f32(x), -0.01, floor(player.pos.z) + f32(z)}, 1, rl.WHITE)
		}}

		rl.EndShaderMode()
		
		rl.DrawCube(light_position, 0.3, 0.3, 0.3, rl.RED)
		
		rl.EndMode3D()

		// Debug info (might move this somewhere else)
		rl.DrawText(fmt.ctprintf("FPS: %d", rl.GetFPS()), 10, 10, 32, rl.LIGHTGRAY)
		rl.DrawText(fmt.ctprintf("Speed: %f", player.speed), 10, 10 + 40 * 1, 32, rl.LIGHTGRAY)
		rl.DrawText(fmt.ctprintf("FOV: %f", player.fov), 10, 10 + 40 * 2, 32, rl.LIGHTGRAY)
		rl.DrawText(fmt.ctprintf("Pos: %f, %f, %f", player.pos.x, player.pos.y, player.pos.z), 10, 10 + 40 * 3, 32, rl.LIGHTGRAY)
		rl.DrawText(fmt.ctprintf("Vel: %f, %f, %f", player.vel.x, player.vel.y, player.vel.z), 10, 10 + 40 * 4, 32, rl.LIGHTGRAY)
		rl.DrawText(fmt.ctprintf("NMap: %d", use_normal_map), 10, 10 + 40 * 5, 32, rl.LIGHTGRAY)
	}
}