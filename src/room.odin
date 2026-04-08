package bb3d

import rl "vendor:raylib"

Room :: struct {
	start_point: rl.Vector3,
	end_point: rl.Vector3,
	blocks: [dynamic][2]Object
}

start_room: Room

InitRooms :: proc() {
	start_room = Room{{}, {10, 10, 10}, {}}
	append(&start_room.blocks, NewBlock({-5.5, 2.5, 0}, {1, 5, 5}))
	append(&start_room.blocks, NewBlock({0, 2.5, 2}, {10, 5, 1}))
	append(&start_room.blocks, NewBlock({0, 2.5, -2}, {10, 5, 1}))
}

AppendRoom :: proc(room: Room) {
	for block in room.blocks {
		append(&objects, block.x)
		append(&objects, block.y)
	}
}