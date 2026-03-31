package bb3d

import rl "vendor:raylib"

light_position := rl.Vector3{0, 1, 0}
light_pos_loc : i32

LoadShader :: proc() {
	material_shader.locs[rl.ShaderLocationIndex.VECTOR_VIEW] = rl.GetShaderLocation(material_shader, "viewPos")
	material_shader.locs[rl.ShaderLocationIndex.MAP_NORMAL] = rl.GetShaderLocation(material_shader, "normalMapTexture")
	material_shader.locs[rl.ShaderLocationIndex.MAP_ROUGHNESS] = rl.GetShaderLocation(material_shader, "roughnessTexture")
	
	light_pos_loc = rl.GetShaderLocation(material_shader, "lightPos")
}

UpdateShader :: proc() {
	rl.SetShaderValue(material_shader, light_pos_loc, &light_position, .VEC3)
	rl.SetShaderValue(material_shader, material_shader.locs[rl.ShaderLocationIndex.VECTOR_VIEW], &player.camera.position, .VEC3)
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