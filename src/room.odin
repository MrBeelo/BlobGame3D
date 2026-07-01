package bg3d

import rl "vendor:raylib"
import "core:fmt"
import hlp "helper"
import "core:encoding/json"
import "core:math/rand"
import "core:strings"

Room :: struct {
	objects: [dynamic]Object,
	end_point: rl.Vector3,
	room_type: RoomType,
}

RoomType :: enum { START, MAIN, END, }
ROOM_DELAY :: 3
MAX_ROOMS :: 5

rooms: [dynamic]Room
global_end_point: rl.Vector3
global_room_number: int

InitRooms :: proc() {
	START_PATH :: "rooms"
	files := rl.LoadDirectoryFilesEx(START_PATH, ".json", false)
	for index in 0..<files.count { 
		path := string(files.paths[index])
		name, _ := strings.substring_from(path, len(START_PATH) + 1)
		if strings.starts_with(name, "start") do append(&rooms, ImportRoom(path, .START))
		if strings.starts_with(name, "main") do append(&rooms, ImportRoom(path, .MAIN))
		if strings.starts_with(name, "end") do append(&rooms, ImportRoom(path, .END))
	}
}

ResetRooms :: proc() {
	global_end_point = {}
	global_room_number = 0
	ClearObjects()
	AppendRandomRoom(0, .START)
	for i in 1..<ROOM_DELAY do AppendRandomRoom(i, .MAIN)
}

AdvanceRoom :: proc(room_number: int) {
	if room_number + ROOM_DELAY > MAX_ROOMS do return
	global_room_number += 1
	if room_number + ROOM_DELAY < MAX_ROOMS do AppendRandomRoom(room_number + ROOM_DELAY, .MAIN); else do AppendRandomRoom(room_number + ROOM_DELAY, .END)
	AddClockSeconds(0.2)
	run_stats.points += 3
	#reverse for obj, index in objects do if obj.room_number < global_room_number - ROOM_DELAY do ordered_remove(&objects, index)
}

AppendRoom :: proc(room: Room, room_number := int(0)) {
	for obj in room.objects {
		new_obj := obj
		new_obj.room_number = room_number
		new_obj.pos = obj.pos + global_end_point
		new_obj.box.center = obj.box.center + global_end_point
		append(&objects, new_obj)
	}
	global_end_point += room.end_point
}

GetRoomArray :: proc(type: RoomType) -> [dynamic]Room {
	new_rooms: [dynamic]Room
	for room in rooms do if room.room_type == type do append(&new_rooms, room)
	return new_rooms
}

AppendRandomRoom :: proc(room_number := int(0), type: RoomType) {
	type_rooms := GetRoomArray(type)
	if len(type_rooms) == 0 do panic("GAME: Found no rooms, exiting!")
	room := rand.int32_range(0, i32(len(type_rooms)))
	AppendRoom(type_rooms[room], room_number)
}

ImportRoom :: proc(path: string, type := RoomType.MAIN) -> Room {
	// JRoom format definitions
	room: Room
	JCube :: struct{pos: rl.Vector3, rot: rl.Vector3, size: rl.Vector3, type: enum{BLOCK, TRIGGER}}
	JRoom :: struct{jcubes: [dynamic]JCube, end_point: rl.Vector3}
	
	// Parsing the json
	data, ok := hlp.read_entire_file(path, context.allocator)
	if !ok {
		fmt.printf("GAME: OS read file error! (path: %s)\n", path)
		return Room{}
	}
	new_room: JRoom
	unm_err := json.unmarshal(data, &new_room)
	if unm_err != nil {
		fmt.printf("GAME: Json unmarshal error! (path: %s)\n", path)
		return Room{}
	}
	
	// Translation from JRoom to Room
	clear(&room.objects) // I have no idea why I did this, but I'm keeping it anyway!
	for cube in new_room.jcubes do switch cube.type {
		case .BLOCK: {
			block_objects := BlockToObjects(cube.pos, cube.rot, cube.size, 0)
			for block_obj in block_objects do append(&room.objects, block_obj)
		}
		case .TRIGGER: {
			trigger_prop := SpecialProperty.ADVANCE_TRIGGER if type == .START || type == .MAIN else SpecialProperty.END_TRIGGER
			append(&room.objects, NewCube(cube.pos, cube.rot, cube.size, .NONE, 0, {false, false, false}, trigger_prop))
		}
	}
	
	if type == .END do append(&room.objects, NewBlob(new_room.end_point, {}, 0.5, rotating = true))
	room.end_point = new_room.end_point
	room.room_type = type
	fmt.printf("GAME: Imported from %s\n", path)
	return room
}