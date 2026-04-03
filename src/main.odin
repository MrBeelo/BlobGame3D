package bb3d

import "core:math"
import rl "vendor:raylib"

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
	append(&objects, NewWall({8, 1, 8}, {1, 1, 10}))
	
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
		
		DrawSkybox()
		DrawFloor()
		DrawObjects()
				
		rl.EndMode3D()
		
		DrawDebug()
	}
}