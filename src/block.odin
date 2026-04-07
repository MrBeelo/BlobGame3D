package bb3d

import rl "vendor:raylib"

TOP_PART_HEIGHT :: 0.1

NewBlock :: proc(pos: rl.Vector3, size := rl.Vector3{1, 1, 1}, name := "Block", force := false) -> (Object, Object) {
	if(size.y > TOP_PART_HEIGHT) {
		bottom_part_y_size := size.y - TOP_PART_HEIGHT
		down_y_pos := pos.y - size.y / 2
		bottom_part_y_center := down_y_pos + bottom_part_y_size / 2
		top_part_y_center := down_y_pos + bottom_part_y_size + TOP_PART_HEIGHT / 2
		
		bottom_part_pos := rl.Vector3{pos.x, bottom_part_y_center, pos.z}
		top_part_pos := rl.Vector3{pos.x, top_part_y_center, pos.z}
		bottom_part_size := rl.Vector3{size.x, bottom_part_y_size, size.z}
		top_part_size := rl.Vector3{size.x, TOP_PART_HEIGHT, size.z}
		
		bottom_part := NewWall(bottom_part_pos, bottom_part_size, concat({name, "Bottom"}), force)
		top_part := NewFloor(top_part_pos, top_part_size, concat({name, "Top"}), force)
		
		return bottom_part, top_part
	}
	
	return NewBadObject(), NewFloor(pos, size, concat({name, "Top"}), force)
}

AppendNewBlock :: proc(pos: rl.Vector3, size := rl.Vector3{1, 1, 1}, name := "Block", force := false, objs: ^[dynamic]Object) {
	block_bottom, block_top := NewBlock(pos, size, name, force)
	if(!block_bottom.bad_object) do append(objs, block_bottom)
	if(!block_top.bad_object) do append(objs, block_top)
}