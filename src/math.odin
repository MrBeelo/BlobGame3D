package bg3d

import "core:math"

Sphere :: struct{center: [3]f32, radius: f32}
Capsule :: struct{centers: [3][3]f32, radius: f32}

get_spheres :: proc(capsule: Capsule) -> [3]Sphere {
	spheres: [3]Sphere
	for i in 0..=2 do spheres[i] = {capsule.centers[i], capsule.radius}
	return spheres
}

capsule_add :: proc(capsule: Capsule, vec: [3]f32) -> Capsule {
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

rot_rad :: proc(v: [3]f32) -> [3]f32 {
	return {math.to_radians(v.x), math.to_radians(v.y), math.to_radians(v.z)}
}

round_half :: proc(x: f32) -> f32 {
	return math.round(x * 2) / 2
}