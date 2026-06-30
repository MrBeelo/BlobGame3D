package bg3d

import "core:math"
import rl "vendor:raylib"

Sphere :: struct{center: rl.Vector3, radius: f32}
Capsule :: struct{centers: [3]rl.Vector3, radius: f32}
MAX_INT :: int(math.max(i32))

get_spheres :: proc(capsule: Capsule) -> [3]Sphere {
	spheres: [3]Sphere
	for i in 0..=2 do spheres[i] = {capsule.centers[i], capsule.radius}
	return spheres
}

capsule_add :: proc(capsule: Capsule, vec: rl.Vector3) -> Capsule {
	new_capsule := capsule
	for i in 0..=2 do new_capsule.centers[i] += vec
	return new_capsule
}

array_min :: proc(arr: []$T) -> T {
	min := arr[0]
	for t in arr do if t < min do min = t
	return min
}

array_max :: proc(arr: []$T) -> T {
	max := arr[0]
	for t in arr do if t > max do max = t
	return max
}

rot_rad :: proc(v: rl.Vector3) -> rl.Vector3 { return {math.to_radians(v.x), math.to_radians(v.y), math.to_radians(v.z)} }
round_half :: proc(x: f32) -> f32 { return math.round(x * 2) / 2 }
round :: proc(x: f32, n: f32) -> f32 { return n * ((x + n / 2) / n) }
clamp_low :: proc(value: $T, low: T) -> T { if value < low do return low; return value }

djb2_hash :: proc(str: string, range: f32 = 100) -> f32 {
	hash: u32 = 5381
	for c in str do hash = ((hash << 5) + hash) + u32(c)
	return f32(hash) / f32(0xFFFFFFFF) * range // Returns a value in [0, range]
}