package bb3d

import rl "vendor:raylib"

floor_textures : [4]rl.Texture2D // Diffuse, Normal Map, Roughness
floor_model: rl.Model

LoadFloor :: proc() {
	floor_textures[0] = rl.LoadTexture("res/textures/tiles_diffuse.png")
	floor_textures[1] = rl.LoadTexture("res/textures/tiles_normal.png")
	floor_textures[2] = rl.LoadTexture("res/textures/tiles_rough.png")
	floor_textures[3] = rl.LoadTexture("res/textures/tiles_height.png")
	for texture in (floor_textures) do rl.SetTextureWrap(texture, .REPEAT)
}

NewFloor :: proc(scale: f32) -> Object {
	floor_mesh := GenCustomMeshCube(scale, 0.01, scale)
	floor_model := rl.LoadModelFromMesh(floor_mesh)
	AssignShader(&floor_model, material_shader, 0)
	AssignTexture(&floor_model, floor_textures[0], .ALBEDO, 0)
	AssignTexture(&floor_model, floor_textures[1], .NORMAL, 0)
	AssignTexture(&floor_model, floor_textures[2], .ROUGHNESS, 0)
	AssignTexture(&floor_model, floor_textures[3], .HEIGHT, 0)
	return NewObject(floor_model, {floor(player.pos.x), -0.01, floor(player.pos.z)}, {}, 0, 1, {.NORMAL, .ROUGH, .HEIGHT, .TILING}, true, "Floor")
}

AppendFloor :: proc() {
	FLOOR_SIZE :: 50
	append(&objects, NewFloor(FLOOR_SIZE))
}

UpdateFloor :: proc(obj: ^Object) {
	if(obj.name != "Floor") do return
	obj.pos = {floor(player.pos.x), -0.01, floor(player.pos.z)}
}

UnloadFloor :: proc() {
	for texture in (floor_textures) do rl.UnloadTexture(texture)
	rl.UnloadModel(floor_model)
}