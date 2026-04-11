package bg3d

import rl "vendor:raylib"
import "core:fmt"
import "core:os"
import "core:encoding/json"

Room :: struct {
	blocks: [dynamic]Block,
	end_point: rl.Vector3
}

intro_room: Room

InitRooms :: proc() {
	intro_room = ImportRoom("rooms/intro.json")
}

// To be replaced with a more complicated method that uses end points (when I add room generation)
AppendRoom :: proc(room: Room) {
	for block in room.blocks do AppendBlock(block, &objects)
}

ImportRoom :: proc(path: string) -> Room {
	// BareRoom format definitions
	room: Room
	BareBlock :: struct{pos: rl.Vector3, scale: rl.Vector3}
	BareRoom :: struct{bare_blocks: [dynamic]BareBlock, end_point: rl.Vector3}
	
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
	room.end_point = new_room.end_point
	fmt.printf("GAME: Imported from %s\n", path)
	return room
}