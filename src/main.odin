package bg3d

import "core:fmt"
import "core:math"
import "core:strings"
import rl "vendor:raylib"

// Global Constants
SCREEN_SIZE :: rl.Vector2{1920, 1080}
VERSION :: "0.4.3"
MAX_NUM :: 2_147_483_647

// Global Variables
should_exit := false
render_textures: [2]rl.RenderTexture2D

// Functions
print :: fmt.printf; formatc :: fmt.ctprintf; sin :: math.sin; cos :: math.cos; clamp :: math.clamp; abs :: math.abs
floor :: math.floor; sqrt :: math.sqrt; concat :: strings.concatenate; to_cstr :: strings.clone_to_cstring; rad :: math.to_radians
format :: proc(fmt: string, args: ..any) -> string { return string(formatc(fmt, ..args)) }
to_string :: proc(value: any) -> string { return format("%v", value) }
round :: proc(x: f32, n: f32) -> f32 { return n * ((x + n / 2) / n) }
contains :: proc(arr: []$T, x: T) -> bool { for y in (arr) do if (y == x) { return true }; return false }
clamp_low :: proc(value: $T, low: T) -> T { if(value < low) do return low; return value }
string_pop :: proc(str: string) -> string { text, err := strings.substring(cmd_text, 0, strings.rune_count(cmd_text) - 1); return text }
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
	rl.BeginTextureMode(render_textures[0])
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
	rl.BeginTextureMode(render_textures[1])
	rl.ClearBackground(rl.WHITE)
	texture_color := rl.RED if (GetRemainingClockTime() <= 0 && CanSeeMainGame()) else rl.WHITE
	rl.DrawTexturePro(render_textures[0].texture, {0, 0, SCREEN_SIZE.x, -SCREEN_SIZE.y}, {0, 0, SCREEN_SIZE.x, SCREEN_SIZE.y}, {}, 0, texture_color)
	if(CanSeeMainGame()) {
		DrawClock()
		DrawHealth(&player)
	}
	rl.EndTextureMode()
	
	// Draw the colored render texture
	rl.ClearBackground(rl.WHITE)
	if(game_state != .MAIN && game_state != .SAFEROOM_ENTER && ((!IsInMainGame()) || (IsInMainGame() && player.health <= 50))) do rl.BeginShaderMode(blur_shader)
	rl.DrawTexturePro(render_textures[1].texture, {0, 0, SCREEN_SIZE.x, -SCREEN_SIZE.y}, {0, 0, SCREEN_SIZE.x, SCREEN_SIZE.y}, {}, 0, rl.WHITE)
	if(game_state != .MAIN && game_state != .SAFEROOM_ENTER && ((!IsInMainGame()) || (IsInMainGame() && player.health <= 50))) do rl.EndShaderMode()
	
	// Draw other GUI
	DrawMenus()
	DrawDebug()
}

ResetGame :: proc(advance := false) {
	if(advance) do ResetPlayer(true); else do ResetPlayer()
	ResetRooms()
	if(!advance) {
		ResetRunStats()
		ResetClock()
	}
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