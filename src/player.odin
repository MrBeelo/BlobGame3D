package bb3d

import "core:math"
import "core:math/rand"
import rl "vendor:raylib"

MAX_HEALTH :: 100
MAX_WALLJUMPS :: 3

player: Player
rots: [2]rl.Vector2 // old, new

Player :: struct {
	pos: rl.Vector3,
	vel: rl.Vector3,
	rot: rl.Vector2, // yaw, pitch
	dir: rl.Vector3,
	size: rl.Vector3,
	fov: f32,
	camera: rl.Camera3D,
	health: f32,
	speed: f32,
	collisions: [6]bool, // min xyz, max xyz
	walljumps: int
}

NewPlayer :: proc() -> Player {
	POS :: rl.Vector3{0, 0.5, 0}
	FOV :: 60
	SIZE :: rl.Vector3{0.1, 0.5, 0.1}
	camera := rl.Camera3D{POS, {1, 0.5, 1}, {0, 1, 0}, FOV, .PERSPECTIVE}
	return Player{POS, {}, {}, {}, SIZE, FOV, camera, MAX_HEALTH, MAX_WALLJUMPS, {}, 0}
}

// Helper Functions
ResetPlayer :: proc() { player = NewPlayer() }
IsPlayerSprinting :: proc() -> bool { return rl.IsKeyDown(.LEFT_SHIFT) || rl.IsMouseButtonDown(.RIGHT) }
IsPlayerCrouching :: proc() -> bool { return rl.IsKeyDown(.LEFT_CONTROL) || rl.IsKeyDown(.C) }
IsPlayerSliding :: proc() -> bool { return IsPlayerSprinting() && IsPlayerCrouching() }
GetPlayerForwardAxis :: proc() -> f32 { return f32(int(rl.IsKeyDown(.W)) - int(rl.IsKeyDown(.S))) }
GetPlayerSidewardAxis :: proc() -> f32 { return f32(int(rl.IsKeyDown(.D)) - int(rl.IsKeyDown(.A))) }
IsPlayerMovingAxis :: proc() -> bool { return GetPlayerForwardAxis() != 0 || GetPlayerSidewardAxis() != 0 }
IsPlayerMovingSidewaysAxis :: proc() -> bool { return GetPlayerForwardAxis() != 0 && GetPlayerSidewardAxis() != 0 }
GetMouseSensitivity :: proc() -> f32 { return 0.0025 }
GetCameraFrustum :: proc(self: ^Player) -> Frustum { return CameraGetFrustum(&self.camera, f32(SCREEN_SIZE[0] / f32(SCREEN_SIZE[1]))) }
GetPlayerBoundingBox :: proc(self: ^Player) -> rl.BoundingBox { return {self.pos - self.size, self.pos + self.size} }
IsCollidingXZ :: proc(self: ^Player) -> bool { return self.collisions[0] || self.collisions[2] || self.collisions[3] || self.collisions[5] }
IsCollidingYDown :: proc(self: ^Player) -> bool { return self.collisions[4] }
IsCollidingYUp :: proc(self: ^Player) -> bool { return self.collisions[1] }
IsColliding :: proc(self: ^Player) -> bool { return IsCollidingXZ(self) || IsCollidingYDown(self) || IsCollidingYUp(self) }
PlayerPressedCrouch :: proc() -> bool { return rl.IsKeyPressed(.LEFT_CONTROL) || rl.IsKeyPressed(.C) }
PlayerJumped :: proc() -> bool { return rl.IsKeyPressed(.SPACE) }
GetRotationChange :: proc() -> rl.Vector2 { return {rots[1].x - rots[0].x, rots[1].y - rots[0].y} }
PlayerSwitchedFlashlight :: proc() -> bool { return rl.IsKeyPressed(.F) }

