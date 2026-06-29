package bg3d

import rl "vendor:raylib"

main :: proc() {
	rl.SetConfigFlags({.WINDOW_HIGHDPI, .MSAA_4X_HINT} + ({.VSYNC_HINT} if settings.vsync_enabled else {}))
	
	rl.InitWindow(i32(SCREEN_SIZE.x), i32(SCREEN_SIZE.y), "Blob Game 3D")
	defer rl.CloseWindow()
	
	rl.InitAudioDevice()
	defer rl.CloseAudioDevice()
	
	rl.SetExitKey(.KEY_NULL)
	//if !rl.IsWindowFullscreen() do rl.ToggleFullscreen()
	
	SearchAndSetResourceDir("res")
	LoadGameResources()
	defer UnloadGameResources()
	
	for !rl.WindowShouldClose() && !should_exit {
		UpdateGame()		
		rl.BeginDrawing()
		defer rl.EndDrawing()
		DrawGame()
	}
}

RenderPass :: enum{INITIAL, BLUR, UI}

SCREEN_SIZE :: rl.Vector2{1920, 1080}
VERSION :: "0.5.4"
MAX_NUM :: 2_147_483_647

should_exit := false
render_textures: [len(RenderPass)]rl.RenderTexture2D

contains :: proc(arr: []$T, x: T) -> bool { for y in (arr) do if y == x { return true }; return false }
djb2_hash :: proc(str: string, range: f32 = 100) -> f32 {
	hash: u32 = 5381
	for c in str do hash = ((hash << 5) + hash) + u32(c)
	return f32(hash) / f32(0xFFFFFFFF) * range // Returns a value in [0, range]
}

UpdateGame :: proc() {
	UpdateShaders()
	UpdateDebug()
	UpdateSounds()
	UpdateMenus()
	UpdateClock()
	UpdateDeathSequence()
	UpdateMusic()
		
	if !CanSeeMainGame() && !IsInDeathSequence() {
		UpdateMainBackground()
		UpdateObjects(main_bg_objects)
	} else if !IsInDeathSequence() {
		if IsInMainGame() { UpdatePlayer(&player); UpdateRunStats() }
		UpdateObjects()
		if rl.IsKeyPressed(.ESCAPE) do ChangeGameState(IsInMainGame() ? .PAUSED : .PLAYING)
		if rl.IsKeyPressed(.SLASH) do ChangeGameState(IsInMainGame() ? .COMMAND : .PLAYING)
	}

	if rl.IsKeyPressed(.F11) do rl.ToggleFullscreen()
}

DrawGame :: proc() {
	// First pass: INITIAL
	rl.BeginTextureMode(render_textures[int(RenderPass.INITIAL)])
	rl.ClearBackground(rl.WHITE)
	if CanSeeMainBackground() {
		rl.BeginMode3D(main_bg_camera)
		DrawSkybox()
		DrawObjects(GetFrustumFromCamera(&main_bg_camera, f32(SCREEN_SIZE[0] / f32(SCREEN_SIZE[1]))), main_bg_objects)
		rl.EndMode3D()
	} else if CanSeeMainGame() {
		rl.BeginMode3D(player.camera)
		DrawSkybox()
		DrawObjects(GetCameraFrustum(&player))
		rl.EndMode3D()
	}
	rl.EndTextureMode()
	
	// Second pass: BLUR
	rl.BeginTextureMode(render_textures[int(RenderPass.BLUR)])
	rl.ClearBackground(rl.WHITE)
	texture_color := rl.RED if GetRemainingClockTime() <= 0 && CanSeeMainGame() else rl.WHITE
	rl.DrawTexturePro(render_textures[int(RenderPass.INITIAL)].texture, {0, 0, SCREEN_SIZE.x, -SCREEN_SIZE.y}, {0, 0, SCREEN_SIZE.x, SCREEN_SIZE.y}, {}, 0, texture_color)
	if CanSeeMainGame() {
		DrawClock()
		DrawHealth(&player)
	}
	rl.EndTextureMode()
	
	// Third pass: UI
	rl.BeginTextureMode(render_textures[int(RenderPass.UI)])
	rl.ClearBackground(rl.WHITE)
	if game_state != .MAIN && game_state != .SAFEROOM_ENTER && ((!IsInMainGame()) || (IsInMainGame() && player.health <= 50)) do rl.BeginShaderMode(blur_shader)
	rl.DrawTexturePro(render_textures[int(RenderPass.BLUR)].texture, {0, 0, SCREEN_SIZE.x, -SCREEN_SIZE.y}, {0, 0, SCREEN_SIZE.x, SCREEN_SIZE.y}, {}, 0, rl.WHITE)
	if game_state != .MAIN && game_state != .SAFEROOM_ENTER && ((!IsInMainGame()) || (IsInMainGame() && player.health <= 50)) do rl.EndShaderMode()
	
	DrawMenus()
	DrawDebug()
	rl.EndTextureMode()

	// Final draw
	window_size := rl.Vector2{f32(rl.GetScreenWidth()), f32(rl.GetScreenHeight())}
	scale := min(window_size.x / SCREEN_SIZE.x, window_size.y / SCREEN_SIZE.y)
	dest := rl.Rectangle{(window_size.x - SCREEN_SIZE.x * scale) * 0.5, (window_size.y - SCREEN_SIZE.y * scale) * 0.5, SCREEN_SIZE.x * scale, SCREEN_SIZE.y * scale}
	rl.ClearBackground(rl.BLACK)
	rl.DrawTexturePro(render_textures[int(RenderPass.UI)].texture, {0, 0, SCREEN_SIZE.x, -SCREEN_SIZE.y}, dest, {}, 0, rl.WHITE)
}

ResetGame :: proc(advance := false) {
	if advance do ResetPlayer(true); else do ResetPlayer()
	ResetRooms()
	if !advance {
		ResetRunStats()
		ResetClock()
		clear(&run_upgrades)
	}
}