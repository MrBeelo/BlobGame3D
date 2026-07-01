package bg3d

import hlp "helper"
import rl "vendor:raylib"

objects, near_objects: [dynamic]Object

ObjectProperties :: struct {
	collidable: bool,
	force_draw: bool,
	should_draw: bool,
}

SpecialProperty :: enum {
	NONE,
	ROTATING_BLOB,
	ADVANCE_TRIGGER,
	END_TRIGGER,
	UI_FLASHLIGHT,
}

Object :: struct {
	pos: rl.Vector3,
	rot: rl.Vector3,
	scale: rl.Vector3,
	model: Maybe(rl.Model),
	box: OBB,
	rotation_order: MatrixRotationOrder,
	props: ObjectProperties,
	shader_types: []MaterialShaderType,
	special_prop: SpecialProperty,
	room_number: int,
}
	
NewObject :: proc(pos: rl.Vector3, rot: rl.Vector3 = {}, scale: rl.Vector3 = {1, 1, 1}, 
model: Maybe(rl.Model) = nil, box := OBB{}, rotation_order := MatrixRotationOrder.XYZ, 
props := ObjectProperties{true, false, true}, shader_types: []MaterialShaderType = {}, 
special_prop := SpecialProperty.NONE, room_number := int(0)) -> Object {
	copied_shader_types := make([]MaterialShaderType, len(shader_types))
    for i in 0..<len(shader_types) do copied_shader_types[i] = shader_types[i]
	return Object{pos, rot, scale, model, box, rotation_order, 
		props, copied_shader_types, special_prop, room_number}
}

UpdateObjects :: proc(objs: [dynamic]Object = objects) {
	for &obj in (objs) do UpdateObject(&obj)
}

DrawObjects :: proc(frustum: Frustum, objs: [dynamic]Object = objects) {
	for &obj in (objs) do DrawObject(&obj, frustum)
}

UpdateObject :: proc(self: ^Object) {
	#partial switch self.special_prop {
	case .ROTATING_BLOB: UpdateRotatingBlob(self)
	case .UI_FLASHLIGHT: UpdateFlashlight(self)
	case .ADVANCE_TRIGGER, .END_TRIGGER: UpdateTriggers(self)
	}
}

DrawObject :: proc(self: ^Object, frustum: Frustum) {
	if !self.props.should_draw || self.model == nil do return
	AssignMaterialMaps(self.shader_types)
	if self.props.should_draw do DrawModelPro(&self.model.?, self.pos, hlp.rot_rad(self.rot), self.scale, rl.WHITE, self.rotation_order)
	if debug_on do DrawOOBLines(self.box)
}

ClearObjects :: proc() {
	#reverse for obj, index in objects {
		if obj.special_prop != .UI_FLASHLIGHT do ordered_remove(&objects, index)
	}
}

GetObjectBoundingBox :: proc(obj: Object) -> rl.BoundingBox {
	if obj.model == nil do return {}
	box := rl.GetModelBoundingBox(obj.model.?)
	box.min = box.min * obj.scale + obj.pos
    box.max = box.max * obj.scale + obj.pos
    return box
}

GetObjectOBB :: proc(obj: Object) -> OBB {
	box := GetObjectBoundingBox(obj)
	return GetOBBFromBoundingBox(box)
}