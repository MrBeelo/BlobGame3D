package bg3d

import "core:math"
import rl "vendor:raylib"

OBB :: struct {
	center: rl.Vector3,
	axis: [3]rl.Vector3,
	half_size: rl.Vector3,
}

GetOBBCorners :: proc(box: OBB, offset := f32(0)) -> [8]rl.Vector3 {
	hx := box.axis.x * (box.half_size.x + offset)
    hy := box.axis.y * (box.half_size.y + offset)
    hz := box.axis.z * (box.half_size.z + offset)
    
	return [?]rl.Vector3{
		box.center - hx - hy - hz, box.center + hx - hy - hz,
		box.center + hx + hy - hz, box.center - hx + hy - hz,
		box.center - hx - hy + hz, box.center + hx - hy + hz,
		box.center + hx + hy + hz, box.center - hx + hy + hz,
	}
}

ProjectOBB :: proc(box: OBB, axis: rl.Vector3) -> rl.Vector2 {
    corners := GetOBBCorners(box)
    points: [8]f32
    for i in 0..=7 do points[i] = rl.Vector3DotProduct(axis, corners[i])
    return {array_min(points[:]), array_max(points[:])}
}

CheckOBBPointOverlap :: proc(points1, points2: rl.Vector2) -> bool { return points2.x <= points1.y && points1.x <= points2.y }

CheckCollisionOBB :: proc(box1, box2: OBB) -> bool {
	axes := [?]rl.Vector3 {
		box1.axis.x, box1.axis.y, box1.axis.z,
		box2.axis.x, box2.axis.y, box2.axis.z,
		rl.Vector3CrossProduct(box1.axis.x, box2.axis.x),
		rl.Vector3CrossProduct(box1.axis.x, box2.axis.y),
		rl.Vector3CrossProduct(box1.axis.x, box2.axis.z),
		rl.Vector3CrossProduct(box1.axis.y, box2.axis.x),
		rl.Vector3CrossProduct(box1.axis.y, box2.axis.y),
		rl.Vector3CrossProduct(box1.axis.y, box2.axis.z),
		rl.Vector3CrossProduct(box1.axis.z, box2.axis.x),
		rl.Vector3CrossProduct(box1.axis.z, box2.axis.y),
		rl.Vector3CrossProduct(box1.axis.z, box2.axis.z),
	}
	
	for axis in axes do if !CheckOBBPointOverlap(ProjectOBB(box1, axis), ProjectOBB(box2, axis)) do return false
	return true
}

CheckCollisionSphereOBB :: proc(sphere: Sphere, box: OBB) -> bool {
	rel := sphere.center - box.center

    local := rl.Vector3{rl.Vector3DotProduct(rel, box.axis[0]), rl.Vector3DotProduct(rel, box.axis[1]),
        rl.Vector3DotProduct(rel, box.axis[2])}

    closest := rl.Vector3{math.clamp(local.x, -box.half_size.x, box.half_size.x), math.clamp(local.y, -box.half_size.y, box.half_size.y),
        math.clamp(local.z, -box.half_size.z, box.half_size.z)}

    delta := local - closest
    return rl.Vector3DotProduct(delta, delta) <= sphere.radius * sphere.radius
}

CheckCollisionCapsuleOBB :: proc(capsule: Capsule, box: OBB) -> bool {
	for sphere in get_spheres(capsule) do if CheckCollisionSphereOBB(sphere, box) do return true
	return false
}

DrawOOBLines :: proc(box: OBB, offset := f32(0.01), color := rl.RED) {
	corners := GetOBBCorners(box, offset)
	rl.DrawLine3D(corners[0], corners[1], color)
	rl.DrawLine3D(corners[1], corners[2], color)
	rl.DrawLine3D(corners[2], corners[3], color)
	rl.DrawLine3D(corners[3], corners[0], color)
	rl.DrawLine3D(corners[4], corners[5], color)
	rl.DrawLine3D(corners[5], corners[6], color)
	rl.DrawLine3D(corners[6], corners[7], color)
	rl.DrawLine3D(corners[7], corners[4], color)
	rl.DrawLine3D(corners[0], corners[4], color)
	rl.DrawLine3D(corners[1], corners[5], color)
	rl.DrawLine3D(corners[2], corners[6], color)
	rl.DrawLine3D(corners[3], corners[7], color)
}

GetOBBFromBoundingBox :: proc(box: rl.BoundingBox) -> OBB {
	center := (box.max + box.min) / 2
	axes := [3]rl.Vector3{{1, 0, 0}, {0, 1, 0}, {0, 0, 1}}
	half_size := (box.max - box.min) / 2
	return {center, axes, half_size}
}