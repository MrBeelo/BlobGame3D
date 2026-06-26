package bg3d

import rl "vendor:raylib"

blob_textures: [2]rl.Texture2D
blob_model: rl.Model

LoadBlob :: proc() {
	blob_textures[0] = LoadTextureCubeDef("blob", .DIFFUSE)
	blob_textures[1] = LoadTextureCubeDef("blob", .ROUGH)
	
	blob_model = LoadModel("blob.glb")
	AssignShader(&blob_model, material_shader, 1)
	AssignTexture(&blob_model, blob_textures[0], .ALBEDO, 1)
	AssignTexture(&blob_model, blob_textures[1], .ROUGHNESS, 1)
}

NewBlob :: proc(pos: rl.Vector3, rot: rl.Vector3 = {}, scale: rl.Vector3 = {1, 1, 1}, room_number := int(0), force := false, 
rotating := true) -> Object {
	blob := NewObject(pos, rot, 0.05 * scale, blob_model, shader_types = {.ROUGH}, special_prop = .ROTATING_BLOB if rotating else .NONE, 
		room_number = room_number, props = {true, force, true})
	box := GetObjectOBB(blob)
	blob.box = box
	return blob
}

UnloadBlob :: proc() {
	for texture in (blob_textures) do rl.UnloadTexture(texture)
	rl.UnloadModel(blob_model)
}

UpdateRotatingBlob :: proc(obj: ^Object) {
	obj.rot.y += rl.GetFrameTime() * 20
}