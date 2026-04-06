package bb3d

import rl "vendor:raylib"

// Gamestates & Menus

GameState :: enum{ MAIN, PLAYING, SETTINGS, INFO, CREDITS, PAUSED }
game_state := GameState.MAIN

ChangeGameState :: proc(new_game_state: GameState) {
	game_state = new_game_state
	if(new_game_state == .PLAYING) {
		rl.DisableCursor()
	} else {
		rl.EnableCursor()
		light_position = {0, 0.5, 0}
		if(new_game_state != .PAUSED) do is_light_on = true
	}
}

InitMenus :: proc() {
	InitMainBackground()
	InitMainMenu()
	InitDefaultBackButton()
	InitPausedMenu()
}

UpdateMenus :: proc() {
	#partial switch(game_state) {
		case .MAIN: UpdateMainMenu()
		case .SETTINGS: UpdateSettingsMenu()
		case .INFO: UpdateInfoMenu()
		case .CREDITS: UpdateCreditsMenu()
		case .PAUSED: UpdatePausedMenu()
	}
}

DrawMenus :: proc() {
	#partial switch(game_state) {
		case .MAIN: DrawMainMenu()
		case .SETTINGS: DrawSettingsMenu()
		case .INFO: DrawInfoMenu()
		case .CREDITS: DrawCreditsMenu()
		case .PAUSED: DrawPausedMenu()
	}
}

// Main Background

main_bg_camera := rl.Camera{{-2.43, 0.4951, -2.167}, {-1.461, 0.5351, -1.924}, {0, 1, 0}, 60, .PERSPECTIVE}
main_bg_objects: [dynamic]Object

InitMainBackground :: proc() {
	append(&main_bg_objects, NewBlob({2, 0, 2}, {0, 25, 0}, 1, "MainMenuBlob", true))
	append(&main_bg_objects, NewFloor(50, "MainMenuFloor", true))
}

// Main Menu

main_menu_buttons: [5]Button

InitMainMenu :: proc() {
	main_menu_buttons = [?]Button{
		NewButtonDefLeft("PLAY", 0, proc() { ChangeGameState(.PLAYING) }),
		NewButtonDefLeft("SETTINGS", 1, proc() { ChangeGameState(.SETTINGS) }),
		NewButtonDefLeft("INFO", 2, proc() { ChangeGameState(.INFO) }),
		NewButtonDefLeft("CREDITS", 3, proc() { ChangeGameState(.CREDITS) }),
		NewButtonDefLeft("LEAVE", 4, proc() { should_exit = true }),
	}
}

UpdateMainMenu :: proc() {
	for &button in (main_menu_buttons) do UpdateButton(&button)
}

DrawMainMenu :: proc() {
	DrawTitle("BLOB GAME 3D")
	for &button in (main_menu_buttons) do DrawButton(&button)
}

// Default Back Button

default_back_button: Button

InitDefaultBackButton :: proc() {
	default_back_button = NewButton("BACK", {SCREEN_SIZE.x / 2, SCREEN_SIZE.y * 9 / 10}, proc() { ChangeGameState(.MAIN) })
}

// Settings Menu

UpdateSettingsMenu :: proc() {
	UpdateButton(&default_back_button)
}

DrawSettingsMenu :: proc() {
	DrawTitle("SETTINGS (UNFINISHED)")
	DrawButton(&default_back_button)
}

// Info Menu

UpdateInfoMenu :: proc() {
	UpdateButton(&default_back_button)
}

DrawInfoMenu :: proc() {
	DrawTitle("INFO")
	DrawButton(&default_back_button)
}

// Credits Menu

UpdateCreditsMenu :: proc() {
	UpdateButton(&default_back_button)
}

DrawCreditsMenu :: proc() {
	DrawTitle("CREDITS")
	DrawButton(&default_back_button)
}

// Paused Menu

paused_menu_buttons: [2]Button

InitPausedMenu :: proc() {
	paused_menu_buttons = [?]Button{
		NewButtonDefCenter("CONTINUE", 0, proc() { ChangeGameState(.PLAYING) }),
		NewButtonDefCenter("BACK TO MAIN MENU", 1, proc() { ChangeGameState(.MAIN) }),
	}
}

UpdatePausedMenu :: proc() {
	for &button in (paused_menu_buttons) do UpdateButton(&button)
}

