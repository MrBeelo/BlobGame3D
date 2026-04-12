package bg3d

import rl "vendor:raylib"

LoadGameResources :: proc() {
	LoadShaders() // Should ALWAYS be first!
	LoadFloor()
	LoadSkybox()
	LoadBlob()
	LoadWall()
	LoadFlashlight()
	LoadSounds()
	LoadFonts()
	LoadDeathSequence()
	LoadGameRenderTexture()
	
	ResetPlayer()
	InitMenus()
	InitRooms()
	InitClock()
	AppendUIFlashlight()
}

UnloadGameResources :: proc() {
	UnloadShaders()
	UnloadFloor()
	UnloadSkybox()
	UnloadBlob()
	UnloadWall()
	UnloadFlashlight()
	UnloadSounds()
	UnloadFonts()
	UnloadDeathSequence()
	UnloadGameRenderTexture()
}

LoadGameRenderTexture :: proc() { 
	game_texture = rl.LoadRenderTexture(i32(SCREEN_SIZE.x), i32(SCREEN_SIZE.y))
	colored_game_texture = rl.LoadRenderTexture(i32(SCREEN_SIZE.x), i32(SCREEN_SIZE.y)) 
}
UnloadGameRenderTexture :: proc() { 
	rl.UnloadRenderTexture(game_texture)
	rl.UnloadRenderTexture(colored_game_texture)
}

LoadTexture :: proc(path: string) -> rl.Texture2D {
	return rl.LoadTexture(to_cstr(concat({"textures/", path})))
}

LoadImage :: proc(path: string) -> rl.Image {
	return rl.LoadImage(to_cstr(concat({"textures/", path})))
}

LoadModel :: proc(path: string) -> rl.Model {
	return rl.LoadModel(to_cstr(concat({"models/", path})))
}

LoadShader :: proc(vs_path: string, fs_path: string) -> rl.Shader {
	vs := to_cstr(concat({"shaders/", vs_path}))
	fs := to_cstr(concat({"shaders/", fs_path}))
	return rl.LoadShader(vs, fs)
}

LoadShaderFs :: proc(path: string) -> rl.Shader {
	return rl.LoadShader(nil, to_cstr(concat({"shaders/", path})))
}

LoadShaderDef :: proc(name: string) -> rl.Shader {
	vs := concat({name, ".vs"})
	fs := concat({name, ".fs"})
	return LoadShader(vs, fs)
}

LoadShaderFsDef :: proc(name: string) -> rl.Shader {
	return LoadShaderFs(concat({name, ".fs"}))
}

LoadSound :: proc(path: string) -> rl.Sound {
	return rl.LoadSound(to_cstr(concat({"sounds/", path})))
}

LoadTextureDef :: proc(name: string, type: TextureType, suffix := ".png") -> rl.Texture2D {
	type_string := "diffuse"
	switch(type) {
		case .DIFFUSE: type_string = "diffuse"
		case .NORMAL: type_string = "normal"
		case .ROUGH: type_string = "rough"
		case .HEIGHT: type_string = "height"
	}
	
	return LoadTexture(concat({name, "/", name, "_", type_string, suffix}))
}

LoadFont :: proc(path: string, font_size: i32) -> rl.Font {
	return rl.LoadFontEx(to_cstr(concat({"fonts/", path})), font_size, nil, 0)
}

LoadFontDef :: proc(name: string) -> rl.Font {
	return LoadFont(concat({name, ".ttf"}), 100)
}