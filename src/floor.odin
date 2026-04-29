package bg3d

import rl "vendor:raylib"

floor_textures : [4]rl.Texture2D // Diffuse, Normal Map, Roughness, Tiling

LoadFloor :: proc() {
	floor_textures[0] = LoadTextureDef("tiles", .DIFFUSE)
	floor_textures[1] = LoadTextureDef("tiles", .NORMAL)
	floor_textures[2] = LoadTextureDef("tiles", .ROUGH)
	floor_textures[3] = LoadTextureDef("tiles", .HEIGHT)
	for texture in (floor_textures) do rl.SetTextureWrap(texture, .REPEAT)
}

AssignFloorTextures :: proc(model: ^rl.Model) {
	AssignShader(model, material_shader, 0)
	AssignTexture(model, floor_textures[0], .ALBEDO, 0)
	AssignTexture(model, floor_textures[1], .NORMAL, 0)
	AssignTexture(model, floor_textures[2], .ROUGHNESS, 0)
	AssignTexture(model, floor_textures[3], .HEIGHT, 0)
}

NewFloor :: proc(pos: rl.Vector3, scale: rl.Vector3, room_number := int(0), name := "Floor", force := false) -> Object {
	floor_model: rl.Model
	if model, ok := cube_model_cache[scale]; ok do floor_model = model; else do floor_model = GetCubeModel(scale)
	AssignFloorTextures(&floor_model)
	return NewObject(floor_model, pos, {}, 1, {.NORMAL, .HEIGHT, .TILING}, true, name, room_number = room_number, force_draw = force)
}

UnloadFloor :: proc() {
	for texture in (floor_textures) do rl.UnloadTexture(texture)
}