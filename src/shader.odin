package bb3d

import "core:fmt"
import rl "vendor:raylib"

material_shader: rl.Shader
skybox_shader: rl.Shader
blur_shader: rl.Shader

light_position := rl.Vector3{0, 0.5, 0}
light_pos_loc: i32

light_color := rl.Vector3{0.2, 0.2, 0.2} // In the shader vec3 format! (Max is 1, 1, 1)
light_color_loc: i32
is_light_on: bool = true

tiling := rl.Vector2{1, 1}
tiling_loc: i32

environment_map := int(rl.MaterialMapIndex.CUBEMAP)
environment_map_loc: i32

material_use_map_locs: [4]i32 // Normal, rough

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
}

UpdateShaders :: proc() {
	if(game_state == .PLAYING || game_state == .PAUSED) do light_position = GetPosInFrontOfCamera({0, 0, 0.1})
	light_color = (is_light_on) ? {0.2, 0.2, 0.2} : {}
	rl.SetShaderValue(material_shader, light_pos_loc, &light_position, .VEC3)
	rl.SetShaderValue(material_shader, light_color_loc, &light_color, .VEC3)
	rl.SetShaderValue(material_shader, material_shader.locs[rl.ShaderLocationIndex.VECTOR_VIEW], &player.camera.position, .VEC3)
	rl.SetShaderValue(material_shader, tiling_loc, &tiling, .VEC2)
	rl.SetShaderValue(skybox_shader, environment_map_loc, &environment_map, .INT)
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