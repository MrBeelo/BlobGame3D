package bb3d

import "core:fmt"
import "core:math"
import "core:mem"
import "core:strings"
import rl "vendor:raylib"

// Global Constants
SCREEN_SIZE :: rl.Vector2{1920, 1080}

// Global Variables
should_exit := false
game_texture: rl.RenderTexture2D

// Helper Structs
Pair :: struct($T: typeid, $U: typeid) { first: T, second: U }

// Helper Enums
MatrixRotationOrder :: enum{ XYZ, XZY, YXZ, YZX, ZXY, ZYX }
TextureType :: enum{ DIFFUSE, NORMAL, ROUGH, HEIGHT }

// Functions
sin :: math.sin
cos :: math.cos
clamp :: math.clamp
abs :: math.abs
floor :: math.floor
sqrt :: math.sqrt
concat :: strings.concatenate
to_cstr :: strings.clone_to_cstring
round :: proc(x: f32, n: f32) -> f32 { return n * ((x + n / 2) / n) }
contains :: proc(arr: []$T, x: T) -> bool { for y in (arr) do if (y == x) { return true }; return false }

// RESOURCES

LoadGameResources :: proc() {
	LoadShaders() // Should ALWAYS be first!
	LoadFloor()
	LoadSkybox()
	LoadBlob()
	LoadWall()
	LoadFlashlight()
	LoadSounds()
	
	player = NewPlayer()
	InitMenus()
	game_texture = rl.LoadRenderTexture(i32(SCREEN_SIZE.x), i32(SCREEN_SIZE.y))
}

UnloadGameResources :: proc() {
	UnloadShaders()
	UnloadFloor()
	UnloadSkybox()
	UnloadBlob()
	UnloadWall()
	UnloadFlashlight()
	UnloadSounds()
	rl.UnloadRenderTexture(game_texture)
}

UpdateGame :: proc() {
	UpdateShaders()
	UpdateDebug()
	UpdateSounds()
	UpdateMenus()
		
	if(game_state != .PLAYING && game_state != .PAUSED) {
		UpdateObjects(main_bg_objects)
	} else {
		if(game_state == .PLAYING) do UpdatePlayer(&player)
		UpdateObjects()
		if(rl.IsKeyPressed(.ESCAPE)) do ChangeGameState((game_state == .PLAYING) ? .PAUSED : .PLAYING)
	}
}

DrawGame :: proc() {
	rl.BeginTextureMode(game_texture)
	rl.ClearBackground(rl.WHITE)
	if(game_state != .PLAYING && game_state != .PAUSED) {
		rl.BeginMode3D(main_bg_camera)
		DrawSkybox()
		DrawObjects(main_bg_objects)
		rl.EndMode3D()
	} else {
		rl.BeginMode3D(player.camera)
		DrawSkybox()
		DrawObjects()			
		rl.EndMode3D()
	}
	rl.EndTextureMode()
	
	rl.ClearBackground(rl.WHITE)
	if(game_state != .MAIN && game_state != .PLAYING) do rl.BeginShaderMode(blur_shader)
	rl.DrawTexturePro(game_texture.texture, {0, 0, SCREEN_SIZE.x, -SCREEN_SIZE.y}, {0, 0, SCREEN_SIZE.x, SCREEN_SIZE.y}, {}, 0, rl.WHITE)
	if(game_state != .MAIN && game_state != .PLAYING) do rl.EndShaderMode()
	
	DrawMenus()
	DrawDebug()
}

LoadTexture :: proc(path: string) -> rl.Texture2D {
	return rl.LoadTexture(to_cstr(concat({"res/textures/", path})))
}

LoadImage :: proc(path: string) -> rl.Image {
	return rl.LoadImage(to_cstr(concat({"res/textures/", path})))
}

LoadModel :: proc(path: string) -> rl.Model {
	return rl.LoadModel(to_cstr(concat({"res/models/", path})))
}

LoadShader :: proc(vs_path: string, fs_path: string) -> rl.Shader {
	vs := to_cstr(concat({"res/shaders/", vs_path}))
	fs := to_cstr(concat({"res/shaders/", fs_path}))
	return rl.LoadShader(vs, fs)
}

