package bg3d

import rl "vendor:raylib"

TOP_PART_HEIGHT :: 0.1

// ! TODO
BlockToObjects :: proc(pos: rl.Vector3, rot: rl.Vector3, size: rl.Vector3, room_number := int(0)) -> [2]Object {
	if(size.y > TOP_PART_HEIGHT) {
		bottom_part_y_size := size.y - TOP_PART_HEIGHT
		down_y_pos := pos.y - size.y / 2
		bottom_part_y_center := down_y_pos + bottom_part_y_size / 2
		top_part_y_center := down_y_pos + bottom_part_y_size + TOP_PART_HEIGHT / 2
		
		bottom_part_pos := rl.Vector3{pos.x, bottom_part_y_center, pos.z}
		top_part_pos := rl.Vector3{pos.x, top_part_y_center, pos.z}
		bottom_part_size := rl.Vector3{size.x, bottom_part_y_size, size.z}
		top_part_size := rl.Vector3{size.x, TOP_PART_HEIGHT, size.z}
		
		bottom_part := NewCube(bottom_part_pos, rot, bottom_part_size, .WALL, room_number)
		top_part := NewCube(top_part_pos, rot, top_part_size, .FLOOR, room_number)
		
		return {bottom_part, top_part}
	}
	
	return {{}, NewCube(pos, rot, size, .FLOOR, room_number)}
}