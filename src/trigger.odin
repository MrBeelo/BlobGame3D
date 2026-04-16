package bg3d

import rl "vendor:raylib"

trigger_model_cache: map[rl.Vector3]rl.Model

Trigger :: struct {
	pos: rl.Vector3,
	scale: rl.Vector3,
	room_number: int,
}

NewTrigger :: proc(pos: rl.Vector3, scale: rl.Vector3 = {1, 1, 1}, room_number := int(0)) -> Trigger {
	return Trigger{pos, scale, room_number}
}

LoadTriggerModel :: proc(scale: rl.Vector3 = {1, 1, 1}) -> rl.Model {
	trigger_mesh := GenCustomMeshCube(scale.x, scale.y, scale.z)
	trigger_model := rl.LoadModelFromMesh(trigger_mesh)
	trigger_model_cache[scale] = trigger_model
	return trigger_model
}

TriggerToObject :: proc(trigger: Trigger, trigger_name := "AdvanceTrigger") -> Object {
	trigger_model: rl.Model
	if model, ok := wall_model_cache[trigger.scale]; ok do trigger_model = model; else do trigger_model = LoadWallModel(trigger.scale)
	return NewObject(trigger_model, trigger.pos, {}, trigger.scale, {}, false, trigger_name, room_number = trigger.room_number, should_draw = false)
}

UpdateTriggers :: proc(obj: ^Object) {
	if(rl.CheckCollisionBoxes(GetPlayerBoundingBox(&player), GetObjectBoundingBox(obj^))) do switch(obj.name) {
		case "AdvanceTrigger": if(global_room_number <= obj.room_number) do AdvanceRoom(obj.room_number)
		case "EndTrigger": BeginDeathSequence() // # TO CHANGE (obviously)
	}
}