DrawPausedMenu :: proc() {
	DrawTitle("PAUSED")
	DrawSubtitle("A bit tired, huh?")
	for &button in (paused_menu_buttons) do DrawButton(&button)
}

// Buttons

BUTTON_FONT_SIZE :: rl.Vector2{48, 64} // not hovered, hovered
BUTTON_FONT_SPACING :: rl.Vector2{5, 10} // not hovered, hovered

Button :: struct {
	text: string,
	font_size: f32,
	font_spacing: f32,
	center_pos: rl.Vector2, 
	function: proc(),
	hovered: bool
}

NewButton :: proc(text: string, center_pos: rl.Vector2, function: proc()) -> Button {
	return Button{text, BUTTON_FONT_SIZE.x, BUTTON_FONT_SPACING.x, center_pos, function, false}
}

NewButtonDefLeft :: proc(text: string, index: int, function: proc()) -> Button {
	pos := rl.Vector2{300, 400 + f32(index) * 80}
	return NewButton(text, pos, function)
}

NewButtonDefCenter :: proc(text: string, index: int, function: proc()) -> Button {
	text_size := rl.MeasureTextEx(rl.GetFontDefault(), to_cstr(text), BUTTON_FONT_SIZE.x, BUTTON_FONT_SPACING.x)
	pos := rl.Vector2{SCREEN_SIZE.x / 2, 600 + f32(index) * 80}
	return NewButton(text, pos, function)
}

UpdateButton :: proc(self: ^Button) {
	text_size := rl.MeasureTextEx(rl.GetFontDefault(), to_cstr(self.text), self.font_size, 0)
	top_left_pos := self.center_pos - (text_size / 2)
	button_rect := rl.Rectangle{top_left_pos.x, top_left_pos.y, text_size.x, text_size.y}
	mouse_pos := rl.GetMousePosition()
	self.hovered = rl.CheckCollisionPointRec(mouse_pos, button_rect)
	
	if(self.hovered && self.font_size < BUTTON_FONT_SIZE.y) do self.font_size += rl.GetFrameTime() * 100
	if(!self.hovered && self.font_size > BUTTON_FONT_SIZE.x) do self.font_size -= rl.GetFrameTime() * 100
	if(self.hovered && self.font_spacing < BUTTON_FONT_SPACING.y) do self.font_spacing += rl.GetFrameTime() * 100
	if(!self.hovered && self.font_spacing > BUTTON_FONT_SPACING.x) do self.font_spacing -= rl.GetFrameTime() * 100
	
	if(self.hovered && rl.IsMouseButtonPressed(.LEFT)) do self.function()
}

DrawButton :: proc(self: ^Button) {
	text_size := rl.MeasureTextEx(rl.GetFontDefault(), to_cstr(self.text), self.font_size, self.font_spacing)
	top_left_pos := self.center_pos - (text_size / 2)
	rl.DrawTextEx(rl.GetFontDefault(), to_cstr(self.text), top_left_pos, self.font_size, self.font_spacing, rl.WHITE)
}

// Title

DrawTitle :: proc(text: string) {
	TITLE_TEXT_FONT_SIZE :: 64
	TITLE_TEXT_FONT_SPACING :: 5
	text_size := rl.MeasureTextEx(rl.GetFontDefault(), to_cstr(text), TITLE_TEXT_FONT_SIZE, TITLE_TEXT_FONT_SPACING)
	pos := rl.Vector2{SCREEN_SIZE.x / 2 - text_size.x / 2, 100}
	rl.DrawTextEx(rl.GetFontDefault(), to_cstr(text), pos, TITLE_TEXT_FONT_SIZE, TITLE_TEXT_FONT_SPACING, rl.WHITE)
}

DrawSubtitle :: proc(text: string) {
	SUBTITLE_TEXT_FONT_SIZE :: 24
	SUBTITLE_TEXT_FONT_SPACING :: 5
	text_size := rl.MeasureTextEx(rl.GetFontDefault(), to_cstr(text), SUBTITLE_TEXT_FONT_SIZE, SUBTITLE_TEXT_FONT_SPACING)
	pos := rl.Vector2{SCREEN_SIZE.x / 2 - text_size.x / 2, 180}
	rl.DrawTextEx(rl.GetFontDefault(), to_cstr(text), pos, SUBTITLE_TEXT_FONT_SIZE, SUBTITLE_TEXT_FONT_SPACING, rl.WHITE)
}