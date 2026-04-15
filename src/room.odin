package bg3d

import rl "vendor:raylib"
import "core:fmt"
import "core:os"
import "core:encoding/json"
import "core:math/rand"
import "core:strings"

Room :: struct {
	blocks: [dynamic]Block,
	triggers: [dynamic]Trigger,
	end_point: rl.Vector3
}

//MAIN_ROOMS :: 3
//rooms: [MAIN_ROOMS + 1]Room
start_room, end_room: Room
rooms: [dynamic]Room
global_end_point: rl.Vector3
global_room_number := int(0)
ROOM_DELAY :: 5

InitRooms :: proc() {
	start_room, end_room = ImportRoom("rooms/start.json"), ImportRoom("rooms/end.json")
	files, err := os.read_directory_by_path("rooms/", 0, context.allocator)
	if(err == nil) do for file in files do if(strings.starts_with(file.name, "room") && strings.ends_with(file.name, ".json")) { 
		append(&rooms, ImportRoom(concat({"rooms/", file.name})))
	}
}

ResetRooms :: proc() {
	global_end_point = {}
	global_room_number = 0
	ClearObjects()
	AppendRoom(start_room)
	for i in 1..<ROOM_DELAY do AppendRandomRoom(i)
}

AppendRoom :: proc(room: Room, room_number := int(0)) {
	for block in room.blocks do AppendBlock({block.pos + global_end_point, block.scale, room_number, block.name, block.force}, &objects)
	for trigger in room.triggers do AppendTrigger({trigger.pos + global_end_point, trigger.scale, room_number}, &objects)
	global_end_point += room.end_point
}

AppendRandomRoom :: proc(room_number := int(0)) {
	if(len(rooms) == 0) do panic("GAME: Found no rooms, exiting!")
	room := rand.int32_range(0, i32(len(rooms)))
	AppendRoom(rooms[room], room_number)
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