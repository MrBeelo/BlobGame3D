package bb3d

import "core:fmt"
import "core:math"
import rl "vendor:raylib"
import rlgl "vendor:raylib/rlgl"

// Helper Functions
sin :: math.sin
cos :: math.cos
clamp :: math.clamp
abs :: math.abs
floor :: math.floor
sqrt :: math.sqrt
round :: proc(x: f32, n: f32) -> f32 { return n * ((x + n / 2) / n) }

LoadGameResources :: proc() {
	LoadShaders() // Should ALWAYS be first!
	LoadFloor()
	LoadSkybox()
}

UnloadGameResources :: proc() {
	UnloadShaders()
	UnloadFloor()
	UnloadSkybox()
}

// Helper Structs
Pair :: struct($T: typeid, $U: typeid) { first: T, second: U }

// Global Constants
SCREEN_SIZE :: rl.Vector2{1920, 1080}

// Global Variables
player : Player

main :: proc() {
	rl.SetConfigFlags({.WINDOW_HIGHDPI, .MSAA_4X_HINT})
	rl.InitWindow(i32(SCREEN_SIZE.x), i32(SCREEN_SIZE.y), "Blob Game 3D")
	defer rl.CloseWindow()
	rl.DisableCursor()
	
	LoadGameResources()
	defer UnloadGameResources()
	
	player = NewPlayer()

	for(!rl.WindowShouldClose()) {
		// Updating Area
		UpdatePlayer(&player)
		UpdateShaders()
		UpdateDebug()
				
		// Drawing Area
		rl.BeginDrawing()
		defer rl.EndDrawing()
		rl.ClearBackground(rl.WHITE)

		rl.BeginMode3D(player.camera)
		
		rlgl.DisableBackfaceCulling()
		rlgl.DisableDepthMask()
		DrawSkybox()
		rlgl.EnableBackfaceCulling()
		rlgl.EnableDepthMask()
		
		rl.BeginShaderMode(material_shader)
		DrawFloor()
		rl.EndShaderMode()
		
		rl.EndMode3D()
		
		DrawDebug()
	}
}