package bb3d

import "core:fmt"
import rl "vendor:raylib"

main :: proc() {
	rl.SetConfigFlags({.VSYNC_HINT, .WINDOW_HIGHDPI, .MSAA_4X_HINT})
	rl.InitWindow(i32(SCREEN_SIZE.x), i32(SCREEN_SIZE.y), "Blob Game 3D")
	defer rl.CloseWindow()
	rl.InitAudioDevice()
	rl.SetExitKey(.KEY_NULL)
	
	LoadGameResources()
	defer UnloadGameResources()
	
	AppendGroundFloor()
	AppendUIFlashlight()
	append(&objects, NewBlob({2, 0, 2}, {0, 155, 0}, 1))
	append(&objects, NewBlob({4, 0, 4}, {0, 20, 0}, 2))
	append(&objects, NewWall({8, 0.5, 8}, {1, 1, 10}))
	AppendNewBlock({-10, 0.5, 10}, {1, 1, 2}, objs = &objects)
	
	for(!rl.WindowShouldClose() && !should_exit) {
		UpdateGame()
				
		rl.BeginDrawing()
		defer rl.EndDrawing()
		
		DrawGame()
	}
}