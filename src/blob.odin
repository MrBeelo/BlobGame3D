package bg3d

import rl "vendor:raylib"

blob_textures: [2]rl.Texture2D
blob_model: rl.Model

LoadBlob :: proc() {
	blob_textures[0] = LoadTextureDef("blob", .DIFFUSE)
	blob_textures[1] = LoadTextureDef("blob", .ROUGH)
	
	blob_model = LoadModel("blob.glb")
	AssignShader(&blob_model, material_shader, 1)
	AssignTexture(&blob_model, blob_textures[0], .ALBEDO, 1)
	AssignTexture(&blob_model, blob_textures[1], .ROUGHNESS, 1)
}

NewBlob :: proc(pos: rl.Vector3, rot: rl.Vector3 = {}, scale: rl.Vector3 = {1, 1, 1}, name := "Blob", force := false) -> Object {
	return NewObject(blob_model, pos, rot, 0.05 * scale, {.ROUGH}, true, name, force_draw = force)
}

UnloadBlob :: proc() {
	for texture in (blob_textures) do rl.UnloadTexture(texture)
	rl.UnloadModel(blob_model)
}

