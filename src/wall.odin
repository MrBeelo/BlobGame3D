package bg3d

import rl "vendor:raylib"

wall_textures: [4]rl.Texture2D
wall_model_cache: map[rl.Vector3]rl.Model

LoadWall :: proc() {
	wall_textures[0] = LoadTextureDef("brick", .DIFFUSE)
	wall_textures[1] = LoadTextureDef("brick", .NORMAL)
	wall_textures[2] = LoadTextureDef("brick", .ROUGH)
	wall_textures[3] = LoadTextureDef("brick", .HEIGHT)
	for texture in (wall_textures) do rl.SetTextureWrap(texture, .REPEAT)
}

LoadWallModel :: proc(scale: rl.Vector3 = {1, 1, 1}) -> rl.Model {
	wall_mesh := GenCustomMeshCube(scale.x, scale.y, scale.z)
	wall_model := rl.LoadModelFromMesh(wall_mesh)
	AssignShader(&wall_model, material_shader, 0)
	AssignTexture(&wall_model, wall_textures[0], .ALBEDO, 0)
	AssignTexture(&wall_model, wall_textures[1], .NORMAL, 0)
	AssignTexture(&wall_model, wall_textures[2], .ROUGHNESS, 0)
	AssignTexture(&wall_model, wall_textures[3], .HEIGHT, 0)
	wall_model_cache[scale] = wall_model
	return wall_model
}

NewWall :: proc(pos: rl.Vector3, scale: rl.Vector3 = {1, 1, 1}, room_number := int(0), name := "Wall", force := false) -> Object {
	wall_model: rl.Model
	if model, ok := wall_model_cache[scale]; ok do wall_model = model; else do wall_model = LoadWallModel(scale)
	return NewObject(wall_model, pos, {}, 1, {.HEIGHT, .TILING}, true, name, room_number = room_number, force_draw = force)
}

UnloadWall :: proc() {
	for texture in (blob_textures) do rl.UnloadTexture(texture)
}

