package bb3d

import rl "vendor:raylib"

UpdateGame :: proc() {
	UpdateShaders()
	UpdateDebug()
	UpdateSounds()
	UpdateMenus()
	UpdateClock()
	UpdateDeathSequence()
		
	if(game_state != .PLAYING && game_state != .PAUSED && game_state != .DEAD) {
		UpdateMainBackground()
		UpdateObjects(main_bg_objects)
	} else if(game_state != .DEAD) {
		if(game_state == .PLAYING) { 
			UpdatePlayer(&player)
			UpdateRunStats()
		}
		
		UpdateObjects()
		if(rl.IsKeyPressed(.ESCAPE)) do ChangeGameState((game_state == .PLAYING) ? .PAUSED : .PLAYING)
	}
}

DrawGame :: proc() {
	rl.BeginTextureMode(game_texture)
	rl.ClearBackground(rl.WHITE)
	if(game_state != .PLAYING && game_state != .PAUSED && game_state != .DEAD) {
		rl.BeginMode3D(main_bg_camera)
		DrawSkybox()
		DrawObjects(main_bg_objects)
		rl.EndMode3D()
	} else if(game_state != .DEAD) {
		rl.BeginMode3D(player.camera)
		DrawSkybox()
		DrawObjects()
		rl.EndMode3D()
	}
	rl.EndTextureMode()
	
	rl.ClearBackground(rl.WHITE)
	texture_color := rl.RED if (GetRemainingClockTime() <= 0 && (game_state == .PLAYING || game_state == .PAUSED)) else rl.WHITE
	if(game_state != .MAIN && game_state != .PLAYING && game_state != .PAUSED) do rl.BeginShaderMode(blur_shader)
	rl.DrawTexturePro(game_texture.texture, {0, 0, SCREEN_SIZE.x, -SCREEN_SIZE.y}, {0, 0, SCREEN_SIZE.x, SCREEN_SIZE.y}, {}, 0, texture_color)
	if(game_state == .PLAYING || game_state == .PAUSED) {
		DrawClock()
		DrawHealth(&player)
	}
	if(game_state != .MAIN && game_state != .PLAYING && game_state != .PAUSED) do rl.EndShaderMode()
	
	DrawMenus()
	DrawDebug()
}

ResetGame :: proc() {
	ResetPlayer()
	ResetRunStats()
	ResetClock()
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