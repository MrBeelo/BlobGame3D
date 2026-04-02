package bb3d

import "core:math"
import rl "vendor:raylib"

// Global Constants
SCREEN_SIZE :: rl.Vector2{1920, 1080}

// Helper Structs
Pair :: struct($T: typeid, $U: typeid) { first: T, second: U }

// Functions
sin :: math.sin
cos :: math.cos
clamp :: math.clamp
abs :: math.abs
floor :: math.floor
sqrt :: math.sqrt
round :: proc(x: f32, n: f32) -> f32 { return n * ((x + n / 2) / n) }
contains :: proc(arr: []$T, x: T) -> bool {
	for y in (arr) do if (y == x) do return true
	return false
}

LoadGameResources :: proc() {
	LoadShaders() // Should ALWAYS be first!
	LoadFloor()
	LoadSkybox()
	LoadBlob()
	LoadWall()
}

UnloadGameResources :: proc() {
	UnloadShaders()
	UnloadFloor()
	UnloadSkybox()
	UnloadBlob()
	UnloadWall()
}

GetPosInFrontOfCamera :: proc(amount: f32) -> rl.Vector3 {
	forward := rl.Vector3Normalize(player.camera.target - player.camera.position)
	return player.camera.position + forward * amount
}

BoundingBoxAdd :: proc(box1: rl.BoundingBox, box2: rl.BoundingBox) -> rl.BoundingBox {
	return {{box1.min[0] + box2.min[0], box1.min[1] + box2.min[1], box1.min[2] + box2.min[2]}, 
		{box1.max[0] + box2.max[0], box1.max[1] + box2.max[1], box1.max[2] + box2.max[2]}}
}
