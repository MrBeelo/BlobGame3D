package bb3d

import rl "vendor:raylib"

light_position := rl.Vector3{0, 1, 0}
light_pos_loc : i32

LoadShader :: proc() {
	shader.locs[rl.ShaderLocationIndex.VECTOR_VIEW] = rl.GetShaderLocation(shader, "viewPos")
	shader.locs[rl.ShaderLocationIndex.MAP_NORMAL] = rl.GetShaderLocation(shader, "normalMapTexture")
	shader.locs[rl.ShaderLocationIndex.MAP_ROUGHNESS] = rl.GetShaderLocation(shader, "roughnessTexture")
	
	light_pos_loc = rl.GetShaderLocation(shader, "lightPos")
}

UpdateShader :: proc() {
	rl.SetShaderValue(shader, light_pos_loc, &light_position, .VEC3)
	rl.SetShaderValue(shader, shader.locs[rl.ShaderLocationIndex.VECTOR_VIEW], &player.camera.position, .VEC3)
}