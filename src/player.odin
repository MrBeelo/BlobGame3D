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
	speed: f32,
}

NewPlayer :: proc() -> Player {
	INIT_POS :: rl.Vector3{0, 0.5, 0}
	INIT_FOV :: 60
	camera := rl.Camera3D{INIT_POS, {1, 0.5, 1}, {0, 1, 0}, INIT_FOV, .PERSPECTIVE}
	return Player{INIT_POS, {}, {}, {1, 0, 1}, {0.3, 0.5, 0.3}, INIT_FOV, camera, 3}
}

// Helper Functions
IsPlayerOnGround :: proc(self: ^Player) -> bool { return self.pos.y <= 0 + self.size.y }
IsPlayerSprinting :: proc(self: ^Player) -> bool { return rl.IsKeyDown(.LEFT_SHIFT) || rl.IsMouseButtonDown(.RIGHT) }
IsPlayerCrouching :: proc(self: ^Player) -> bool { return rl.IsKeyDown(.LEFT_CONTROL) || rl.IsKeyDown(.C) }
IsPlayerSliding :: proc(self: ^Player) -> bool { return IsPlayerSprinting(self) && IsPlayerCrouching(self) }
GetPlayerForwardAxis :: proc() -> f32 { return f32(int(rl.IsKeyDown(.W)) - int(rl.IsKeyDown(.S))) }
GetPlayerSidewardAxis :: proc() -> f32 { return f32(int(rl.IsKeyDown(.D)) - int(rl.IsKeyDown(.A))) }
IsPlayerMovingAxis :: proc() -> bool { return GetPlayerForwardAxis() == 0 || GetPlayerSidewardAxis() == 0 }
GetMouseSensitivity :: proc() -> f32 { return 0.0025 }

UpdatePlayer :: proc(self: ^Player) {
	frame_time := rl.GetFrameTime()
	mouse_delta := rl.GetMouseDelta()
	rot_clamp := math.to_radians_f32(90)
	diag_speed_mult := 1 / math.sqrt_f32(2)
	GRAVITY :: -0.1
	JUMP_VEL :: 4
	SPEEDS :: rl.Vector2{3.5, 6.5} //base, sprint
	FOVS :: rl.Vector2{60, 80} //base, sprint
	HEIGHTS :: rl.Vector2{0.5, 0.25} //base, crouch
	SUBMAX_SLIDE_VEL :: 4
	
	// Manage rotations with mouse cursor
	speed := frame_time * self.speed
	self.rot.x -= mouse_delta.x * GetMouseSensitivity()
	self.rot.y = clamp(self.rot.y - mouse_delta.y * GetMouseSensitivity(), -rot_clamp, rot_clamp)
	
	// Manage direction vector
	self.dir.x = cos(self.rot.y) * sin(self.rot.x)
    self.dir.y = sin(self.rot.y)
    self.dir.z = cos(self.rot.y) * cos(self.rot.x)
    
    // Manage diagonal movement
    if(!IsPlayerMovingAxis()) do speed *= diag_speed_mult
    
    // Manage sprinting (speed + FOV)
    if(IsPlayerSprinting(self)) {
    	if(self.speed < SPEEDS.y) do self.speed += frame_time * 10
     	if(self.fov < FOVS.y) do self.fov += frame_time * 50
    } else {
    	if(self.speed > SPEEDS.x) do self.speed -= frame_time * 10
   		if(self.fov > FOVS.x) do self.fov -= frame_time * 50
    }
    
    // Manage Crouching (player height)
    if(IsPlayerCrouching(self) && self.size.y > HEIGHTS.y) do self.size.y -= frame_time * 10
    if(!IsPlayerCrouching(self) && self.size.y < HEIGHTS.x) do self.size.y += frame_time * 2
    
    // Calculate the velocity that will be used when moving
    pre_vel_x := speed * (sin(self.rot.x) * GetPlayerForwardAxis() - cos(self.rot.x) * GetPlayerSidewardAxis())
    pre_vel_z := speed * (cos(self.rot.x) * GetPlayerForwardAxis() + sin(self.rot.x) * GetPlayerSidewardAxis())
    
    // Use above velocity, modify if player is sliding
    if(!IsPlayerSliding(self)) {
   		self.vel.x = pre_vel_x * SIM_FPS
     	self.vel.z = pre_vel_z * SIM_FPS
    } else {
    	if(abs(self.vel.x) < SUBMAX_SLIDE_VEL) do self.vel.x += pre_vel_x
     	if(abs(self.vel.z) < SUBMAX_SLIDE_VEL) do self.vel.z += pre_vel_z
      
      	// Reduce velocities if above a certain value
      	if(abs(self.vel.x) + abs(self.vel.z) >= 5) {
     		if(self.vel.x > 0) do self.vel.x -= 2 * frame_time
       		if(self.vel.x < 0) do self.vel.x += 2 * frame_time
         	if(self.vel.z > 0) do self.vel.z -= 2 * frame_time
          	if(self.vel.z < 0) do self.vel.z += 2 * frame_time
       	}
    }
    
    // Manage jumping
    if(rl.IsKeyPressed(.SPACE) && IsPlayerOnGround(self)) do self.vel.y = JUMP_VEL
    
    // Apply velocity to position (with delta time)
    self.pos.x += self.vel.x * frame_time
    self.pos.y += self.vel.y * frame_time
    self.pos.z += self.vel.z * frame_time
    
    // Handle gravity
    self.vel.y += GRAVITY
    if(IsPlayerOnGround(self)) do self.vel.y = 0
    
    // Clamp Y position at ~0 (WILL REMOVE WHEN I ADD COLLISIONS)
    self.pos.y = clamp(self.pos.y, 0 + self.size.y, 999999)
    
    // Clamp some values for safety
    self.speed = clamp(self.speed, SPEEDS.x, SPEEDS.y)
    self.fov = clamp(self.fov, FOVS.x, FOVS.y)
    self.size.y = clamp(self.size.y, HEIGHTS.y, HEIGHTS.x)
    
    // Change camera settings
    self.camera.position = self.pos
	self.camera.target = self.pos + self.dir
	self.camera.fovy = self.fov
}