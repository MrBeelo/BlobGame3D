package bg3d

import rl "vendor:raylib"

material_shader: rl.Shader
skybox_shader: rl.Shader
blur_shader: rl.Shader

light_position := rl.Vector3{0, 0.5, 0}
light_pos_loc: i32

light_color := rl.Vector3{0.2, 0.2, 0.2} // In the shader vec3 format! (Max is 1, 1, 1)
light_color_loc: i32
is_light_on: bool = true

tiling := rl.Vector2{2, 2}
tiling_loc: i32

environment_map := int(rl.MaterialMapIndex.CUBEMAP)
environment_map_loc: i32

material_use_map_locs: [4]i32 // Normal, Rough, Height, Tiling?

blur_strength: f32 = 1
blur_strength_loc: i32

MaterialShaderType :: enum {
	NORMAL,
	ROUGH,
	HEIGHT,
	TILING
}

LoadShaders :: proc() {
	material_shader = LoadShaderDef("material")
	skybox_shader = LoadShaderDef("skybox")
	blur_shader = LoadShaderFsDef("blur")
	
	material_shader.locs[rl.ShaderLocationIndex.VECTOR_VIEW] = rl.GetShaderLocation(material_shader, "viewPos")
	material_shader.locs[rl.ShaderLocationIndex.MAP_NORMAL] = rl.GetShaderLocation(material_shader, "normalMapTexture")
	material_shader.locs[rl.ShaderLocationIndex.MAP_ROUGHNESS] = rl.GetShaderLocation(material_shader, "roughnessTexture")
	material_shader.locs[rl.ShaderLocationIndex.MAP_HEIGHT] = rl.GetShaderLocation(material_shader, "heightMapTexture")
	light_pos_loc = rl.GetShaderLocation(material_shader, "lightPos")
	light_color_loc = rl.GetShaderLocation(material_shader, "lightColor")
	tiling_loc = rl.GetShaderLocation(material_shader, "tiling")
	
	environment_map_loc = rl.GetShaderLocation(skybox_shader, "environmentMap")
	
	material_use_map_locs[0] = rl.GetShaderLocation(material_shader, "useNormalMap")
	material_use_map_locs[1] = rl.GetShaderLocation(material_shader, "useRoughness")
	material_use_map_locs[2] = rl.GetShaderLocation(material_shader, "useHeightMap")
	material_use_map_locs[3] = rl.GetShaderLocation(material_shader, "doTiling")
	
	blur_strength_loc = rl.GetShaderLocation(blur_shader, "blurStrength")
}

UpdateShaders :: proc() {
	if(CanSeeMainGame()) do light_position = GetPosInFrontOfCamera({0, 0, GetMaxDistInFrontOfCamera(1.7) - 0.2})
	light_color = (is_light_on) ? {0.2, 0.2, 0.2} : {}
	blur_strength = CalculateBlurStrength()
	
	rl.SetShaderValue(material_shader, light_pos_loc, &light_position, .VEC3)
	rl.SetShaderValue(material_shader, light_color_loc, &light_color, .VEC3)
	rl.SetShaderValue(material_shader, material_shader.locs[rl.ShaderLocationIndex.VECTOR_VIEW], &player.camera.position, .VEC3)
	rl.SetShaderValue(material_shader, tiling_loc, &tiling, .VEC2)
	rl.SetShaderValue(skybox_shader, environment_map_loc, &environment_map, .INT)
	rl.SetShaderValue(blur_shader, blur_strength_loc, &blur_strength, .FLOAT)
}

UnloadShaders :: proc() {
	rl.UnloadShader(material_shader)
	rl.UnloadShader(skybox_shader)
	rl.UnloadShader(blur_shader)
}

AssignShader :: proc(model: ^rl.Model, shader: rl.Shader, mat: int = 0) {
	model.materials[mat].shader = shader
}

AssignTexture :: proc(model: ^rl.Model, texture: rl.Texture2D, index: rl.MaterialMapIndex, mat: int = 0) {
	model.materials[mat].maps[index].texture = texture
}

AssignMaterialMaps :: proc(types: []MaterialShaderType) {
	for type in (MaterialShaderType) {
		loc: i32
		switch(type) {
			case .NORMAL: loc = material_use_map_locs[0]
			case .ROUGH: loc = material_use_map_locs[1]
			case .HEIGHT: loc = material_use_map_locs[2]
			case .TILING: loc = material_use_map_locs[3]
		}
		
		use_shader := (contains(types, type)) ? 1 : 0
		rl.SetShaderValue(material_shader, loc, &use_shader, .INT)
	}
}

CalculateBlurStrength :: proc() -> f32 {
	if(game_state != .PLAYING) do return 3
	return 0 if(player.health > 50) else (MAX_HEALTH - player.health) / MAX_HEALTH * 4
}