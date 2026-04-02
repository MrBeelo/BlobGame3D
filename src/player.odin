package bb3d

import "core:math"
import "core:fmt"
import rl "vendor:raylib"

player : Player

Player :: struct {
	pos: rl.Vector3,
	vel: rl.Vector3,
	rot: rl.Vector2, //yaw, pitch
	dir: rl.Vector3,
	size: rl.Vector3,
	fov: f32,
	camera: rl.Camera3D,
	speed: f32,
	collisions: [3]bool
}

NewPlayer :: proc() -> Player {
	POS :: rl.Vector3{0, 0.5, 0}
	FOV :: 60
	SIZE :: rl.Vector3{0.2, 0.5, 0.2}
	camera := rl.Camera3D{POS, {1, 0.5, 1}, {0, 1, 0}, FOV, .PERSPECTIVE}
	return Player{POS, {}, {}, {}, SIZE, FOV, camera, 3, {}}
}

// Helper Functions
IsPlayerOnGround :: proc(self: ^Player) -> bool { return (self.pos.y <= 0 + self.size.y) }
IsPlayerSprinting :: proc() -> bool { return rl.IsKeyDown(.LEFT_SHIFT) || rl.IsMouseButtonDown(.RIGHT) }
IsPlayerCrouching :: proc() -> bool { return rl.IsKeyDown(.LEFT_CONTROL) || rl.IsKeyDown(.C) }
IsPlayerSliding :: proc() -> bool { return IsPlayerSprinting() && IsPlayerCrouching() }
GetPlayerForwardAxis :: proc() -> f32 { return f32(int(rl.IsKeyDown(.W)) - int(rl.IsKeyDown(.S))) }
GetPlayerSidewardAxis :: proc() -> f32 { return f32(int(rl.IsKeyDown(.D)) - int(rl.IsKeyDown(.A))) }
IsPlayerMovingAxis :: proc() -> bool { return GetPlayerForwardAxis() == 0 || GetPlayerSidewardAxis() == 0 }
GetMouseSensitivity :: proc() -> f32 { return 0.0025 }
IsPlayerMovingSideways :: proc(self: ^Player) -> bool { return abs(self.vel.x) >= 1.5 && abs(self.vel.z) >= 1.5 }
GetCameraFrustum :: proc(self: ^Player) -> Frustum { return CameraGetFrustum(&self.camera, f32(SCREEN_SIZE[0] / f32(SCREEN_SIZE[1]))) }
GetPlayerBoundingBox :: proc(self: ^Player) -> rl.BoundingBox { return {self.pos - self.size, self.pos + self.size} }
IsCollidingXZ :: proc(self: ^Player) -> bool { return self.collisions[0] || self.collisions[2] }
IsCollidingY :: proc(self: ^Player) -> bool { return self.collisions[1] }
IsColliding :: proc(self: ^Player) -> bool { return IsCollidingXZ(self) || IsCollidingY(self) }
PlayerPressedCrouch :: proc() -> bool { return rl.IsKeyPressed(.LEFT_CONTROL) || rl.IsKeyPressed(.C) }
PlayerJumped :: proc() -> bool { return rl.IsKeyPressed(.SPACE) }

