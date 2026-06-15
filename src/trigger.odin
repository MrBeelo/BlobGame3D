package bg3d

import rl "vendor:raylib"

UpdateTriggers :: proc(obj: ^Object) {
	if CheckCollisionCapsuleOBB(player.capsule, obj.box) do #partial switch(obj.special_prop) {
		case .ADVANCE_TRIGGER: if(global_room_number <= obj.room_number) do AdvanceRoom(obj.room_number)
		case .END_TRIGGER: if(IsInMainGame()) do BeginSaferoomStartSequence()
	}
}