package bg3d

import rl "vendor:raylib"

Trigger :: struct {
	pos: rl.Vector3,
	scale: rl.Vector3,
	room_number: int,
}

NewTrigger :: proc(pos: rl.Vector3, scale: rl.Vector3 = {1, 1, 1}, room_number := int(0)) -> Trigger {
	return Trigger{pos, scale, room_number}
}

TriggerToObject :: proc(trigger: Trigger, trigger_name := "AdvanceTrigger") -> Object {
	trigger_model: rl.Model
	if model, ok := cube_model_cache[trigger.scale]; ok do trigger_model = model; else do trigger_model = GetCubeModel(trigger.scale)
	return NewObject(trigger_model, trigger.pos, {}, trigger.scale, {}, false, trigger_name, room_number = trigger.room_number, should_draw = false)
}

UpdateTriggers :: proc(obj: ^Object) {
	if(rl.CheckCollisionBoxes(GetPlayerBoundingBox(&player), GetObjectBoundingBox(obj^))) do switch(obj.name) {
		case "AdvanceTrigger": if(global_room_number <= obj.room_number) do AdvanceRoom(obj.room_number)
		case "EndTrigger": if(IsInMainGame()) do BeginSaferoomStartSequence()
	}
}