package bb3d

import "core:math"
import rl "vendor:raylib"
import rlgl "vendor:raylib/rlgl"

main :: proc() {
	rl.SetConfigFlags({.VSYNC_HINT, .WINDOW_HIGHDPI, .MSAA_4X_HINT})
	rl.InitWindow(i32(SCREEN_SIZE.x), i32(SCREEN_SIZE.y), "Blob Game 3D")
	defer rl.CloseWindow()
	rl.DisableCursor()
	
	LoadGameResources()
	defer UnloadGameResources()
	
	player = NewPlayer()
	
	append(&objects, NewBlob({2, 0, 2}, {0, 1, 0}, 155, 1))
	append(&objects, NewBlob({4, 0, 4}, {0, 1, 0}, 20, 2))
	
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
		DrawObjects()
		rl.EndShaderMode()
				
		rl.EndMode3D()
		
		DrawDebug()
	}
}