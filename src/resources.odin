package bb3d

import rl "vendor:raylib"

material_shader: rl.Shader

floor_textures : [3]rl.Texture2D // Diffuse, Normal Map, Roughness
floor_mesh: rl.Mesh
floor_model: rl.Model

LoadGameResources :: proc() {
	material_shader = rl.LoadShader("res/shaders/material_shader.vs", "res/shaders/material_shader.fs")
	
	floor_textures[0] = rl.LoadTexture("res/textures/tiles_diffuse.png")
	floor_textures[1] = rl.LoadTexture("res/textures/tiles_normal.png")
	floor_textures[2] = rl.LoadTexture("res/textures/tiles_rough.png")
	floor_model = rl.LoadModel("res/models/default_plane.glb")
	
	ApplyShaderTexturesToModel(&floor_model, material_shader, floor_textures)
	AliasingHelper(&floor_model)
}

UnloadGameResources :: proc() {
	rl.UnloadShader(material_shader)
	for texture in (floor_textures) do rl.UnloadTexture(texture)
	rl.UnloadModel(floor_model)
}
