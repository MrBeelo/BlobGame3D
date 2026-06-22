// Frustum header by SuperUserNameMan, translated to Odin and expanded by MrBeelo

package bg3d

import rl "vendor:raylib"

BOX_NO_CORNER :: 0
BOX_FRONT_BOTTOM_LEFT :: 1
BOX_FRONT_BOTTOM_RIGHT :: 2
BOX_FRONT_TOP_LEFT :: 4
BOX_FRONT_TOP_RIGHT :: 8
BOX_BACK_BOTTOM_LEFT :: 16
BOX_BACK_BOTTOM_RIGHT :: 32
BOX_BACK_TOP_LEFT :: 64
BOX_BACK_TOP_RIGHT :: 128
BOX_ALL_CORNERS :: 255

Frustum :: struct {
	up: rl.Vector4,
	down: rl.Vector4,
	left: rl.Vector4,
	right: rl.Vector4,
	near: rl.Vector4,
	far: rl.Vector4
}

GetFrustumFromCamera :: proc(camera: ^rl.Camera, aspect: f32) -> Frustum {
	frustum: Frustum;
	view: rl.Matrix = rl.GetCameraViewMatrix(camera)
	proj: rl.Matrix = rl.GetCameraProjectionMatrix(camera, aspect)
	clip: rl.Matrix = proj * view
	
	frustum.left = Vector4Normalize({clip[3,0] + clip[0,0], clip[3,1] + clip[0,1], clip[3,2] + clip[0,2], clip[3,3] + clip[0,3]});
	frustum.right = Vector4Normalize({clip[3,0] - clip[0,0], clip[3,1] - clip[0,1], clip[3,2] - clip[0,2], clip[3,3] - clip[0,3]});
	frustum.down = Vector4Normalize({clip[3,0] + clip[1,0], clip[3,1] + clip[1,1], clip[3,2] + clip[1,2], clip[3,3] + clip[1,3]});
	frustum.up = Vector4Normalize({clip[3,0] - clip[1,0], clip[3,1] - clip[1,1], clip[3,2] - clip[1,2], clip[3,3] - clip[1,3]});
	frustum.near = Vector4Normalize({clip[3,0] + clip[2,0], clip[3,1] + clip[2,1], clip[3,2] + clip[2,2], clip[3,3] + clip[2,3]});
	frustum.far = Vector4Normalize({clip[3,0] - clip[2,0], clip[3,1] - clip[2,1], clip[3,2] - clip[2,2], clip[3,3] - clip[2,3]});
	
	return frustum
}

Vector4Normalize :: proc(v: rl.Vector4) -> rl.Vector4 {
	result := v
	len: f32 = sqrt(v.x * v.x + v.y * v.y + v.z * v.z + v.w + v.w)
	if(len != 0) {
		ilen := 1 / len
		result *= ilen
	}
	return result
}

CheckCollisionPlanePoint :: proc(plane: rl.Vector4, point: rl.Vector3) -> bool {
	d := point.x * plane.x + point.y * plane.y + point.z * plane.z + plane.w 
	e := sqrt(plane.x * plane.x + plane.y * plane.y + plane.z * plane.z)
	distance := d / e
	return distance <= 0
}

CheckCollisionPlaneOBBEx :: proc(plane: rl.Vector4, box: OBB) -> int {
	corners := BOX_NO_CORNER
	points := GetOBBCorners(box)
	for i in 0..=7 do if CheckCollisionPlanePoint(plane, points[i]) do corners |= 1 << uint(i)
	return corners
}

CheckCollisionPlaneOBBPointsEx :: proc(plane: rl.Vector4, points: [8]rl.Vector3) -> int {
	corners := BOX_NO_CORNER
	for i in 0..=7 do if CheckCollisionPlanePoint(plane, points[i]) do corners |= 1 << uint(i)
	return corners
}

FrustumContainsOBB :: proc(frustum: Frustum, box: OBB) -> bool {
	points := GetOBBCorners(box)
	planes := [6]rl.Vector4{frustum.up, frustum.down, frustum.left, frustum.right, frustum.near, frustum.far}
	/*if(CheckCollisionPlaneOBBPointsEx(frustum.up, points) == BOX_ALL_CORNERS) do return false
	if(CheckCollisionPlaneOBBPointsEx(frustum.down, points) == BOX_ALL_CORNERS) do return false
	if(CheckCollisionPlaneOBBPointsEx(frustum.left, points) == BOX_ALL_CORNERS) do return false
	if(CheckCollisionPlaneOBBPointsEx(frustum.right, points) == BOX_ALL_CORNERS) do return false
	if(CheckCollisionPlaneOBBPointsEx(frustum.near, points) == BOX_ALL_CORNERS) do return false
	if(CheckCollisionPlaneOBBPointsEx(frustum.far, points) == BOX_ALL_CORNERS) do return false*/
	for plane in planes do if CheckCollisionPlaneOBBPointsEx(plane, points) == BOX_ALL_CORNERS do return false

	return true
}

