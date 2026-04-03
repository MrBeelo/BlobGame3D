package bb3d

import rl "vendor:raylib"

wall_textures: [4]rl.Texture2D

LoadWall :: proc() {
	wall_textures[0] = rl.LoadTexture("res/textures/brick_diffuse.png")
	wall_textures[1] = rl.LoadTexture("res/textures/brick_normal.png")
	wall_textures[2] = rl.LoadTexture("res/textures/brick_rough.png")
	wall_textures[3] = rl.LoadTexture("res/textures/brick_height.png")
	for texture in (wall_textures) do rl.SetTextureWrap(texture, .REPEAT)
}

NewWall :: proc(pos: rl.Vector3, scale: rl.Vector3 = {1, 1, 1}) -> Object {
	wall_mesh := GenCustomMeshCube(scale.x, scale.y, scale.z)
	wall_model := rl.LoadModelFromMesh(wall_mesh)
	AssignShader(&wall_model, material_shader, 0)
	AssignTexture(&wall_model, wall_textures[0], .ALBEDO, 0)
	AssignTexture(&wall_model, wall_textures[1], .NORMAL, 0)
	AssignTexture(&wall_model, wall_textures[2], .ROUGHNESS, 0)
	AssignTexture(&wall_model, wall_textures[3], .HEIGHT, 0)
	return NewObject(wall_model, pos, {}, 0, 1, {.NORMAL, .ROUGH, .HEIGHT, .TILING}, "Wall")
}

UnloadWall :: proc() {
	for texture in (blob_textures) do rl.UnloadTexture(texture)
}

