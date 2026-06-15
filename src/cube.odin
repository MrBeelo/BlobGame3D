package bg3d

import "core:mem"
import rl "vendor:raylib"

//TOP_PART_HEIGHT :: 0.1
cube_model_cache: map[rl.Vector3]rl.Model
floor_textures : [4]rl.Texture2D // Diffuse, Normal Map, Roughness, Tiling
wall_textures: [4]rl.Texture2D // Diffuse, Normal Map, Roughness, Tiling

CubeType :: enum {
	NONE,
	WALL,
	FLOOR
}

LoadCube :: proc() {
	floor_textures[0] = LoadTextureDef("tiles", .DIFFUSE)
	floor_textures[1] = LoadTextureDef("tiles", .NORMAL)
	floor_textures[2] = LoadTextureDef("tiles", .ROUGH)
	floor_textures[3] = LoadTextureDef("tiles", .HEIGHT)
	for texture in (floor_textures) do rl.SetTextureWrap(texture, .REPEAT)
	
	wall_textures[0] = LoadTextureDef("brick", .DIFFUSE)
	wall_textures[1] = LoadTextureDef("brick", .NORMAL)
	wall_textures[2] = LoadTextureDef("brick", .ROUGH)
	wall_textures[3] = LoadTextureDef("brick", .HEIGHT)
	for texture in (wall_textures) do rl.SetTextureWrap(texture, .REPEAT)
}

UnloadCube :: proc() {
	for texture in (floor_textures) do rl.UnloadTexture(texture)
	for texture in (blob_textures) do rl.UnloadTexture(texture)
}

NewCube :: proc(pos: rl.Vector3, rot: rl.Vector3, size: rl.Vector3, type := CubeType.WALL, room_number := int(0), 
force := false, special_prop := SpecialProperty.NONE) -> Object {
	cube_model: rl.Model
	if model, ok := cube_model_cache[size]; ok do cube_model = model; else do cube_model = GetCubeModel(size)
	
	#partial switch(type) {
		case .WALL: AssignWallTextures(&cube_model)
		case .FLOOR: AssignFloorTextures(&cube_model)
	}
	
	box := GetCubeOBB(pos, rot, size, .XYZ)
	
	//return NewObject(floor_model, pos, {}, 1, {.NORMAL, .HEIGHT, .TILING}, true, name, room_number = room_number, force_draw = force)
	return NewObject(pos, rot, 1, cube_model, box, .XYZ, {true, force, true}, {.NORMAL, .TILING}, room_number = room_number,
		special_prop = special_prop)
}

AssignFloorTextures :: proc(model: ^rl.Model) {
	AssignShader(model, material_shader, 0)
	AssignTexture(model, floor_textures[0], .ALBEDO, 0)
	AssignTexture(model, floor_textures[1], .NORMAL, 0)
	AssignTexture(model, floor_textures[2], .ROUGHNESS, 0)
	AssignTexture(model, floor_textures[3], .HEIGHT, 0)
}

AssignWallTextures :: proc(model: ^rl.Model) {
	AssignShader(model, material_shader, 0)
	AssignTexture(model, wall_textures[0], .ALBEDO, 0)
	AssignTexture(model, wall_textures[1], .NORMAL, 0)
	AssignTexture(model, wall_textures[2], .ROUGHNESS, 0)
	AssignTexture(model, wall_textures[3], .HEIGHT, 0)
}

GetCubeOBB :: proc(pos: rl.Vector3, rot: rl.Vector3, scale: rl.Vector3, order: MatrixRotationOrder) -> OBB {
	rm := MatrixRotateGeneral(rot, order)
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


