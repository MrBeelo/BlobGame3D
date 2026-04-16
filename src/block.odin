package bg3d

import rl "vendor:raylib"

TOP_PART_HEIGHT :: 0.1

Block :: struct {
	pos: rl.Vector3,
	scale: rl.Vector3,
	room_number: int,
	name: string
}

NewBlock :: proc(pos: rl.Vector3, scale: rl.Vector3, room_number := int(0), name := "Block") -> Block {
	return Block{pos, scale, room_number, name}
}

BlockToObjects :: proc(block: Block) -> [2]Object {
	if(block.scale.y > TOP_PART_HEIGHT) {
		bottom_part_y_size := block.scale.y - TOP_PART_HEIGHT
		down_y_pos := block.pos.y - block.scale.y / 2
		bottom_part_y_center := down_y_pos + bottom_part_y_size / 2
		top_part_y_center := down_y_pos + bottom_part_y_size + TOP_PART_HEIGHT / 2
		
		bottom_part_pos := rl.Vector3{block.pos.x, bottom_part_y_center, block.pos.z}
		top_part_pos := rl.Vector3{block.pos.x, top_part_y_center, block.pos.z}
		bottom_part_size := rl.Vector3{block.scale.x, bottom_part_y_size, block.scale.z}
		top_part_size := rl.Vector3{block.scale.x, TOP_PART_HEIGHT, block.scale.z}
		
		bottom_part := NewWall(bottom_part_pos, bottom_part_size, block.room_number, concat({block.name, "Bottom"}))
		top_part := NewFloor(top_part_pos, top_part_size, block.room_number, concat({block.name, "Top"}))
		
		return {bottom_part, top_part}
	}
	
	return {NewBadObject(), NewFloor(block.pos, block.scale, block.room_number, concat({block.name, "Top"}))}
}