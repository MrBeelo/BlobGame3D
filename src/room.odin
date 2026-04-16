package bg3d

import rl "vendor:raylib"
import "core:fmt"
import "core:os"
import "core:encoding/json"
import "core:math/rand"
import "core:strings"

Room :: struct {
	objects: [dynamic]Object,
	end_point: rl.Vector3
}

RoomType :: enum { NORMAL, END }
ROOM_DELAY :: 5
MAX_ROOMS :: 10

start_room, end_room: Room
rooms: [dynamic]Room
global_end_point: rl.Vector3
global_room_number: int

InitRooms :: proc() {
	start_room, end_room = ImportRoom("rooms/start.json"), ImportRoom("rooms/end.json", .END)
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

AdvanceRoom :: proc(room_number: int) {
	if(room_number + ROOM_DELAY > MAX_ROOMS) do return
	global_room_number += 1
	if(room_number + ROOM_DELAY < MAX_ROOMS) do AppendRandomRoom(room_number + ROOM_DELAY); else do AppendRoom(end_room, room_number + ROOM_DELAY)
	AddClockSeconds(0.2)
	#reverse for obj, index in objects do if(obj.room_number < global_room_number - ROOM_DELAY) do ordered_remove(&objects, index)
}

AppendRoom :: proc(room: Room, room_number := int(0)) {
	for obj in room.objects {
		new_obj := obj
		new_obj.room_number = room_number
		new_obj.pos = obj.pos + global_end_point
		if(!new_obj.bad_object) do append(&objects, new_obj)
	}
	global_end_point += room.end_point
}

AppendRandomRoom :: proc(room_number := int(0)) {
	if(len(rooms) == 0) do panic("GAME: Found no rooms, exiting!")
	room := rand.int32_range(0, i32(len(rooms)))
	AppendRoom(rooms[room], room_number)
}

ImportRoom :: proc(path: string, type := RoomType.NORMAL) -> Room {
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
	clear(&room.objects) // I have no idea why I did this, but I'm keeping it anyway!
	for block in new_room.bare_blocks {
		block_objects := BlockToObjects(NewBlock(block.pos, block.scale))
		for block_obj in block_objects do append(&room.objects, block_obj)
	}
	for trigger in new_room.bare_triggers {
		trigger_name := "AdvanceTrigger" if(type == .NORMAL) else "EndTrigger"
		append(&room.objects, TriggerToObject(NewTrigger(trigger.pos, trigger.scale), trigger_name))
	}
	
	if(type == .END) do append(&room.objects, NewBlob(new_room.end_point, {}, 0.5, name = "RotatingBlob"))
	room.end_point = new_room.end_point
	fmt.printf("GAME: Imported from %s\n", path)
	return room
}