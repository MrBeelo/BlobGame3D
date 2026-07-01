package bg3d

import hlp "helper"
import rl "vendor:raylib"

flashlight_model: rl.Model

LoadFlashlight :: proc() {
	flashlight_model = LoadModel("flashlight.glb")
	AssignShader(&flashlight_model, material_shader)
}

NewFlashlight :: proc(pos: rl.Vector3, rot: rl.Vector3 = {}, scale: rl.Vector3 = {1, 1, 1}, name := "Flashlight") -> Object {
	return NewObject(pos, rot, 0.035 * scale, flashlight_model, rotation_order = .YXZ, props = {false, true, true},
		special_prop = .UI_FLASHLIGHT, room_number = hlp.MAX_INT)
}

AppendUIFlashlight :: proc() {
	append(&objects, NewFlashlight(player.pos, name = "UIFlashlight"))
}

UpdateFlashlight :: proc(obj: ^Object) {
	obj.pos = GetPosInFrontOfCamera({0.15 + GetRotationChange().x / 5, -0.1, 0.35})
	obj.rot = GetCameraRotation()
}

UnloadFlashlight :: proc() {
	rl.UnloadModel(flashlight_model)
}