package bb3d

import rl "vendor:raylib"

light_position := rl.Vector3{0, 1, 0}
specular_exponent := 8
use_normal_map := 1

diffuse_loc : i32
normal_loc : i32
light_pos_loc : i32
specular_exponent_loc : i32
use_normal_map_loc : i32

LoadShader :: proc() {
	shader.locs[rl.ShaderLocationIndex.MAP_NORMAL] = rl.GetShaderLocation(shader, "normalMap")
	shader.locs[rl.ShaderLocationIndex.VECTOR_VIEW] = rl.GetShaderLocation(shader, "viewPos")
	
	light_pos_loc = rl.GetShaderLocation(shader, "lightPos")
	specular_exponent_loc = rl.GetShaderLocation(shader, "specularExponent")
	use_normal_map_loc = rl.GetShaderLocation(shader, "useNormalMap")
	
	rl.SetShaderValue(shader, specular_exponent_loc, &specular_exponent, .FLOAT)
	rl.SetShaderValue(shader, use_normal_map_loc, &use_normal_map, .INT)
}

UpdateShader :: proc() {
	rl.SetShaderValue(shader, light_pos_loc, &light_position, .VEC3)
	rl.SetShaderValue(shader, shader.locs[rl.ShaderLocationIndex.VECTOR_VIEW], &player.camera.position, .VEC3)
}