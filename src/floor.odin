package bb3d

import rl "vendor:raylib"

floor_textures : [4]rl.Texture2D // Diffuse, Normal Map, Roughness
floor_model: rl.Model

LoadFloor :: proc() {
	floor_textures[0] = LoadTextureDef("tiles", .DIFFUSE)
	floor_textures[1] = LoadTextureDef("tiles", .NORMAL)
	floor_textures[2] = LoadTextureDef("tiles", .ROUGH)
	floor_textures[3] = LoadTextureDef("tiles", .HEIGHT)
	for texture in (floor_textures) do rl.SetTextureWrap(texture, .REPEAT)
}

NewFloor :: proc(pos: rl.Vector3, scale: rl.Vector3, name := "Floor", force := false) -> Object {
	floor_mesh := GenCustomMeshCube(scale.x, scale.y, scale.z)
	floor_model := rl.LoadModelFromMesh(floor_mesh)
	AssignShader(&floor_model, material_shader, 0)
	AssignTexture(&floor_model, floor_textures[0], .ALBEDO, 0)
	AssignTexture(&floor_model, floor_textures[1], .NORMAL, 0)
	AssignTexture(&floor_model, floor_textures[2], .ROUGHNESS, 0)
	AssignTexture(&floor_model, floor_textures[3], .HEIGHT, 0)
	return NewObject(floor_model, pos, {}, 1, {.NORMAL, .HEIGHT, .TILING}, true, name, force_draw = force)
}

AppendGroundFloor :: proc() {
	FLOOR_SIZE :: 50
	append(&objects, NewFloor({0, -0.01, 0}, {FLOOR_SIZE, 0.01, FLOOR_SIZE}, "GroundFloor", false))
}

UpdateFloor :: proc(obj: ^Object) {
	if(obj.name != "GroundFloor") do return
	obj.pos = {floor(player.pos.x), -0.01, floor(player.pos.z)}
}

UnloadFloor :: proc() {
	for texture in (floor_textures) do rl.UnloadTexture(texture)
	rl.UnloadModel(floor_model)
}