LoadShaderFs :: proc(path: string) -> rl.Shader {
	return rl.LoadShader(nil, to_cstr(concat({"res/shaders/", path})))
}

LoadShaderDef :: proc(name: string) -> rl.Shader {
	vs := concat({name, ".vs"})
	fs := concat({name, ".fs"})
	return LoadShader(vs, fs)
}

LoadShaderFsDef :: proc(name: string) -> rl.Shader {
	return LoadShaderFs(concat({name, ".fs"}))
}

LoadSound :: proc(path: string) -> rl.Sound {
	return rl.LoadSound(to_cstr(concat({"res/sounds/", path})))
}

LoadTextureDef :: proc(name: string, type: TextureType, suffix := ".png") -> rl.Texture2D {
	type_string := "diffuse"
	switch(type) {
		case .DIFFUSE: type_string = "diffuse"
		case .NORMAL: type_string = "normal"
		case .ROUGH: type_string = "rough"
		case .HEIGHT: type_string = "height"
	}
	
	return LoadTexture(concat({name, "/", name, "_", type_string, suffix}))
}

// VECTORS / POSITIONS / ROTATIONS

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

WrapAngleDiff :: proc(diff: f32) -> f32 {
    if (diff > 180) do return diff - 360
    if (diff < -180) do return diff + 360
    return diff
}

Vector3ToRadians :: proc(v: rl.Vector3) -> rl.Vector3 {
	rad :: math.to_radians
	return {rad(v.x), rad(v.y), rad(v.z)}
}

// MESHES / MODELS / BOUNDING BOXES

BoundingBoxAdd :: proc(box1: rl.BoundingBox, box2: rl.BoundingBox) -> rl.BoundingBox {
	return {{box1.min[0] + box2.min[0], box1.min[1] + box2.min[1], box1.min[2] + box2.min[2]}, 
		{box1.max[0] + box2.max[0], box1.max[1] + box2.max[1], box1.max[2] + box2.max[2]}}
}

