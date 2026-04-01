package bb3d

import rl "vendor:raylib"

objects : [dynamic]Object

Object :: struct {
	model: rl.Model,
	pos: rl.Vector3,
	rot_axis: rl.Vector3,
	rot_angle: f32,
	scale: rl.Vector3,
	maps: [2]bool // Normal, Roughness
}

NewObject :: proc(model: rl.Model, pos: rl.Vector3, rot_axis: rl.Vector3 = {}, rot_angle: f32 = 0, 
	scale: rl.Vector3 = {1, 1, 1}, maps: [2]bool = {false, false}) -> Object {
	return Object{model, pos, rot_axis, rot_angle, scale, maps}
}

DrawObjects :: proc() {
	for &obj in (objects) do DrawObject(&obj)
}

DrawObject :: proc(self: ^Object) {
	AssignMaterialMaps(self.maps[0], self.maps[1])
	is_seen := FrustumContainsBox(GetCameraFrustum(&player), GetObjectBoundingBox(self^))
	if(is_seen) do rl.DrawModelEx(self.model, self.pos, self.rot_axis, self.rot_angle, self.scale, rl.WHITE)
	if(f3) do DrawBoundingBox(GetObjectBoundingBox(self^))
}

GetObjectBoundingBox :: proc(obj: Object) -> rl.BoundingBox {
	bbox := rl.GetModelBoundingBox(obj.model)
	bbox.min = bbox.min * obj.scale + obj.pos
    bbox.max = bbox.max * obj.scale + obj.pos
    return bbox
}

DrawBoundingBox :: proc(box: rl.BoundingBox) {
	center := (box.min + box.max) / 2
	size: rl.Vector3 = box.max - box.min
	rl.DrawCubeWiresV(center, size, rl.RED)
}