package bb3d

import rl "vendor:raylib"

//! Original Frustum header by SuperUserNameMan.

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

CameraGetFrustum :: proc(camera: ^rl.Camera, aspect: f32) -> Frustum {
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