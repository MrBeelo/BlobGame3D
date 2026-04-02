package bb3d

import "core:fmt"
import rl "vendor:raylib"

material_shader: rl.Shader
skybox_shader: rl.Shader

light_position := rl.Vector3{}
light_pos_loc : i32

environment_map := int(rl.MaterialMapIndex.CUBEMAP)
environment_map_loc : i32

material_use_map_locs: [2]i32 // Normal, rough

MaterialShaderType :: enum {
	NORMAL,
	ROUGH
}

LoadShaders :: proc() {
	material_shader = rl.LoadShader("res/shaders/material.vs", "res/shaders/material.fs")
	skybox_shader = rl.LoadShader("res/shaders/skybox.vs", "res/shaders/skybox.fs")
	
	material_shader.locs[rl.ShaderLocationIndex.VECTOR_VIEW] = rl.GetShaderLocation(material_shader, "viewPos")
	material_shader.locs[rl.ShaderLocationIndex.MAP_NORMAL] = rl.GetShaderLocation(material_shader, "normalMapTexture")
	material_shader.locs[rl.ShaderLocationIndex.MAP_ROUGHNESS] = rl.GetShaderLocation(material_shader, "roughnessTexture")
	light_pos_loc = rl.GetShaderLocation(material_shader, "lightPos")
	
	environment_map_loc = rl.GetShaderLocation(skybox_shader, "environmentMap")
	
	material_use_map_locs[0] = rl.GetShaderLocation(material_shader, "useNormalMap")
	material_use_map_locs[1] = rl.GetShaderLocation(material_shader, "useRoughness")
}

UpdateShaders :: proc() {
	light_position = GetPosInFrontOfCamera(0.1)
	rl.SetShaderValue(material_shader, light_pos_loc, &light_position, .VEC3)
	rl.SetShaderValue(material_shader, material_shader.locs[rl.ShaderLocationIndex.VECTOR_VIEW], &player.camera.position, .VEC3)
	
	rl.SetShaderValue(skybox_shader, environment_map_loc, &environment_map, .INT)
}

UnloadShaders :: proc() {
	rl.UnloadShader(material_shader)
	rl.UnloadShader(skybox_shader)
}

AssignShader :: proc(model: ^rl.Model, shader: rl.Shader, mat: int = 0) {
	model.materials[mat].shader = shader
}

AssignTexture :: proc(model: ^rl.Model, texture: rl.Texture2D, index: rl.MaterialMapIndex, mat: int = 0) {
	model.materials[mat].maps[index].texture = texture
}

AliasingHelper :: proc(model: ^rl.Model, material: int) {
	rl.GenTextureMipmaps(&model.materials[material].maps[rl.MaterialMapIndex.ALBEDO].texture);
    rl.GenTextureMipmaps(&model.materials[material].maps[rl.MaterialMapIndex.NORMAL].texture);
    rl.GenTextureMipmaps(&model.materials[material].maps[rl.MaterialMapIndex.ROUGHNESS].texture);
    rl.SetTextureFilter(model.materials[material].maps[rl.MaterialMapIndex.ALBEDO].texture, rl.TextureFilter.TRILINEAR);
    rl.SetTextureFilter(model.materials[material].maps[rl.MaterialMapIndex.NORMAL].texture, rl.TextureFilter.TRILINEAR);
    rl.SetTextureFilter(model.materials[material].maps[rl.MaterialMapIndex.ROUGHNESS].texture, rl.TextureFilter.TRILINEAR);
}

GenerateTangents :: proc(model: ^rl.Model) {
	for i in 0..<model.meshCount do rl.GenMeshTangents(&model.meshes[i])
}

AssignMaterialMaps :: proc(types: []MaterialShaderType) {
	for type in (MaterialShaderType) {
		loc: i32
		switch(type) {
			case .NORMAL: loc = material_use_map_locs[0]
			case .ROUGH: loc = material_use_map_locs[1]
		}
		
		use_shader := (contains(types, type)) ? 1 : 0
		rl.SetShaderValue(material_shader, loc, &use_shader, .INT)
	}
}