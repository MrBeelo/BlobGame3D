package bg3d

import "core:strings"
import rl "vendor:raylib"

LoadGameResources :: proc() {
	LoadShaders() // Should ALWAYS be first!
	LoadSkybox()
	LoadBlob()
	LoadFlashlight()
	LoadSounds()
	LoadFonts()
	LoadDeathSequence()
	LoadGameRenderTexture()
	LoadSaferoomSequences()
	LoadMusic()
	LoadCube()
	LoadUpgradeButtons()
	
	ResetPlayer()
	InitMenus()
	InitRooms()
	InitClock()
	InitCoyoteTimer()
	AppendUIFlashlight()
}

UnloadGameResources :: proc() {
	UnloadShaders()
	UnloadSkybox()
	UnloadBlob()
	UnloadFlashlight()
	UnloadSounds()
	UnloadFonts()
	UnloadDeathSequence()
	UnloadGameRenderTexture()
	UnloadSaferoomSequences()
	UnloadMusic()
	UnloadCube()
	UnloadUpgradeButtons()
}

LoadGameRenderTexture :: proc() { 
	for &render_texture in render_textures do render_texture = rl.LoadRenderTexture(i32(SCREEN_SIZE.x), i32(SCREEN_SIZE.y))
}

UnloadGameRenderTexture :: proc() { 
	for &render_texture in render_textures do rl.UnloadRenderTexture(render_texture)
}

LoadTexture :: proc(path: string) -> rl.Texture2D {
	return rl.LoadTexture(strings.clone_to_cstring(strings.concatenate({"textures/", path})))
}

LoadImage :: proc(path: string) -> rl.Image {
	return rl.LoadImage(strings.clone_to_cstring(strings.concatenate({"textures/", path})))
}

LoadModel :: proc(path: string) -> rl.Model {
	return rl.LoadModel(strings.clone_to_cstring(strings.concatenate({"models/", path})))
}

LoadShader :: proc(vs_path: string, fs_path: string) -> rl.Shader {
	vs := strings.clone_to_cstring(strings.concatenate({"shaders/", vs_path}))
	fs := strings.clone_to_cstring(strings.concatenate({"shaders/", fs_path}))
	return rl.LoadShader(vs, fs)
}

LoadShaderFs :: proc(path: string) -> rl.Shader {
	return rl.LoadShader(nil, strings.clone_to_cstring(strings.concatenate({"shaders/", path})))
}

LoadShaderDef :: proc(name: string) -> rl.Shader {
	vs := strings.concatenate({name, ".vs"})
	fs := strings.concatenate({name, ".fs"})
	return LoadShader(vs, fs)
}

LoadShaderFsDef :: proc(name: string) -> rl.Shader {
	return LoadShaderFs(strings.concatenate({name, ".fs"}))
}

LoadSound :: proc(path: string) -> rl.Sound {
	return rl.LoadSound(strings.clone_to_cstring(strings.concatenate({"sounds/", path})))
}

TextureType :: enum{ DIFFUSE, NORMAL, ROUGH }
LoadTextureCubeDef :: proc(name: string, type: TextureType, suffix := ".png") -> rl.Texture2D {
	type_string := "diffuse"
	switch type {
		case .DIFFUSE: type_string = "diffuse"
		case .NORMAL: type_string = "normal"
		case .ROUGH: type_string = "rough"
	}
	
	return LoadTexture(strings.concatenate({name, "/", name, "_", type_string, suffix}))
}

LoadFont :: proc(path: string, font_size: i32) -> rl.Font {
	return rl.LoadFontEx(strings.clone_to_cstring(strings.concatenate({"fonts/", path})), font_size, nil, 0)
}

LoadFontDef :: proc(name: string) -> rl.Font {
	return LoadFont(strings.concatenate({name, ".ttf"}), 512)
}