package bg3d

import rl "vendor:raylib"

floor_textures : [4]rl.Texture2D // Diffuse, Normal Map, Roughness
floor_model_cache: map[rl.Vector3]rl.Model

LoadFloor :: proc() {
	floor_textures[0] = LoadTextureDef("tiles", .DIFFUSE)
	floor_textures[1] = LoadTextureDef("tiles", .NORMAL)
	floor_textures[2] = LoadTextureDef("tiles", .ROUGH)
	floor_textures[3] = LoadTextureDef("tiles", .HEIGHT)
	for texture in (floor_textures) do rl.SetTextureWrap(texture, .REPEAT)
}

LoadFloorModel :: proc(scale: rl.Vector3 = {1, 1, 1}) -> rl.Model {
	floor_mesh := GenCustomMeshCube(scale.x, scale.y, scale.z)
	floor_model := rl.LoadModelFromMesh(floor_mesh)
	AssignShader(&floor_model, material_shader, 0)
	AssignTexture(&floor_model, floor_textures[0], .ALBEDO, 0)
	AssignTexture(&floor_model, floor_textures[1], .NORMAL, 0)
	AssignTexture(&floor_model, floor_textures[2], .ROUGHNESS, 0)
	AssignTexture(&floor_model, floor_textures[3], .HEIGHT, 0)
	floor_model_cache[scale] = floor_model
	return floor_model
}

NewFloor :: proc(pos: rl.Vector3, scale: rl.Vector3, room_number := int(0), name := "Floor", force := false) -> Object {
	floor_model: rl.Model
	if model, ok := floor_model_cache[scale]; ok do floor_model = model; else do floor_model = LoadFloorModel(scale)
	return NewObject(floor_model, pos, {}, 1, {.NORMAL, .HEIGHT, .TILING}, true, name, room_number = room_number, force_draw = force)
}

UnloadFloor :: proc() {
	for texture in (floor_textures) do rl.UnloadTexture(texture)
}