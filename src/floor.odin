package bb3d

import rl "vendor:raylib"

floor_textures : [3]rl.Texture2D // Diffuse, Normal Map, Roughness
floor_model: rl.Model

LoadFloor :: proc() {
	floor_textures[0] = rl.LoadTexture("res/textures/tiles_diffuse.png")
	floor_textures[1] = rl.LoadTexture("res/textures/tiles_normal.png")
	floor_textures[2] = rl.LoadTexture("res/textures/tiles_rough.png")
	
	floor_model = rl.LoadModel("res/models/default_plane.glb")
	ApplyShaderTexturesToModel(&floor_model, material_shader, floor_textures)
	AliasingHelper(&floor_model)
}

DrawFloor :: proc() {
	REPS :: 10
	for x in (-REPS..=REPS) { for z in (-REPS..=REPS) {
		pos := rl.Vector3{floor(player.pos.x) + f32(x), -0.01, floor(player.pos.z) + f32(z)}
		box := rl.BoundingBox{{pos.x - 1, pos.y - 1, pos.z - 1}, {pos.x + 1, pos.y + 1, pos.z + 1}}
		is_seen := FrustumContainsBox(GetCameraFrustum(&player), box)
		if(is_seen) do rl.DrawModel(floor_model, pos, 0.5, rl.WHITE)
	}}
}

UnloadFloor :: proc() {
	for texture in (floor_textures) do rl.UnloadTexture(texture)
	rl.UnloadModel(floor_model)
}