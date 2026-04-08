package bb3d

import "core:fmt"
import rl "vendor:raylib"

UpdateGame :: proc() {
	UpdateShaders()
	UpdateDebug()
	UpdateSounds()
	UpdateMenus()
	UpdateClock()
		
	if(game_state != .PLAYING && game_state != .PAUSED) {
		UpdateMainBackground()
		UpdateObjects(main_bg_objects)
	} else {
		if(game_state == .PLAYING) do UpdatePlayer(&player)
		UpdateObjects()
		if(rl.IsKeyPressed(.ESCAPE)) do ChangeGameState((game_state == .PLAYING) ? .PAUSED : .PLAYING)
	}
}

DrawGame :: proc() {
	rl.BeginTextureMode(game_texture)
	rl.ClearBackground(rl.WHITE)
	if(game_state != .PLAYING && game_state != .PAUSED) {
		rl.BeginMode3D(main_bg_camera)
		DrawSkybox()
		DrawObjects(main_bg_objects)
		rl.EndMode3D()
	} else {
		rl.BeginMode3D(player.camera)
		DrawSkybox()
		DrawObjects()
		rl.EndMode3D()
		DrawClock()
	}
	rl.EndTextureMode()
	
	rl.ClearBackground(rl.WHITE)
	if(game_state != .MAIN && game_state != .PLAYING) do rl.BeginShaderMode(blur_shader)
	rl.DrawTexturePro(game_texture.texture, {0, 0, SCREEN_SIZE.x, -SCREEN_SIZE.y}, {0, 0, SCREEN_SIZE.x, SCREEN_SIZE.y}, {}, 0, rl.WHITE)
	if(game_state != .MAIN && game_state != .PLAYING) do rl.EndShaderMode()
	
	DrawMenus()
	DrawDebug()
}

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
	AppendRoom(start_room)
	
	for(!rl.WindowShouldClose() && !should_exit) {
		UpdateGame()
				
		rl.BeginDrawing()
		defer rl.EndDrawing()
		
		DrawGame()
	}
}