UpdatePlayer :: proc(self: ^Player) {
	frame_time := rl.GetFrameTime()
	mouse_delta := rl.GetMouseDelta()
	rot_clamp := math.to_radians_f32(90)
	diag_speed_mult := 1 / math.sqrt_f32(2)
	
	SPEEDS :: rl.Vector2{2.5, 5.5} //base, sprint
	FOVS :: rl.Vector2{60, 80} //base, sprint
	HEIGHTS :: rl.Vector2{0.5, 0.2} //base, crouch
	JUMP_VELS :: rl.Vector2{4, 3} //base, crouch
	
	// Set old rotation
	rots[0] = self.rot
	
	// Manage rotations with mouse cursor
	speed := self.speed
	self.rot.x -= mouse_delta.x * GetMouseSensitivity()
	self.rot.y = clamp(self.rot.y - mouse_delta.y * GetMouseSensitivity(), -rot_clamp + 0.1, rot_clamp - 0.1)
	
	// Set new rotation
    rots[1] = self.rot
       	
	// Manage direction vector
	self.dir.x = cos(self.rot.y) * sin(self.rot.x)
    self.dir.y = sin(self.rot.y)
    self.dir.z = cos(self.rot.y) * cos(self.rot.x)
    
    // Manage diagonal movement
    if(IsPlayerMovingSidewaysAxis()) do speed *= diag_speed_mult
    
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
    	if(!IsCollidingYUp(self)) do self.size.y += frame_time * 2
    	if(IsCollidingYDown(self)) do self.pos.y += frame_time * 2
    } 
    
    // Sets the Y velocity (for when the player is on the air)
    CROUCH_Y_VEL :: -4
    if(PlayerPressedCrouch()) do self.vel.y = CROUCH_Y_VEL
    
    // Calculate the velocity that will be used when moving
    pre_vel_x := speed * (sin(self.rot.x) * GetPlayerForwardAxis() - cos(self.rot.x) * GetPlayerSidewardAxis())
    pre_vel_z := speed * (cos(self.rot.x) * GetPlayerForwardAxis() + sin(self.rot.x) * GetPlayerSidewardAxis())
    
    // Use above velocity, modify if player is sliding
    if(!IsPlayerSliding()) {
    	if(pre_vel_x != 0) do self.vel.x = pre_vel_x
     	if(pre_vel_z != 0) do self.vel.z = pre_vel_z

       	DECELERATION_MODIFIER :: 1.1
       	if(abs(self.vel.x) > pre_vel_x && pre_vel_x == 0) do self.vel.x /= DECELERATION_MODIFIER
        if(abs(self.vel.z) > pre_vel_z && pre_vel_z == 0) do self.vel.z /= DECELERATION_MODIFIER
   		
       	// Low but non-zero velocity fix
        if(!IsPlayerMovingAxis()) {
       		ZERO_THRESHOLD :: 0.05
         	if(abs(self.vel.x) <= ZERO_THRESHOLD) do self.vel.x = 0
          	if(abs(self.vel.z) <= ZERO_THRESHOLD) do self.vel.z = 0
        }
    } else {    
    	SLIDE_ACCELERATION :: 3
     	SUBMAX_SLIDE_VEL :: 4
     	if(abs(self.vel.x) < SUBMAX_SLIDE_VEL) do self.vel.x += (pre_vel_x - self.vel.x) * SLIDE_ACCELERATION * frame_time
      	if(abs(self.vel.z) < SUBMAX_SLIDE_VEL) do self.vel.z += (pre_vel_z - self.vel.z) * SLIDE_ACCELERATION * frame_time
      
      	// Reduce velocities if above a certain value
        avg_vel := sqrt(self.vel.x*self.vel.x + self.vel.z*self.vel.z)
        if(avg_vel > 3) {
       		vel_decrease_modifier := avg_vel / 2
        	if(self.vel.x > 0) do self.vel.x -= vel_decrease_modifier * frame_time
         	if(self.vel.x < 0) do self.vel.x += vel_decrease_modifier * frame_time
         	if(self.vel.z > 0) do self.vel.z -= vel_decrease_modifier * frame_time
          	if(self.vel.z < 0) do self.vel.z += vel_decrease_modifier * frame_time
        }
    }
    
    // Manage jumping
    if(PlayerJumped() && (IsCollidingYDown(self) || (IsCollidingXZ(self) && self.walljumps > 0))) {
   		PlayPoolSound(.JUMP)
    	JUMP_MULT :: 1.7
    	self.vel.y = IsPlayerCrouching() ? JUMP_VELS[1] : JUMP_VELS[0]
     	if(IsCollidingXZ(self)) do self.vel.xz *= JUMP_MULT
      	if(!IsCollidingYDown(self)) do self.walljumps -= 1
    }
    
    // Register previous position (for collisions) and reset collisions
    old_pos := self.pos
    self.collisions = {}
    
    // Apply velocity to position (with delta time) and check for collisions
    for x in (0..=2) {
    	self.pos[x] += self.vel[x] * frame_time
     	for obj in (objects) do if(rl.CheckCollisionBoxes(GetPlayerBoundingBox(self), GetObjectBoundingBox(obj)) && obj.collidable) {
      		mod: int = (self.pos[x] < obj.pos[x]) ? 0 : 3
     		self.collisions[x + mod] = true
      		self.pos[x] = old_pos[x]
      	}
    }
    
    // Fix Y position in case of noclip
    if((self.vel.x != 0 || self.vel.z != 0) && self.pos == old_pos) {
    	if(!IsCollidingYUp(self)) {
     		self.pos.y += frame_time
     	} else do self.size.y -= frame_time
    } 
    
    // Handle gravity
    GRAVITY :: -10
    self.vel.y += GRAVITY * frame_time
    if(IsCollidingYDown(self) || IsCollidingYUp(self)) do self.vel.y = -0.1
    
    // Reset walljumps
    if(IsCollidingYDown(self)) do self.walljumps = MAX_WALLJUMPS
    
    // Clamp some values for safety
    self.speed = clamp(self.speed, SPEEDS.x, SPEEDS.y)
    self.fov = clamp(self.fov, FOVS.x, FOVS.y)
    self.size.y = clamp(self.size.y, HEIGHTS.y, HEIGHTS.x)
    
    // Change camera settings
    self.camera.position = self.pos
	self.camera.target = self.pos + self.dir
	self.camera.fovy = self.fov
	
	// Handle Flashlight
	if(PlayerSwitchedFlashlight()) {
		is_light_on = !is_light_on
		rl.PlaySound(flashlight_switch_sound)
	}
	
	// Handle Health
	if(self.health < MAX_HEALTH && GetRemainingClockTime() > 0) do self.health += frame_time * 0.5
	self.health = clamp(self.health, 0, MAX_HEALTH)
	if(self.health == 0) do BeginDeathSequence()
	if(GetRemainingClockTime() <= 0) do self.health -= frame_time * sqrt(abs(GetRemainingClockTime())) * 2
	
	// Screen Shaking
	if(GetRemainingClockTime() < 0) {
		offset := ((MAX_HEALTH - self.health) / MAX_HEALTH) * 3
		self.rot[0] += rand.float32_range(-offset, offset) * frame_time
		self.rot[1] += rand.float32_range(-offset, offset) * frame_time
	}
}