GenCustomMeshCube :: proc(width, height, length: f32, tiling: bool = true) -> rl.Mesh {
	hw := width / 2
	hh := height / 2
	hl := length / 2
	vertices := [?]f32{
        -hw, -hh, hl,  hw, -hh, hl,  hw, hh, hl,  -hw, -hh, hl,  hw, hh, hl,  -hw, hh, hl, // FRONT
        hw, -hh, -hl,  -hw, -hh, -hl,  -hw, hh, -hl,  hw, -hh, -hl,  -hw, hh, -hl,  hw, hh, -hl, // BACK
        -hw, -hh, -hl,  -hw, -hh, hl,  -hw, hh, hl,  -hw, -hh, -hl,  -hw, hh, hl,  -hw, hh, -hl, // LEFT
        hw, -hh, hl,  hw, -hh, -hl,  hw, hh, -hl,  hw, -hh, hl,  hw, hh, -hl,  hw, hh, hl, // RIGHT
        -hw, hh, hl,  hw, hh, hl,  hw, hh, -hl,  -hw, hh, hl,  hw, hh, -hl,  -hw, hh, -hl, // TOP
        -hw, -hh, -hl,  hw, -hh, -hl,  hw, -hh, hl,  -hw, -hh, -hl,  hw, -hh, hl,  -hw, -hh, hl // BOTTOM
    }
    
    tw := (tiling) ? width : 1
    th := (tiling) ? height : 1
    tl := (tiling) ? length : 1
    texcoords := [?]f32{
        0, 0,  tw, 0,  tw, th,  0, 0,  tw, th,  0, th, // FRONT
        0, 0,  tw, 0,  tw, th,  0, 0,  tw, th,  0, th, // BACK
        0, 0,  tl, 0,  tl, th,  0, 0,  tl, th,  0, th, // LEFT
        0, 0,  tl, 0,  tl, th,  0, 0,  tl, th,  0, th, // RIGHT
        0, 0,  tw, 0,  tw, tl,  0, 0,  tw, tl,  0, tl, // TOP
        0, 0,  tw, 0,  tw, tl,  0, 0,  tw, tl,  0, tl, // BOTTOM
    }

    normals := [?]f32{
        0, 0, 1,  0, 0, 1,  0, 0, 1,  0, 0, 1,  0, 0, 1,  0, 0, 1, // FRONT
        0, 0,-1,  0, 0,-1,  0, 0,-1,  0, 0,-1,  0, 0,-1,  0, 0,-1, // BACK
        -1, 0, 0,  -1, 0, 0,  -1, 0, 0,  -1, 0, 0,  -1, 0, 0,  -1, 0, 0, // LEFT
        1, 0, 0,  1, 0, 0,  1, 0, 0,  1, 0, 0,  1, 0, 0,  1, 0, 0, // RIGHT
        0, 1, 0,  0, 1, 0,  0, 1, 0,  0, 1, 0,  0, 1, 0,  0, 1, 0, // TOP
        0,-1, 0,  0,-1, 0,  0,-1, 0,  0,-1, 0,  0,-1, 0,  0,-1, 0, // BOTTOM
    }
    
    mesh := rl.Mesh{}
    mesh.vertexCount = 36

    vertices_ptr, verr := mem.alloc(len(vertices) * size_of(f32))
    mesh.vertices = cast([^]f32) vertices_ptr
    mem.copy(mesh.vertices, &vertices, len(vertices) * size_of(f32))
    
    texcoords_ptr, terr := mem.alloc(len(texcoords) * size_of(f32))
    mesh.texcoords = cast([^]f32) texcoords_ptr
    mem.copy(mesh.texcoords, &texcoords, len(texcoords) * size_of(f32))
    
    normals_ptr, nerr := mem.alloc(len(normals) * size_of(f32))
    mesh.normals = cast([^]f32) normals_ptr
    mem.copy(mesh.normals, &normals, len(normals) * size_of(f32))
    
    rl.GenMeshTangents(&mesh)

    rl.UploadMesh(&mesh, false)
    return mesh
}

MatrixRotateGeneral :: proc(v: rl.Vector3, order: MatrixRotationOrder) -> rl.Matrix {
	rx := rl.MatrixRotateX(v.x)
	ry := rl.MatrixRotateY(v.y)
    rz := rl.MatrixRotateZ(v.z)
    switch(order) {
    	case .XYZ: return rx * ry * rz
     	case .XZY: return rx * rz * ry
      	case .YXZ: return ry * rx * rz
       	case .YZX: return ry * rz * rx
        case .ZXY: return rz * rx * ry
        case .ZYX: return rz * ry * rx
    }
    
    return rx * ry * rz
}

DrawModelPro :: proc(model: ^rl.Model, position: rl.Vector3, rotation: rl.Vector3, scale: rl.Vector3, tint: rl.Color, order: MatrixRotationOrder = MatrixRotationOrder.XYZ) {
    matScale := rl.MatrixScale(scale.x, scale.y, scale.z)
    matRotation := MatrixRotateGeneral(rotation, order)
    matTranslation := rl.MatrixTranslate(position.x, position.y, position.z)
    matTransform := matTranslation * matRotation * matScale

    for i := 0; i < int(model.meshCount); i += 1 {
        mat := model.materials[model.meshMaterial[i]]
        colDiffuse := mat.maps[rl.MaterialMapIndex.ALBEDO].color

        colTinted: rl.Color = {}
        colTinted.r = u8((int(colDiffuse.r) * int(tint.r)) / 255)
        colTinted.g = u8((int(colDiffuse.g) * int(tint.g)) / 255)
        colTinted.b = u8((int(colDiffuse.b) * int(tint.b)) / 255)
        colTinted.a = u8((int(colDiffuse.a) * int(tint.a)) / 255)

        mat.maps[rl.MaterialMapIndex.ALBEDO].color = colTinted
        rl.DrawMesh(model.meshes[i], mat, matTransform)
        mat.maps[rl.MaterialMapIndex.ALBEDO].color = colDiffuse
    }
}