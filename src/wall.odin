package bg3d

import rl "vendor:raylib"

wall_textures: [4]rl.Texture2D

LoadWall :: proc() {
	wall_textures[0] = LoadTextureDef("brick", .DIFFUSE)
	wall_textures[1] = LoadTextureDef("brick", .NORMAL)
	wall_textures[2] = LoadTextureDef("brick", .ROUGH)
	wall_textures[3] = LoadTextureDef("brick", .HEIGHT)
	for texture in (wall_textures) do rl.SetTextureWrap(texture, .REPEAT)
}

AssignWallTextures :: proc(model: ^rl.Model) {
	AssignShader(model, material_shader, 0)
	AssignTexture(model, wall_textures[0], .ALBEDO, 0)
	AssignTexture(model, wall_textures[1], .NORMAL, 0)
	AssignTexture(model, wall_textures[2], .ROUGHNESS, 0)
	AssignTexture(model, wall_textures[3], .HEIGHT, 0)
}

NewWall :: proc(pos: rl.Vector3, scale: rl.Vector3 = {1, 1, 1}, room_number := int(0), name := "Wall", force := false) -> Object {
	wall_model: rl.Model
	if model, ok := cube_model_cache[scale]; ok do wall_model = model; else do wall_model = GetCubeModel(scale)
	AssignWallTextures(&wall_model)
	return NewObject(wall_model, pos, {}, 1, {.HEIGHT, .TILING}, true, name, room_number = room_number, force_draw = force)
}

UnloadWall :: proc() {
	for texture in (blob_textures) do rl.UnloadTexture(texture)
}

