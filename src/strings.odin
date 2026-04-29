package bg3d

import "core:strconv"

Parse :: proc(str: string, $T: typeid) -> T {
	when(T == int) { 
		val, vok := strconv.parse_int(str)
		return val if(vok) else 0
	} 
	else when(T == f32) { 
		val, vok := strconv.parse_f32(str)
		return val if(vok) else 0
	}
	else when(T == f64) { 
		val, vok := strconv.parse_f64(str)
		return val if(vok) else 0
	}
	else when(T == bool) { 
		val, vok := strconv.parse_bool(str)
		return val if(vok) else false
	}
	else when(T == string || T == cstring) do return str
}

ParseVector :: proc(args: []string, $vlen: int) -> [vlen]f32 {
	if(len(args) < vlen) do return {}, false
	vector: [vlen]f32
	vgok := true
	for i in 0..=vlen - 1 {
		vok: bool
		vector[i], vok = Parse(args[i], f32)
		if(!vok) do vgok = false
	}
	return vector if(vgok) else {}
}