package bg3d

import rl "vendor:raylib"

GetVMousePos :: proc() -> rl.Vector2 {
	window_size := rl.Vector2{f32(rl.GetScreenWidth()), f32(rl.GetScreenHeight())}
	scale := min(window_size.x / SCREEN_SIZE.x, window_size.y / SCREEN_SIZE.y)
	vmouse_x := (f32(rl.GetMouseX()) - (window_size.x - (SCREEN_SIZE.x * scale)) * 0.5) / scale;
    vmouse_y := (f32(rl.GetMouseY()) - (window_size.y - (SCREEN_SIZE.y * scale)) * 0.5) / scale;
    return rl.Vector2{clamp(vmouse_x, 0, SCREEN_SIZE.x), clamp(vmouse_y, 0, SCREEN_SIZE.y)};
}