UpdatePlayer :: proc(self: ^Player) {
	frame_time := rl.GetFrameTime()
	mouse_delta := rl.GetMouseDelta()
	rot_clamp := math.to_radians_f32(90)
	diag_speed_mult := 1 / math.sqrt_f32(2)
	
	SPEEDS :: rl.Vector2{2.5, 5.5} //base, sprint
	FOVS :: rl.Vector2{60, 80} //base, sprint
	HEIGHTS :: rl.Vector2{0.5, 0.25} //base, crouch
	JUMP_VELS :: rl.Vector2{4, 3} //base, crouch
	
	// Manage rotations with mouse cursor
	speed := self.speed
	self.rot.x -= mouse_delta.x * GetMouseSensitivity()
	self.rot.y = clamp(self.rot.y - mouse_delta.y * GetMouseSensitivity(), -rot_clamp + 0.1, rot_clamp - 0.1)
	
	// Manage direction vector
	self.dir.x = cos(self.rot.y) * sin(self.rot.x)
    self.dir.y = sin(self.rot.y)
    self.dir.z = cos(self.rot.y) * cos(self.rot.x)
    
    // Manage diagonal movement
    if(!IsPlayerMovingAxis() || IsPlayerMovingSideways(self)) do speed *= diag_speed_mult
    
    // Manage sprinting (speed + FOV)
    SPEED_CHANGE_MODIFIER :: 10
    FOV_CHANGE_MODIFIER :: 50
    if(IsPlayerSprinting()) {
    	if(self.speed < SPEEDS.y) do self.speed += frame_time * SPEED_CHANGE_MODIFIER
     	if(self.fov < FOVS.y) do self.fov += frame_time * FOV_CHANGE_MODIFIER
    } else {
    	if(self.speed > SPEEDS.x) do self.speed -= frame_time * SPEED_CHANGE_MODIFIER
   		if(self.fov > FOVS.x) do self.fov -= frame_time * FOV_CHANGE_MODIFIER
    }
    
    // Manage Crouching (player height)
    if(IsPlayerCrouching() && self.size.y > HEIGHTS.y) do self.size.y -= frame_time * 10
    if(!IsPlayerCrouching() && self.size.y < HEIGHTS.x) {
    	self.size.y += frame_time * 2
    	if(IsCollidingY(self)) do self.pos.y += frame_time * 2
    } 
    
    // Sets the Y velocity (for when the player is on the air)
    CROUCH_Y_VEL :: -2.5
    if(PlayerPressedCrouch()) do self.vel.y = CROUCH_Y_VEL
    
    // Calculate the velocity that will be used when moving
    pre_vel_x := speed * (sin(self.rot.x) * GetPlayerForwardAxis() - cos(self.rot.x) * GetPlayerSidewardAxis())
    pre_vel_z := speed * (cos(self.rot.x) * GetPlayerForwardAxis() + sin(self.rot.x) * GetPlayerSidewardAxis())
    
    // Use above velocity, modify if player is sliding
    if(!IsPlayerSliding()) {
   		self.vel.x = pre_vel_x
     	self.vel.z = pre_vel_z
    } else {    
    	SLIDE_ACCELERATION :: 3
     	SUBMAX_SLIDE_VEL :: 4
     	if(abs(self.vel.x) < SUBMAX_SLIDE_VEL) do self.vel.x += (pre_vel_x - self.vel.x) * SLIDE_ACCELERATION * frame_time
      	if(abs(self.vel.z) < SUBMAX_SLIDE_VEL) do self.vel.z += (pre_vel_z - self.vel.z) * SLIDE_ACCELERATION * frame_time
      
      	// Reduce velocities if above a certain value
       	MAX_TOTAL_VELOCITY :: 5
        VEL_DECREASE_MODIFIER :: 3
      	if(abs(self.vel.x) + abs(self.vel.z) >= MAX_TOTAL_VELOCITY) {
     		if(self.vel.x > 0) do self.vel.x -= VEL_DECREASE_MODIFIER * frame_time
       		if(self.vel.x < 0) do self.vel.x += VEL_DECREASE_MODIFIER * frame_time
         	if(self.vel.z > 0) do self.vel.z -= VEL_DECREASE_MODIFIER * frame_time
          	if(self.vel.z < 0) do self.vel.z += VEL_DECREASE_MODIFIER * frame_time
        }
    }
    
    // Manage jumping
    if(PlayerJumped() && (IsPlayerOnGround(self) || IsColliding(self))) {
    	self.vel.y = IsPlayerCrouching() ? JUMP_VELS[1] : JUMP_VELS[0]
     	if(IsCollidingXZ(self)) do self.vel.xz *= 2
    }
    
    // Register previous position (for collisions) and reset collisions
    old_pos := self.pos
    self.collisions = {}
    
    // Apply velocity to position (with delta time) and check for collisions
    for x in (0..=2) {
    	self.pos[x] += self.vel[x] * frame_time
     	for obj in (objects) do if(rl.CheckCollisionBoxes(GetPlayerBoundingBox(self), GetObjectBoundingBox(obj))) {
     		self.collisions[x] = true
      		self.pos[x] = old_pos[x]
      	}
    }
    
    // Fix Y position in case of noclip
    if((self.vel.x != 0 || self.vel.z != 0) && self.pos == old_pos) do self.pos.y += frame_time * 2
    
    // Handle gravity
    GRAVITY :: -10
    self.vel.y += GRAVITY * frame_time
    if(IsPlayerOnGround(self)) do self.vel.y = 0
    if(IsCollidingY(self)) do self.vel.y = -0.1
    
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