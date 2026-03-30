package bb3d

import rl "vendor:raylib"

shader: rl.Shader

floor_diffuse_texture: rl.Texture2D
floor_normal_map_texture: rl.Texture2D
floor_mesh: rl.Mesh
floor_model: rl.Model

LoadGameResources :: proc() {
	shader = rl.LoadShader("res/shaders/normalmap.vs", "res/shaders/normalmap.fs")
	
	floor_diffuse_texture = rl.LoadTexture("res/textures/tiles2_diffuse.png")
	floor_normal_map_texture = rl.LoadTexture("res/textures/tiles2_normal.png")
	floor_model = rl.LoadModel("res/models/default_plane.glb")
	
	floor_model.materials[0].shader = shader
	floor_model.materials[0].maps[rl.MaterialMapIndex.ALBEDO].texture = floor_diffuse_texture
	floor_model.materials[0].maps[rl.MaterialMapIndex.NORMAL].texture = floor_normal_map_texture
	
	rl.GenTextureMipmaps(&floor_model.materials[0].maps[rl.MaterialMapIndex.ALBEDO].texture);
    rl.GenTextureMipmaps(&floor_model.materials[0].maps[rl.MaterialMapIndex.NORMAL].texture);
    rl.SetTextureFilter(floor_model.materials[0].maps[rl.MaterialMapIndex.ALBEDO].texture, rl.TextureFilter.TRILINEAR);
    rl.SetTextureFilter(floor_model.materials[0].maps[rl.MaterialMapIndex.NORMAL].texture, rl.TextureFilter.TRILINEAR);
}

UnloadGameResources :: proc() {
	rl.UnloadShader(shader)
	rl.UnloadTexture(floor_diffuse_texture)
	rl.UnloadTexture(floor_normal_map_texture)
	rl.UnloadModel(floor_model)
}
