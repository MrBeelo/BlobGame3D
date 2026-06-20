package bg3d

import "core:math"
import "core:math/rand"
import rl "vendor:raylib"

BASE_MAX_HEALTH :: 100
BASE_MAX_WALLJUMPS :: 3
max_health := f32(BASE_MAX_HEALTH + run_upgrades[.EXTRA_MAX_HEALTH] * 10)
max_walljumps := BASE_MAX_WALLJUMPS + run_upgrades[.EXTRA_WALLJUMPS]

SPEEDS :: rl.Vector2{2.5, 5.5} //Base, Sprint
FOVS :: rl.Vector2{60, 80} //Base, Sprint
HEIGHTS :: rl.Vector2{0.6, 0.4} //Base, Crouch
JUMP_VELS :: rl.Vector2{4, 3} //Base, Crouch

player: Player
rots: [2]rl.Vector2 // Old, New
was_on_ground: bool
coyote_timer: Timer

InitCoyoteTimer :: proc() { coyote_timer = NewTimer(0.07, false) }

Player :: struct {
	pos: rl.Vector3,
	vel: rl.Vector3,
	rot: rl.Vector2, // Yaw, Pitch
	dir: rl.Vector3,
	height: f32,
	fov: f32,
	camera: rl.Camera3D,
	health: f32,
	speed: f32,
	collisions: [6]bool, // Min XYZ, Max XYZ
	walljumps: int
}

NewPlayer :: proc(keep_health := false) -> Player {
	POS :: rl.Vector3{0, HEIGHTS[0] + 0.05, 0}
	FOV :: 60
	camera := rl.Camera3D{POS, {}, {0, 1, 0}, FOV, .PERSPECTIVE}
	health := player.health if(keep_health) else max_health
	return Player{POS, {}, {math.to_radians_f32(90), 0}, {}, HEIGHTS[0], FOV, camera, health, f32(max_walljumps), {}, 0}
}

// Helper Functions
ResetPlayer :: proc(keep_health := false) { player = NewPlayer(keep_health) }
IsPlayerSprinting :: proc() -> bool { return rl.IsKeyDown(.LEFT_SHIFT) || rl.IsMouseButtonDown(.RIGHT) }
IsPlayerCrouching :: proc() -> bool { return rl.IsKeyDown(.LEFT_CONTROL) || rl.IsKeyDown(.C) }
IsPlayerSliding :: proc() -> bool { return IsPlayerSprinting() && IsPlayerCrouching() }
GetPlayerForwardAxis :: proc() -> f32 { return f32(int(rl.IsKeyDown(.W)) - int(rl.IsKeyDown(.S))) }
GetPlayerSidewardAxis :: proc() -> f32 { return f32(int(rl.IsKeyDown(.D)) - int(rl.IsKeyDown(.A))) }
IsPlayerMovingAxis :: proc() -> bool { return GetPlayerForwardAxis() != 0 || GetPlayerSidewardAxis() != 0 }
IsPlayerMovingSidewaysAxis :: proc() -> bool { return GetPlayerForwardAxis() != 0 && GetPlayerSidewardAxis() != 0 }
GetCameraFrustum :: proc(self: ^Player) -> Frustum { return GetFrustumFromCamera(&self.camera, f32(SCREEN_SIZE[0] / f32(SCREEN_SIZE[1]))) }
GetCurrentPlayerCapsule :: proc() -> Capsule { return GetPlayerCapsule(player.pos, player.height) }
IsCollidingXZ :: proc(self: ^Player) -> bool { return self.collisions[0] || self.collisions[2] || self.collisions[3] || self.collisions[5] }
IsCollidingYDown :: proc(self: ^Player) -> bool { return self.collisions[1] }
IsCollidingYUp :: proc(self: ^Player) -> bool { return self.collisions[4] }
IsCollidingY :: proc(self: ^Player) -> bool { return IsCollidingYDown(self) || IsCollidingYUp(self) }
IsColliding :: proc(self: ^Player) -> bool { return IsCollidingXZ(self) || IsCollidingY(self) }
PlayerPressedCrouch :: proc() -> bool { return rl.IsKeyPressed(.LEFT_CONTROL) || rl.IsKeyPressed(.C) }
PlayerJumped :: proc() -> bool { return rl.IsKeyPressed(.SPACE) }
GetRotationChange :: proc() -> rl.Vector2 { return {rots[1].x - rots[0].x, rots[1].y - rots[0].y} }
PlayerSwitchedFlashlight :: proc() -> bool { return rl.IsKeyPressed(.F) }

