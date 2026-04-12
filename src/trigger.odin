package bg3d

import rl "vendor:raylib"

trigger_model: rl.Model

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

LoadTriggers :: proc() {
	trigger_mesh := rl.GenMeshCube(0.25, 1, 0.75)
	trigger_model = rl.LoadModelFromMesh(trigger_mesh)
}

UnloadTriggers :: proc() {
	rl.UnloadModel(trigger_model)
}

NewTrigger :: proc(pos: rl.Vector3, scale: rl.Vector3 = {1, 1, 1}, room_number := int(0)) -> Trigger {
	return Trigger{pos, scale, room_number}
}

TriggerToObject :: proc(trigger: Trigger) -> Object {
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