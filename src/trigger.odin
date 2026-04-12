package bg3d

import rl "vendor:raylib"

trigger_model_cache: map[rl.Vector3]rl.Model

Trigger :: struct {
	pos: rl.Vector3,
	scale: rl.Vector3,
	room_number: int,
}

// # WARNING: PLEASE READ
// # I've temporarily made it so that triggers use one model (trigger_model)
// # This might change in the future, so please make a cache system like ya did with the others!
// # Otherwise collision stuff might break, I don't want that!
// # You can clearly see the hitbox that's always used in the F3 mode!

NewTrigger :: proc(pos: rl.Vector3, scale: rl.Vector3 = {1, 1, 1}, room_number := int(0)) -> Trigger {
	return Trigger{pos, scale, room_number}
}

LoadTriggerModel :: proc(scale: rl.Vector3 = {1, 1, 1}) -> rl.Model {
	trigger_mesh := GenCustomMeshCube(scale.x, scale.y, scale.z)
	trigger_model := rl.LoadModelFromMesh(trigger_mesh)
	trigger_model_cache[scale] = trigger_model
	return trigger_model
}

TriggerToObject :: proc(trigger: Trigger) -> Object {
	trigger_model: rl.Model
	if model, ok := wall_model_cache[trigger.scale]; ok do trigger_model = model; else do trigger_model = LoadWallModel(trigger.scale)
	return NewObject(trigger_model, trigger.pos, {}, trigger.scale, {}, false, "Trigger", room_number = trigger.room_number, should_draw = false)
}

AppendTrigger :: proc(trigger: Trigger, objs: ^[dynamic]Object) {
	append(objs, TriggerToObject(trigger))
}

UpdateTriggers :: proc(obj: ^Object) {
	if(obj.name != "Trigger") do return
	if(rl.CheckCollisionBoxes(GetPlayerBoundingBox(&player), GetObjectBoundingBox(obj^)) && global_room_number <= obj.room_number) {
		global_room_number += 1
		AppendRoom(rooms[1], obj.room_number + ROOM_DELAY) // To Change (add support for more / random rooms)
		#reverse for obj, index in objects do if(obj.room_number < global_room_number - ROOM_DELAY) do ordered_remove(&objects, index)
	}
}