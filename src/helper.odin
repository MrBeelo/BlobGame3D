package bg3d

import "core:fmt"
import "core:math"
import "core:strings"
import "core:strconv"
import rl "vendor:raylib"

// Global Constants
SCREEN_SIZE :: rl.Vector2{1920, 1080}
VERSION :: "0.4.3"
MAX_NUM :: 2_147_483_647

// Global Variables
should_exit := false
game_texture: rl.RenderTexture2D
colored_game_texture: rl.RenderTexture2D

// Helper Enums
MatrixRotationOrder :: enum{ XYZ, XZY, YXZ, YZX, ZXY, ZYX }
TextureType :: enum{ DIFFUSE, NORMAL, ROUGH, HEIGHT }

// Functions
print :: fmt.printf
formatc :: fmt.ctprintf
sin :: math.sin
cos :: math.cos
clamp :: math.clamp
abs :: math.abs
floor :: math.floor
sqrt :: math.sqrt
concat :: strings.concatenate
to_cstr :: strings.clone_to_cstring
rad :: math.to_radians
format :: proc(fmt: string, args: ..any) -> string { return string(formatc(fmt, ..args)) }
to_string :: proc(value: any) -> string { return format("%v", value) }
round :: proc(x: f32, n: f32) -> f32 { return n * ((x + n / 2) / n) }
contains :: proc(arr: []$T, x: T) -> bool { for y in (arr) do if (y == x) { return true }; return false }
clamp_low :: proc(value: $T, low: T) -> T { if(value < low) do return low; return value }
string_pop :: proc(str: string) -> string { text, err := strings.substring(cmd_text, 0, strings.rune_count(cmd_text) - 1); return text }
djb2_hash :: proc(str: string, range: f32 = 100) -> f32 {
	hash: u32 = 5381
	for c in str do hash = ((hash << 5) + hash) + u32(c)
	return f32(hash) / f32(0xFFFFFFFF) * range // Returns a value in [0, range]
}

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

Interval :: proc(mod: f32) -> f32 {
	t := f32(rl.GetTime()) / (1 / mod)
	return t - floor(t)
}

FloatToTimeStr :: proc(value: f32, miliseconds := false, use_x := true) -> string {
	mins := int(floor(value / 60))
	secs := int(floor(value)) % 60
	mils := int(floor(value - floor(value) * 1000))
	mins = clamp_low(mins, 0)
	secs = clamp_low(secs, 0)
	mils = clamp_low(mils, 0)
	str := string(rl.TextFormat("%2d:%02d.%d", mins, secs, mils)) if(miliseconds) else string(rl.TextFormat("%2d:%02d", mins, secs))
	if(use_x) do str = "XX:XX.XXX" if(miliseconds) else "XX:XX"
	return str
}