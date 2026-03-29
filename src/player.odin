package bb3d

import "core:math"
import rl "vendor:raylib"

Player :: struct {
	pos: rl.Vector3,
	vel: rl.Vector3,
	rot: rl.Vector2, //yaw, pitch
	dir: rl.Vector3,
	size: rl.Vector3,
	fov: f32,
	camera: rl.Camera3D,
	sensitivity: f32,
	speed: f32,
	sprinting: bool
}

NewPlayer :: proc() -> Player {
	init_pos :: rl.Vector3{0, 0.5, 0}
	init_fov :: 70
	camera := rl.Camera3D{init_pos, {1, 0.5, 1}, {0, 1, 0}, init_fov, .PERSPECTIVE}
	return Player{init_pos, {}, {}, {1, 0, 1}, {0.3, 0.5, 0.3}, init_fov, camera, 0.0025, 3, false}
}

UpdatePlayer :: proc(self: ^Player) {
	frame_time := rl.GetFrameTime()
	mouse_delta := rl.GetMouseDelta()
	rot_clamp := math.to_radians_f32(90)
	diag_speed_mult := 1 / math.sqrt_f32(2)
	gravity :: -0.5
	jump_vel :: 20
	speeds :: rl.Vector2{2.5, 6.5} //base, sprint
	fovs :: rl.Vector2{70, 60} //base, sprint
	
	speed := frame_time * self.speed
	self.rot.x -= mouse_delta.x * self.sensitivity
	self.rot.y = clamp(self.rot.y - mouse_delta.y * self.sensitivity, -rot_clamp, rot_clamp)
	
	self.dir.x = cos(self.rot.y) * sin(self.rot.x)
    self.dir.y = sin(self.rot.y)
    self.dir.z = cos(self.rot.y) * cos(self.rot.x)
    
    forward := f32(int(rl.IsKeyDown(.W)) - int(rl.IsKeyDown(.S)))
    sideward := f32(int(rl.IsKeyDown(.D)) - int(rl.IsKeyDown(.A)))
    
    if(forward != 0 && sideward != 0) do speed *= diag_speed_mult
    
    nx, nz := self.pos.x, self.pos.z
    nx += speed * (sin(self.rot.x) * forward - cos(self.rot.x) * sideward);
    nz += speed * (cos(self.rot.x) * forward + sin(self.rot.x) * sideward);
    self.pos.x, self.pos.z = nx, nz
    
    if(rl.IsKeyPressed(.SPACE)) do self.vel.y = jump_vel
    
    self.pos.x += self.vel.x * frame_time * 1 / 2
    self.pos.y += self.vel.y * frame_time * 1 / 2
    self.pos.z += self.vel.z * frame_time * 1 / 2
    
    self.vel.y += gravity
    self.pos.y = clamp(self.pos.y, 0 + self.size.y, 999999)
    
    self.sprinting = rl.IsKeyDown(.LEFT_SHIFT)
    
    if(self.sprinting) {
    	if(self.speed < speeds.y) do self.speed += frame_time * 10
     	if(self.fov > fovs.y) do self.fov -= frame_time * 50
    } else {
    	if(self.speed > speeds.x) do self.speed -= frame_time * 10
   		if(self.fov < fovs.x) do self.fov += frame_time * 50
    }
    
    self.speed = clamp(self.speed, speeds.x, speeds.y)
    self.fov = clamp(self.fov, fovs.y, fovs.x) //normal FOV is bigger than sprinting one.
    
    self.camera.position = self.pos
	self.camera.target = self.pos + self.dir
	self.camera.fovy = self.fov
}