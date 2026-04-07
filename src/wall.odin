package bb3d

import rl "vendor:raylib"

wall_textures: [4]rl.Texture2D

LoadWall :: proc() {
	wall_textures[0] = LoadTextureDef("brick", .DIFFUSE)
	wall_textures[1] = LoadTextureDef("brick", .NORMAL)
	wall_textures[2] = LoadTextureDef("brick", .ROUGH)
	wall_textures[3] = LoadTextureDef("brick", .HEIGHT)
	for texture in (wall_textures) do rl.SetTextureWrap(texture, .REPEAT)
}

NewWall :: proc(pos: rl.Vector3, scale: rl.Vector3 = {1, 1, 1}, name := "Wall", force := false) -> Object {
	wall_mesh := GenCustomMeshCube(scale.x, scale.y, scale.z)
	wall_model := rl.LoadModelFromMesh(wall_mesh)
	AssignShader(&wall_model, material_shader, 0)
	AssignTexture(&wall_model, wall_textures[0], .ALBEDO, 0)
	AssignTexture(&wall_model, wall_textures[1], .NORMAL, 0)
	AssignTexture(&wall_model, wall_textures[2], .ROUGHNESS, 0)
	AssignTexture(&wall_model, wall_textures[3], .HEIGHT, 0)
	return NewObject(wall_model, pos, {}, 1, {.NORMAL, .ROUGH, .HEIGHT, .TILING}, true, name, force_draw = force)
}

UnloadWall :: proc() {
	for texture in (blob_textures) do rl.UnloadTexture(texture)
}

