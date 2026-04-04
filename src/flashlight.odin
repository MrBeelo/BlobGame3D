package bb3d

import rl "vendor:raylib"

flashlight_model: rl.Model

LoadFlashlight :: proc() {
	flashlight_model = rl.LoadModel("res/models/flashlight.glb")
	AssignShader(&flashlight_model, material_shader)
}

NewFlashlight :: proc(pos: rl.Vector3, rot: rl.Vector3 = {}, scale: rl.Vector3 = {1, 1, 1}) -> Object {
	return NewObject(flashlight_model, pos, rot, 0.035 * scale, {}, false, "Flashlight", .YXZ)
}

AppendFlashlight :: proc() {
	append(&objects, NewFlashlight(player.pos))
}

UpdateFlashlight :: proc(obj: ^Object) {
	if(obj.name != "Flashlight") do return
	obj.pos = GetPosInFrontOfCamera({0.15 + GetRotationChange().x / 5, -0.1, 0.35})
	obj.rot = GetCameraRotation()
}

UnloadFlashlight :: proc() {
	rl.UnloadModel(flashlight_model)
}