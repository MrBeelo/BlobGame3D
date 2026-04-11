package bg3d

import rl "vendor:raylib"
import "vendor:raylib/rlgl"

sky_image : rl.Image
sky_cubemap : rl.TextureCubemap
sky_mesh : rl.Mesh
sky_model : rl.Model

LoadSkybox :: proc() {
	sky_image = LoadImage("skybox.png")
	sky_cubemap = rl.LoadTextureCubemap(sky_image, .CROSS_FOUR_BY_THREE)
	sky_mesh = rl.GenMeshCube(1, 1, 1)
	sky_model = rl.LoadModelFromMesh(sky_mesh)
	sky_model.materials[0].shader = skybox_shader
	sky_model.materials[0].maps[rl.MaterialMapIndex.CUBEMAP].texture = sky_cubemap
}

DrawSkybox :: proc() {
	rlgl.DisableBackfaceCulling()
	rlgl.DisableDepthMask()
	rl.DrawModel(sky_model, player.camera.position, 1, rl.WHITE)
	rlgl.EnableBackfaceCulling()
	rlgl.EnableDepthMask()
}

UnloadSkybox :: proc() {
	rl.UnloadImage(sky_image)
	rl.UnloadModel(sky_model)
}