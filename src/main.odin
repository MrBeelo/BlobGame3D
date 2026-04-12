package bg3d

import rl "vendor:raylib"

UpdateGame :: proc() {
	UpdateShaders()
	UpdateDebug()
	UpdateSounds()
	UpdateMenus()
	UpdateClock()
	UpdateDeathSequence()
		
	if(!CanSeeMainGame() && !IsInDeathSequence()) {
		UpdateMainBackground()
		UpdateObjects(main_bg_objects)
	} else if(!IsInDeathSequence()) {
		if(IsInMainGame()) { UpdatePlayer(&player); UpdateRunStats() }
		UpdateObjects()
		if(rl.IsKeyPressed(.ESCAPE)) do ChangeGameState(IsInMainGame() ? .PAUSED : .PLAYING)
		if(rl.IsKeyPressed(.SLASH)) do ChangeGameState(IsInMainGame() ? .COMMAND : .PLAYING)
	}
}

DrawGame :: proc() {
	// Begin drawing to the regular game render texture
	rl.BeginTextureMode(game_texture)
	rl.ClearBackground(rl.WHITE)
	if(CanSeeMainBackground()) {
		rl.BeginMode3D(main_bg_camera)
		DrawSkybox()
		DrawObjects(main_bg_objects)
		rl.EndMode3D()
	} else if(CanSeeMainGame()) {
		rl.BeginMode3D(player.camera)
		DrawSkybox()
		DrawObjects()
		rl.EndMode3D()
	}
	rl.EndTextureMode()
	
	// Take the regular game render texture and apply color to it, passing it to colored_game_texture
	rl.BeginTextureMode(colored_game_texture)
	rl.ClearBackground(rl.WHITE)
	texture_color := rl.RED if (GetRemainingClockTime() <= 0 && CanSeeMainGame()) else rl.WHITE
	rl.DrawTexturePro(game_texture.texture, {0, 0, SCREEN_SIZE.x, -SCREEN_SIZE.y}, {0, 0, SCREEN_SIZE.x, SCREEN_SIZE.y}, {}, 0, texture_color)
	if(CanSeeMainGame()) {
		DrawClock()
		DrawHealth(&player)
	}
	rl.EndTextureMode()
	
	// Draw the colored render texture
	rl.ClearBackground(rl.WHITE)
	if(game_state != .MAIN && ((!IsInMainGame()) || (IsInMainGame() && player.health <= 50))) do rl.BeginShaderMode(blur_shader)
	rl.DrawTexturePro(colored_game_texture.texture, {0, 0, SCREEN_SIZE.x, -SCREEN_SIZE.y}, {0, 0, SCREEN_SIZE.x, SCREEN_SIZE.y}, {}, 0, rl.WHITE)
	if(game_state != .MAIN && ((!IsInMainGame()) || (IsInMainGame() && player.health <= 50))) do rl.EndShaderMode()
	
	// Draw other GUI
	DrawMenus()
	DrawDebug()
}

ResetGame :: proc() {
	ResetPlayer()
	ResetRunStats()
	ResetClock()
	ResetRooms()
}

main :: proc() {
	rl.SetConfigFlags({.VSYNC_HINT, .WINDOW_HIGHDPI, .MSAA_4X_HINT})
	rl.InitWindow(i32(SCREEN_SIZE.x), i32(SCREEN_SIZE.y), "Blob Game 3D")
	defer rl.CloseWindow()
	rl.InitAudioDevice()
	rl.SetExitKey(.KEY_NULL)
	SearchAndSetResourceDir("res")
	
	LoadGameResources()
	defer UnloadGameResources()
	
	for(!rl.WindowShouldClose() && !should_exit) {
		UpdateGame()		
		rl.BeginDrawing()
		defer rl.EndDrawing()
		DrawGame()
	}
}