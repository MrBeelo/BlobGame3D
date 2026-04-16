package bg3d

import "core:fmt"
import "core:math"
import "core:strings"
import rl "vendor:raylib"

// Global Constants
SCREEN_SIZE :: rl.Vector2{1920, 1080}
VERSION :: "0.4.2"
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