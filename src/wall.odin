package bb3d

import rl "vendor:raylib"

wall_textures: [2]rl.Texture2D

LoadWall :: proc() {
	wall_textures[0] = rl.LoadTexture("res/textures/brick_diffuse.png")
	wall_textures[1] = rl.LoadTexture("res/textures/brick_rough.png")
	//for texture in (wall_textures) do rl.SetTextureWrap(texture, .REPEAT)
}

NewWall :: proc(pos: rl.Vector3, scale: rl.Vector3 = {1, 1, 1}) -> Object {
	wall_mesh := rl.GenMeshCube(scale.x, scale.y, scale.z)
	wall_model := rl.LoadModelFromMesh(wall_mesh)
	AssignShader(&wall_model, material_shader, 0)
	AssignTexture(&wall_model, wall_textures[0], .ALBEDO, 0)
	AssignTexture(&wall_model, wall_textures[1], .ROUGHNESS, 0)
	//GenerateTangents(&wall_model)
	return NewObject(wall_model, pos, {}, 0, 1, {.ROUGH})
}

UnloadWall :: proc() {
	for texture in (blob_textures) do rl.UnloadTexture(texture)
}

