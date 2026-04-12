package bg3d

import rl "vendor:raylib"
import "core:fmt"
import "core:os"
import "core:encoding/json"

Room :: struct {
	blocks: [dynamic]Block,
	triggers: [dynamic]Trigger,
	end_point: rl.Vector3
}

intro_room: Room
rooms: [2]Room
global_end_point: rl.Vector3
global_room_number := int(0)
ROOM_DELAY :: 5

InitRooms :: proc() {
	intro_room = ImportRoom("rooms/intro.json")
	rooms[0] = ImportRoom("rooms/roomstart.json")
	rooms[1] = ImportRoom("rooms/room1.json")
}

// To be replaced with a more complicated method that uses end points (when I add room generation)
AppendRoom :: proc(room: Room, room_number := int(0)) {
	for block in room.blocks do AppendBlock({block.pos + global_end_point, block.scale, room_number, block.name, block.force}, &objects)
	for trigger in room.triggers do AppendTrigger({trigger.pos + global_end_point, trigger.scale, room_number}, &objects)
	global_end_point += room.end_point
}

ImportRoom :: proc(path: string) -> Room {
	// BareRoom format definitions
	room: Room
	BareBlock :: struct{pos: rl.Vector3, scale: rl.Vector3}
	BareTrigger :: struct{pos: rl.Vector3, scale: rl.Vector3}
	BareRoom :: struct{bare_blocks: [dynamic]BareBlock, bare_triggers: [dynamic]BareTrigger, end_point: rl.Vector3}
	
	// Parsing the json
	data, err := os.read_entire_file(path, context.allocator)
	if(err != nil) {
		fmt.printf("GAME: OS read file error! (path: %s)\n", path)
		return Room{}
	}
	new_room: BareRoom
	unm_err := json.unmarshal(data, &new_room)
	if(unm_err != nil) {
		fmt.printf("GAME: Json unmarshal error! (path: %s)\n", path)
		return Room{}
	}
	
	// Translation from BareRoom to Room
	clear(&room.blocks)
	for block in new_room.bare_blocks do append(&room.blocks, NewBlock(block.pos, block.scale))
	for trigger in new_room.bare_triggers do append(&room.triggers, NewTrigger(trigger.pos, trigger.scale))
	room.end_point = new_room.end_point
	fmt.printf("GAME: Imported from %s\n", path)
	return room
}