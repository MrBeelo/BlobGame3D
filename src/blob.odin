package bb3d

import "core:fmt"
import rl "vendor:raylib"

blob_textures: [3]rl.Texture2D
blob_model: rl.Model

LoadBlob :: proc() {
	blob_textures[0] = rl.LoadTexture("res/textures/blob_diffuse.png")
	blob_textures[1] = rl.LoadTexture("res/textures/blob_normal.png")
	blob_textures[2] = rl.LoadTexture("res/textures/blob_rough.png")
	
	blob_model = rl.LoadModel("res/models/blob.glb")
	ApplyShaderTexturesToModel(&blob_model, material_shader, blob_textures, 1)
	GenerateTangents(&blob_model)
}

DrawBlob :: proc() {
	pos: rl.Vector3 = {2, 0, 2}
	rot: f32 = 0
	rl.DrawModelEx(blob_model, pos, {0, 1, 0}, rot, 0.05, rl.WHITE)
}

UnloadBlob :: proc() {
	for texture in (blob_textures) do rl.UnloadTexture(texture)
	rl.UnloadModel(blob_model)
}