UpdatePlayer :: proc(self: ^Player) {
	UpdateTimer(&coyote_timer)
	frame_time := rl.GetFrameTime()
	frame_time = clamp(frame_time, 0.0001, 0.1)
	mouse_delta := rl.GetMouseDelta()
	rot_clamp := math.to_radians_f32(90)
	diag_speed_mult := 1 / math.sqrt_f32(2)
	
	max_health = f32(BASE_MAX_HEALTH + run_upgrades[.EXTRA_MAX_HEALTH])
	max_walljumps = BASE_MAX_WALLJUMPS + run_upgrades[.EXTRA_WALLJUMPS]
	
	// Set old rotation
	rots[0] = self.rot
	
	// Manage rotations with mouse cursor
	speed := self.speed
	self.rot.x -= mouse_delta.x * settings.sensitivity
	self.rot.y = clamp(self.rot.y - mouse_delta.y * settings.sensitivity, -rot_clamp + 0.1, rot_clamp - 0.1)
	
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
       	if(abs(self.vel.x) > pre_vel_x && pre_vel_x == 0) do self.vel.x /= math.pow(DECELERATION_MODIFIER, frame_time * 144)
        if(abs(self.vel.z) > pre_vel_z && pre_vel_z == 0) do self.vel.z /= math.pow(DECELERATION_MODIFIER, frame_time * 144)
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
    
    // Low but non-zero velocity fix
    if(!IsPlayerMovingAxis()) {
   		ZERO_THRESHOLD :: 0.005
     	if(abs(self.vel.x) <= ZERO_THRESHOLD) do self.vel.x = 0
      	if(abs(self.vel.z) <= ZERO_THRESHOLD) do self.vel.z = 0
    }
    
    // Terminal velocity
    TERMINAL_VELOCITY :: 10
    self.vel.y = clamp(self.vel.y, -TERMINAL_VELOCITY, TERMINAL_VELOCITY)
    
    // Manage jumping
    KNOCKBACK_VELOCITY :: 0.3
    if PlayerJumped() && (IsCollidingYDown(self) || (IsCollidingXZ(self) && self.walljumps > 0) || coyote_timer.active) {
   		PlayPoolSound(.JUMP)
    	JUMP_MULT :: 1.4
    	self.vel.y = IsPlayerCrouching() ? JUMP_VELS[1] : JUMP_VELS[0]
     	if(IsCollidingXZ(self)) do self.vel.xz *= JUMP_MULT
      	if(!IsCollidingYDown(self)) do self.walljumps -= 1
    }
    
    // Check if player was on ground (for coyote time)
    was_on_ground = IsCollidingYDown(self)
    
    // Register previous position (for collisions) and reset collisions
    old_pos := self.pos
    self.collisions = {}
    
    // This is obvious enough
    UpdateNearbyObjects(self)

    // Move!
    move_order := [3]int{0, 2, 1}
	for axis in move_order do MovePlayer(self, axis, frame_time, near_objects)
	
	// Check if player IS on ground and update coyote time accordingally
	if !IsCollidingYDown(self) && was_on_ground do ActivateTimer(&coyote_timer)
      
    // Manage Crouching (player height)
    CROUCH_HEIGHT_CHANGE_MODIFIER :: 2
    change := frame_time * CROUCH_HEIGHT_CHANGE_MODIFIER
    if IsPlayerCrouching() && self.height > HEIGHTS.y do self.height -= change
    will_collide_up := GetCollisions(self.pos, self.height + change + 0.01, 1).y
    if !IsPlayerCrouching() && self.height < HEIGHTS.x && !will_collide_up do self.height += change
    
    // Handle gravity
    GRAVITY :: -10
    self.vel.y += GRAVITY * frame_time
    
    // Reset walljumps
    if(IsCollidingYDown(self)) do self.walljumps = max_walljumps
    
    // Clamp some values for safety
    self.speed = clamp(self.speed, SPEEDS.x, SPEEDS.y)
    self.fov = clamp(self.fov, FOVS.x, FOVS.y)
    self.height = clamp(self.height, HEIGHTS.y, HEIGHTS.x)
    
    // Change camera settings
    self.camera.position = self.pos - {0, HEIGHTS[0] - self.height, 0}
	self.camera.target = self.pos - {0, HEIGHTS[0] - self.height, 0} + self.dir
	self.camera.fovy = self.fov
	
	// Handle Flashlight
	if(PlayerSwitchedFlashlight()) {
		is_light_on = !is_light_on
		rl.PlaySound(flashlight_switch_sound)
	}
	
	// Handle Health
	if(self.health < max_health && GetRemainingClockTime() > 0) do self.health += frame_time * 0.5
	self.health = clamp(self.health, 0, max_health)
	if(self.health == 0) do BeginDeathSequence()
	if(GetRemainingClockTime() <= 0) do self.health -= frame_time * sqrt(abs(GetRemainingClockTime())) * 2
	
	// Screen Shaking
	if(GetRemainingClockTime() < 0) {
		offset := ((max_health - self.health) / max_health) * 3
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

CheckCollisionWithObjects :: proc(capsule: Capsule, objs := objects) -> bool {
	for obj in objs {
		if !obj.props.collidable do continue
		if CheckCollisionCapsuleOBB(capsule, obj.box) do return true
	}
	
	return false
}

GetCollisions :: proc(plr_pos: rl.Vector3, plr_height: f32, axis: int, objs := objects) -> [2]bool {
	blocks: [2]bool
	for i in 0..=1 {
		probe_pos := plr_pos
		probe_pos[axis] += -0.01 if i == 0 else 0.01
		blocks[i] = CheckCollisionWithObjects(GetPlayerCapsule(probe_pos, plr_height), objs)
	}
	
	return blocks
}

MovePlayer :: proc(plr: ^Player, axis: int, frame_time: f32, objs := objects) {
	if axis >= 3 do return
	npos := plr.pos
	npos[axis] += plr.vel[axis] * frame_time
	collided := false
	capsule := GetPlayerCapsule(npos, plr.height)
	if CheckCollisionWithObjects(capsule, objs) do collided = true
	
	if axis != 1 {
		STEP_HEIGHT :: f32(0.05)
		CHECKS :: 10
		
		down_collision_exists := CheckCollisionWithObjects(capsule_add(capsule, {0, -STEP_HEIGHT, 0}), objs)
		for j in -CHECKS..=CHECKS {
			if j == 0 do continue
			y_change := STEP_HEIGHT * f32(j) / CHECKS
			collision := CheckCollisionWithObjects(capsule_add(capsule, {0, y_change, 0}), objs)
			if j < 0 && plr.vel.y <= 0 && !collided && !collision && down_collision_exists { npos.y += y_change; break }
			if j > 0 && collided && !collision { npos.y += y_change; collided = false; break }
		}
		
		capsule = GetPlayerCapsule(npos, plr.height)
		
		other_axis := 2 if axis == 0 else 0
		for j := 1; j < CHECKS; j *= -1 {
			change_vector: rl.Vector3
			change_vector[other_axis] += STEP_HEIGHT * f32(j) / CHECKS
			collision := CheckCollisionWithObjects(capsule_add(capsule, change_vector), objs)
			if collided && !collision { npos += change_vector; collided = false; break }
			if j < 0 do j -= 1
		}
	}
	
	capsule = GetPlayerCapsule(npos, plr.height)
	colls := GetCollisions(npos, plr.height, axis, objs)
	plr.collisions[axis], plr.collisions[axis + 3] = colls.x, colls.y
	
	if !collided do plr.pos = npos; else if axis == 1 do plr.vel.y = 0
}

GetPlayerCapsule :: proc(pos: rl.Vector3, height: f32) -> Capsule { 	
	RADIUS :: f32(0.1)
	low_player_pos := pos - {0, HEIGHTS[0], 0}
	high_player_pos := low_player_pos + {0, height, 0}
	low := low_player_pos + {0, RADIUS, 0}
	high := high_player_pos - {0, RADIUS, 0}
	mid := (low + high) / 2
	
	return Capsule{ { low, mid, high }, RADIUS }
}

UpdateNearbyObjects :: proc(plr: ^Player) {
	clear(&near_objects)
	for obj in objects do if CheckCollisionSphereOBB({plr.pos, 1}, obj.box) do append(&near_objects, obj)
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
	
	color := rl.ColorLerp(rl.WHITE, {255, 68, 37, 255}, (50 - self.health) / 50)
	
	if(self.health > 50) {
		DrawTextShaky(text, {BUFFER, SCREEN_SIZE.y - text_size.y - BUFFER}, FONT_SIZE, FONT_SPACING, .CHANGA_ONE, .REGULAR,
			rl.WHITE, {true, 5, rl.BLACK}, {2, 1.5}, 5, "")
	} else {
		DrawTextSpiky(text, {BUFFER, SCREEN_SIZE.y - text_size.y - BUFFER}, FONT_SIZE, FONT_SPACING, .CHANGA_ONE, .REGULAR,
			color, {true, 5, rl.BLACK}, spikyness)
	}
}