GetPosInFrontOfCamera :: proc(amount: rl.Vector3) -> rl.Vector3 {
	// Amount: X -> right, Y -> up, Z -> forward
	forward := rl.Vector3Normalize(player.camera.target - player.camera.position)
	right := rl.Vector3Normalize(rl.Vector3CrossProduct(forward, player.camera.up))
	up := rl.Vector3CrossProduct(right, forward)
	return player.camera.position + right * amount.x + up * amount.y + forward * amount.z
}

GetCameraRotation :: proc() -> rl.Vector3 {
	// Returns rotation in X-Y-Z format
	deg :: math.to_degrees
	forward := rl.Vector3Normalize(player.camera.target - player.camera.position)
    yaw := math.atan2(forward.x, forward.z)
    pitch := math.asin(-forward.y)
    return {deg(pitch), deg(yaw), 0}
}

DrawHealth :: proc(self: ^Player) {
	rl.DrawCircleGradient(0, i32(SCREEN_SIZE.y), 100, rl.BLACK, rl.BLANK)
	
	BUFFER :: 20
	FONT_SIZE :: 64
	FONT_SPACING :: 7
	text := format("%.0f", self.health)
	text_size := MeasureText(text, FONT_SIZE, FONT_SPACING, .CHANGA_ONE, .REGULAR)
	
	spikyness: rl.Vector2
	switch(self.health) {
		case 40..=50: spikyness = {0, 0}
		case 30..<40: spikyness = {1, 0.75}
		case 20..<30: spikyness = {2, 1.5}
		case 10..<20: spikyness = {4, 3}
		case 0..<10: spikyness = {6, 4.5}
		case: spikyness = {}
	}
	
	color: rl.Color
	switch(self.health) {
		case 40..=50: color = {255, 245, 243, 255}
		case 30..<40: color = {255, 213, 206, 255}
		case 20..<30: color = {255, 163, 148, 255}
		case 10..<20: color = {255, 119, 96, 255}
		case 0..<10: color = {255, 68, 37, 255}
		case: color = rl.WHITE
	}
	
	if(self.health > 50) {
		DrawTextShakyBordered(text, {BUFFER, SCREEN_SIZE.y - text_size.y - BUFFER}, FONT_SIZE, FONT_SPACING, 5, .CHANGA_ONE, .REGULAR,
			rl.WHITE, rl.BLACK, {2, 1.5}, 5)
	} else {
		DrawTextSpikyBordered(text, {BUFFER, SCREEN_SIZE.y - text_size.y - BUFFER}, FONT_SIZE, FONT_SPACING, 5, .CHANGA_ONE, .REGULAR,
			spikyness, color, rl.BLACK)
	}
}