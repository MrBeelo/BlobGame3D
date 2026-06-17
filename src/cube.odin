package bg3d

import "core:mem"
import rl "vendor:raylib"

cube_model_cache: map[rl.Vector3]rl.Model
floor_textures : [4]rl.Texture2D // Diffuse, Normal Map, Roughness, Tiling
wall_textures: [4]rl.Texture2D // Diffuse, Normal Map, Roughness, Tiling

CubeType :: enum {
	NONE,
	WALL,
	FLOOR
}

LoadCube :: proc() {
	texture_types := [4]TextureType{.DIFFUSE, .NORMAL, .ROUGH, .HEIGHT}
	for i in 0..=3 do floor_textures[i] = LoadTextureDef("tiles", texture_types[i])
	for i in 0..=3 do wall_textures[i] = LoadTextureDef("brick", texture_types[i])
	for texture in (floor_textures) do rl.SetTextureWrap(texture, .REPEAT)
	for texture in (wall_textures) do rl.SetTextureWrap(texture, .REPEAT)
}

UnloadCube :: proc() {
	for texture in (floor_textures) do rl.UnloadTexture(texture)
	for texture in (blob_textures) do rl.UnloadTexture(texture)
}

NewCube :: proc(pos: rl.Vector3, rot: rl.Vector3, size: rl.Vector3, type := CubeType.WALL, room_number := int(0), 
props := ObjectProperties{true, false, true}, special_prop := SpecialProperty.NONE) -> Object {
	cube_model: rl.Model
	if model, ok := cube_model_cache[size]; ok do cube_model = model; else do cube_model = GetCubeModel(size)
	
	#partial switch(type) {
		case .WALL: AssignTextures(&cube_model, 4, wall_textures, [4]rl.MaterialMapIndex{.ALBEDO, .NORMAL, .ROUGHNESS, .HEIGHT})
		case .FLOOR: AssignTextures(&cube_model, 4, floor_textures, [4]rl.MaterialMapIndex{.ALBEDO, .NORMAL, .ROUGHNESS, .HEIGHT})
	}
	
	box := GetCubeOBB(pos, rot, size, .XYZ)
	
	return NewObject(pos, rot, 1, cube_model, box, .XYZ, props, {.NORMAL, .TILING}, room_number = room_number,
		special_prop = special_prop)
}

AssignTextures :: proc(model: ^rl.Model, $amount: uint, textures: [amount]rl.Texture2D, shader_types: [amount]rl.MaterialMapIndex) {
	AssignShader(model, material_shader, 0)
	for i in 0..<amount do AssignTexture(model, textures[i], shader_types[i], 0)
}

UpdateTriggers :: proc(obj: ^Object) {
	if CheckCollisionCapsuleOBB(GetCurrentPlayerCapsule(), obj.box) do #partial switch(obj.special_prop) {
		case .ADVANCE_TRIGGER: if(global_room_number <= obj.room_number) do AdvanceRoom(obj.room_number)
		case .END_TRIGGER: if(IsInMainGame()) do BeginSaferoomStartSequence()
	}
}

GetCubeOBB :: proc(pos: rl.Vector3, rot: rl.Vector3, scale: rl.Vector3, order: MatrixRotationOrder) -> OBB {
	rm := MatrixRotateGeneral(rot_rad(rot), order)
	axis_x := rl.Vector3{rm[0, 0], rm[1, 0], rm[2, 0]}
	axis_y := rl.Vector3{rm[0, 1], rm[1, 1], rm[2, 1]}
	axis_z := rl.Vector3{rm[0, 2], rm[1, 2], rm[2, 2]}
	return {pos, {axis_x, axis_y, axis_z}, scale / 2}
}

GetCubeModel :: proc(scale: rl.Vector3 = {1, 1, 1}) -> rl.Model {
	mesh := GenCustomCubeMesh(scale)
	model := rl.LoadModelFromMesh(mesh)
	cube_model_cache[scale] = model
	return model
}

GenCustomCubeMesh :: proc(scale: rl.Vector3, tile: bool = true) -> rl.Mesh {
	hw := scale.x / 2
	hh := scale.y / 2
	hl := scale.z / 2
	vertices := [?]f32{
        -hw, -hh, hl,  hw, -hh, hl,  hw, hh, hl,  -hw, -hh, hl,  hw, hh, hl,  -hw, hh, hl, // FRONT
        hw, -hh, -hl,  -hw, -hh, -hl,  -hw, hh, -hl,  hw, -hh, -hl,  -hw, hh, -hl,  hw, hh, -hl, // BACK
        -hw, -hh, -hl,  -hw, -hh, hl,  -hw, hh, hl,  -hw, -hh, -hl,  -hw, hh, hl,  -hw, hh, -hl, // LEFT
        hw, -hh, hl,  hw, -hh, -hl,  hw, hh, -hl,  hw, -hh, hl,  hw, hh, -hl,  hw, hh, hl, // RIGHT
        -hw, hh, hl,  hw, hh, hl,  hw, hh, -hl,  -hw, hh, hl,  hw, hh, -hl,  -hw, hh, -hl, // TOP
        -hw, -hh, -hl,  hw, -hh, -hl,  hw, -hh, hl,  -hw, -hh, -hl,  hw, -hh, hl,  -hw, -hh, hl // BOTTOM
    }
    
    tw := (tile) ? scale.x : 1
    th := (tile) ? scale.y : 1
    tl := (tile) ? scale.z : 1
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

    vertices_ptr, _ := mem.alloc(len(vertices) * size_of(f32))
    mesh.vertices = cast([^]f32) vertices_ptr
    mem.copy(mesh.vertices, &vertices, len(vertices) * size_of(f32))
    
    texcoords_ptr, _ := mem.alloc(len(texcoords) * size_of(f32))
    mesh.texcoords = cast([^]f32) texcoords_ptr
    mem.copy(mesh.texcoords, &texcoords, len(texcoords) * size_of(f32))
    
    normals_ptr, _ := mem.alloc(len(normals) * size_of(f32))
    mesh.normals = cast([^]f32) normals_ptr
    mem.copy(mesh.normals, &normals, len(normals) * size_of(f32))
    
    rl.GenMeshTangents(&mesh)

    rl.UploadMesh(&mesh, false)
    return mesh
}