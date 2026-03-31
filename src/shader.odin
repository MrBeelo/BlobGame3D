package bb3d

import rl "vendor:raylib"

material_shader: rl.Shader
skybox_shader: rl.Shader

light_position := rl.Vector3{}
light_pos_loc : i32

environment_map := int(rl.MaterialMapIndex.CUBEMAP)
environment_map_loc : i32

LoadShaders :: proc() {
	material_shader = rl.LoadShader("res/shaders/material_shader.vs", "res/shaders/material_shader.fs")
	skybox_shader = rl.LoadShader("res/shaders/skybox_shader.vs", "res/shaders/skybox_shader.fs")
	
	material_shader.locs[rl.ShaderLocationIndex.VECTOR_VIEW] = rl.GetShaderLocation(material_shader, "viewPos")
	material_shader.locs[rl.ShaderLocationIndex.MAP_NORMAL] = rl.GetShaderLocation(material_shader, "normalMapTexture")
	material_shader.locs[rl.ShaderLocationIndex.MAP_ROUGHNESS] = rl.GetShaderLocation(material_shader, "roughnessTexture")
	light_pos_loc = rl.GetShaderLocation(material_shader, "lightPos")
	
	environment_map_loc = rl.GetShaderLocation(skybox_shader, "environmentMap")
}

UpdateShaders :: proc() {
	light_position = player.pos + {7, 2, 0}
	rl.SetShaderValue(material_shader, light_pos_loc, &light_position, .VEC3)
	rl.SetShaderValue(material_shader, material_shader.locs[rl.ShaderLocationIndex.VECTOR_VIEW], &player.camera.position, .VEC3)
	
	rl.SetShaderValue(skybox_shader, environment_map_loc, &environment_map, .INT)
}

UnloadShaders :: proc() {
	rl.UnloadShader(material_shader)
	rl.UnloadShader(skybox_shader)
}

ApplyShaderTexturesToModel :: proc(model : ^rl.Model, shader: rl.Shader, textures: [3]rl.Texture2D) {
	floor_model.materials[0].shader = shader
	floor_model.materials[0].maps[rl.MaterialMapIndex.ALBEDO].texture = textures[0]
	floor_model.materials[0].maps[rl.MaterialMapIndex.NORMAL].texture = textures[1]
	floor_model.materials[0].maps[rl.MaterialMapIndex.ROUGHNESS].texture = textures[2]
}

AliasingHelper :: proc(model : ^rl.Model) {
	rl.GenTextureMipmaps(&model.materials[0].maps[rl.MaterialMapIndex.ALBEDO].texture);
    rl.GenTextureMipmaps(&model.materials[0].maps[rl.MaterialMapIndex.NORMAL].texture);
    rl.GenTextureMipmaps(&model.materials[0].maps[rl.MaterialMapIndex.ROUGHNESS].texture);
    rl.SetTextureFilter(model.materials[0].maps[rl.MaterialMapIndex.ALBEDO].texture, rl.TextureFilter.TRILINEAR);
    rl.SetTextureFilter(model.materials[0].maps[rl.MaterialMapIndex.NORMAL].texture, rl.TextureFilter.TRILINEAR);
    rl.SetTextureFilter(model.materials[0].maps[rl.MaterialMapIndex.ROUGHNESS].texture, rl.TextureFilter.TRILINEAR);
}