GetRayCollisionOBB :: proc(ray: rl.Ray, box: OBB) -> rl.RayCollision {
	delta := ray.position - box.center
	local_pos := rl.Vector3{rl.Vector3DotProduct(delta, box.axis[0]), rl.Vector3DotProduct(delta, box.axis[1]), 
		rl.Vector3DotProduct(delta, box.axis[2])}
	local_dir := rl.Vector3{rl.Vector3DotProduct(ray.direction, box.axis[0]), rl.Vector3DotProduct(ray.direction, box.axis[1]),
        rl.Vector3DotProduct(ray.direction, box.axis[2])}
	
    local_ray := rl.Ray{local_pos, local_dir}
    local_box := rl.BoundingBox{-box.half_size, box.half_size};
    hit := rl.GetRayCollisionBox(local_ray, local_box);
    
    if (!hit.hit) do return hit;
    
    hit.point = box.center + box.axis[0] * hit.point.x + box.axis[1] * hit.point.y + box.axis[2] * hit.point.z
    hit.normal = rl.Vector3Normalize(box.axis[0] * hit.normal.x + box.axis[1] * hit.normal.y + box.axis[2] * hit.normal.z)
    return hit;
}

GetMaxDistInFrontOfCameraOBB :: proc(max: f32) -> f32 {
	closest_dist: f32 = max
	ray := rl.GetScreenToWorldRay({SCREEN_SIZE.x / 2, SCREEN_SIZE.y / 2}, player.camera)
	hit := false
	
	for obj in (objects) {
		if(!obj.props.collidable) do continue
		coll := GetRayCollisionOBB(ray, obj.box)
		if(coll.hit && coll.distance < closest_dist) {
			closest_dist = coll.distance
			hit = true
		}
	}
	
	return closest_dist if hit else max
}

// UNUSED BUT PROBABLY USEFUL

CheckCollisionPlaneBoxEx :: proc(plane: rl.Vector4, box: rl.BoundingBox) -> int {
	corners := BOX_NO_CORNER
	
	if(CheckCollisionPlanePoint(plane, box.min)) do corners |= BOX_FRONT_BOTTOM_LEFT
	if(CheckCollisionPlanePoint(plane, box.max)) do corners |= BOX_BACK_TOP_RIGHT
	if(CheckCollisionPlanePoint(plane, {box.min.x, box.max.y, box.min.z})) do corners |= BOX_FRONT_TOP_LEFT
	if(CheckCollisionPlanePoint(plane, {box.max.x, box.max.y, box.min.z})) do corners |= BOX_FRONT_TOP_RIGHT
	if(CheckCollisionPlanePoint(plane, {box.max.x, box.min.y, box.min.z})) do corners |= BOX_FRONT_BOTTOM_RIGHT
	if(CheckCollisionPlanePoint(plane, {box.min.x, box.min.y, box.max.z})) do corners |= BOX_BACK_BOTTOM_LEFT
	if(CheckCollisionPlanePoint(plane, {box.min.x, box.max.y, box.max.z})) do corners |= BOX_BACK_TOP_LEFT
	if(CheckCollisionPlanePoint(plane, {box.max.x, box.min.y, box.max.z})) do corners |= BOX_BACK_BOTTOM_RIGHT
	
	return corners
}

FrustumContainsBox :: proc(frustum: Frustum, box: rl.BoundingBox) -> bool {
	if(CheckCollisionPlaneBoxEx(frustum.up, box) == BOX_ALL_CORNERS) do return false ;
	if(CheckCollisionPlaneBoxEx(frustum.down, box) == BOX_ALL_CORNERS) do return false ;
	if(CheckCollisionPlaneBoxEx(frustum.left, box) == BOX_ALL_CORNERS) do return false ;
	if(CheckCollisionPlaneBoxEx(frustum.right, box) == BOX_ALL_CORNERS) do return false ;
	if(CheckCollisionPlaneBoxEx(frustum.near, box) == BOX_ALL_CORNERS) do return false ;
	if(CheckCollisionPlaneBoxEx(frustum.far, box) == BOX_ALL_CORNERS) do return false ;

	return true;
}

GetMaxDistInFrontOfCameraBBox :: proc(max: f32) -> f32 {
	closest_dist: f32 = max
	ray := rl.GetScreenToWorldRay({SCREEN_SIZE.x / 2, SCREEN_SIZE.y / 2}, player.camera)
	hit := false
	
	for obj in (objects) {
		if(!obj.props.collidable) do continue
		box := GetObjectBoundingBox(obj)
		coll := rl.GetRayCollisionBox(ray, box)
		if(coll.hit && coll.distance < closest_dist) {
			closest_dist = coll.distance
			hit = true
		}
	}
	
	return closest_dist if hit else max
}