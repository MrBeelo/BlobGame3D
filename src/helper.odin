package bb3d

import "core:math"
import rl "vendor:raylib"

// Functions
sin :: math.sin
cos :: math.cos
clamp :: math.clamp
abs :: math.abs
floor :: math.floor
sqrt :: math.sqrt
round :: proc(x: f32, n: f32) -> f32 { return n * ((x + n / 2) / n) }

LoadGameResources :: proc() {
	LoadShaders() // Should ALWAYS be first!
	LoadFloor()
	LoadSkybox()
	LoadBlob()
}

UnloadGameResources :: proc() {
	UnloadShaders()
	UnloadFloor()
	UnloadSkybox()
	UnloadBlob()
}

GetPosInFrontOfCamera :: proc(amount: f32) -> rl.Vector3 {
	forward := rl.Vector3Normalize(player.camera.target - player.camera.position)
	return player.camera.position + forward * amount
}

// Helper Structs
Pair :: struct($T: typeid, $U: typeid) { first: T, second: U }

// Global Constants
SCREEN_SIZE :: rl.Vector2{1920, 1080}