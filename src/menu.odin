package bb3d

import rl "vendor:raylib"

// Gamestates & Menus

GameState :: enum{ MAIN, PLAYING, SETTINGS, INFO, CREDITS, PAUSED, DEAD }
game_state := GameState.MAIN

ChangeGameState :: proc(new_game_state: GameState) {
	old_game_state := game_state
	game_state = new_game_state
	if(new_game_state == .PLAYING) {
		rl.DisableCursor()
	} else {
		rl.EnableCursor()
		light_position = {0, 0.5, 0}
		if(new_game_state != .PAUSED) do is_light_on = true 
		if(old_game_state == .PAUSED && new_game_state == .MAIN) do main_bg_camera = rl.Camera{{-2.43, 0.4951, -2.167}, 
			{-1.461, 0.5351, -1.924}, {0, 1, 0}, 60, .PERSPECTIVE}
	}
}

InitMenus :: proc() {
	InitMainBackground()
	InitMainMenu()
	InitDefaultBackButton()
	InitPausedMenu()
	InitDeadMenu()
}

UpdateMenus :: proc() {
	#partial switch(game_state) {
		case .MAIN: UpdateMainMenu()
		case .SETTINGS: UpdateSettingsMenu()
		case .INFO: UpdateInfoMenu()
		case .CREDITS: UpdateCreditsMenu()
		case .PAUSED: UpdatePausedMenu()
		case .DEAD: UpdateDeadMenu()
	}
}

DrawMenus :: proc() {
	if(game_state != .MAIN && game_state != .PLAYING && game_state != .DEAD) do rl.DrawRectangle(0, 0, i32(SCREEN_SIZE.x), i32(SCREEN_SIZE.y), {0, 0, 0, 100})
	#partial switch(game_state) {
		case .MAIN: DrawMainMenu()
		case .SETTINGS: DrawSettingsMenu()
		case .INFO: DrawInfoMenu()
		case .CREDITS: DrawCreditsMenu()
		case .PAUSED: DrawPausedMenu()
		case .DEAD: DrawDeadMenu()
	}
}

// Main Background

main_bg_camera := rl.Camera{{-2.43, 0.4951, -2.167}, {-1.461, 0.5351, -1.924}, {0, 1, 0}, 60, .PERSPECTIVE}
main_bg_objects: [dynamic]Object

InitMainBackground :: proc() {
	append(&main_bg_objects, NewBlob({2, 0, 2}, {0, 25, 0}, 1, "MainMenuBlob", true))
	append(&main_bg_objects, NewFloor({0, -0.01, 0}, {50, 0.01, 50}, "MainMenuFloor", true))
}

UpdateMainBackground :: proc() {
	ROTATION_SPEED :: 0.003
	offset := main_bg_camera.position - main_bg_camera.target
    angle := ROTATION_SPEED * f32(rl.GetFrameTime())
    main_bg_camera.position = main_bg_camera.target + {offset.x * cos(angle) - offset.z * sin(angle), offset.y, offset.x * sin(angle) + offset.z * cos(angle)}
}

// Main Menu

main_menu_buttons: [5]Button

InitMainMenu :: proc() {
	main_menu_buttons = [?]Button{
		NewButtonDefLeft("PLAY", 0, proc() { ChangeGameState(.PLAYING); ResetGame() }),
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
	SMALL_TEXT_BUFFER :: 10
	SMALL_TEXT_FONT_SIZE :: 24
	DrawText(VERSION, {SMALL_TEXT_BUFFER, SCREEN_SIZE.y - (SMALL_TEXT_BUFFER + SMALL_TEXT_FONT_SIZE) * 2}, SMALL_TEXT_FONT_SIZE, 3, .CHANGA_ONE, .ITALIC)
	DrawText("Made By MrBeelo", {SMALL_TEXT_BUFFER, SCREEN_SIZE.y - (SMALL_TEXT_BUFFER + SMALL_TEXT_FONT_SIZE)}, SMALL_TEXT_FONT_SIZE, 3, .CHANGA_ONE, .ITALIC)
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
	
	strings := [?]string{
		"Hey!",
		"What you're playing right now is a (roblox) Grace clone, made in Raylib and Odin!",
		"I'm calling it a \"clone\" because it's super super inspired from the game,",
		"even though it has many differences in gameplay and everything else.",
		"All the \"characters\" (e.g. Blob, Fred, etc.) came from different kinds of projects",
		"I (and some buddies) have been making over the past few years.",
		"While this was made primarily to test making games in Odin (which I love), I do hope",
		"this gets expanded to a \"full\" game.",
		"",
		"CONTROLS:",
		"WASD - Move",
		"Space - Jump",
		"Left Shift / Right Mouse Button - Sprint",
		"Left Control / C - Crouch",
		"F - Close / Open Flashlight"
	}
	
	for str, index in strings {
		FONT_SIZE :: 24
		FONT_SPACING :: 4
		text_size := MeasureText(str, FONT_SIZE, FONT_SPACING, .CHANGA_ONE, .REGULAR)
		pos := rl.Vector2{SCREEN_SIZE.x / 2 - text_size.x / 2, 300 + f32(index) * 30}
		DrawText(str, pos, FONT_SIZE, FONT_SPACING, .CHANGA_ONE, .REGULAR)
	}
}

// Credits Menu

UpdateCreditsMenu :: proc() {
	UpdateButton(&default_back_button)
}

DrawCreditsMenu :: proc() {
	DrawTitle("CREDITS")
	DrawButton(&default_back_button)
	
	strings := [?]string{
		"Full credits can be found in the credits.txt file in the res folder.",
		"These are just the names of the people who made these assets, the links to their",
		"work can be found in the credits.txt file",
		"",
		"MODELS / TEXTURES",
		"Skybox by Screaming Brain Studios",
		"Flashlight model by Juan111",
		"Brick textures by Rob Tuytel",
		"Tile textures by Charlotte Baglioni",
		"",
		"SOUND EFFECTS",
		"Walking/Running/Jumping by NOX Sound",
		"UI Sounds by Nathan Gibson and JDSherbert",
		"Other sounds by Chequered Ink",
		"",
		"OTHER",
		"Font by Eduardo Tunni",
		"Framework (Raylib) by raysan5",
		"Language (Odin Lang) by Ginger Bill",
		"",
		"Almost everything else has been made by me! (might've forgot something lol)"
	}
	
	for str, index in strings {
		FONT_SIZE :: 24
		FONT_SPACING :: 4
		text_size := MeasureText(str, FONT_SIZE, FONT_SPACING, .CHANGA_ONE, .REGULAR)
		pos := rl.Vector2{SCREEN_SIZE.x / 2 - text_size.x / 2, 250 + f32(index) * 30}
		DrawText(str, pos, FONT_SIZE, FONT_SPACING, .CHANGA_ONE, .REGULAR)
	}
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

// Dead Menu

dead_menu_buttons: [2]Button

InitDeadMenu :: proc() {
	X_BUFFER :: 250
	Y_BUFFER :: 250
	dead_menu_buttons = [?]Button{
		NewButton("PLAY AGAIN", {SCREEN_SIZE.x / 2 - X_BUFFER, SCREEN_SIZE.y - Y_BUFFER}, proc() { ChangeGameState(.PLAYING); ResetGame() }),
		NewButton("LEAVE", {SCREEN_SIZE.x / 2 + X_BUFFER, SCREEN_SIZE.y - Y_BUFFER}, proc() { ChangeGameState(.MAIN) }),
	}
}

UpdateDeadMenu :: proc() {
	for &button in (dead_menu_buttons) do UpdateButton(&button)
}

DrawDeadMenu :: proc() {
	DrawDeathSequence()
	if(GetRemainingTime(&death_sequence_timer) <= 8) do DrawTitle("YOU DIED")
	if(GetRemainingTime(&death_sequence_timer) <= 3) do for &button in (dead_menu_buttons) do DrawButton(&button)
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
	hovered: bool,
	font_name: FontName,
	font_type: FontType
}

NewButton :: proc(text: string, center_pos: rl.Vector2, function: proc(), font_name := FontName.CHANGA_ONE, font_type := FontType.REGULAR) -> Button {
	return Button{text, BUTTON_FONT_SIZE.x, BUTTON_FONT_SPACING.x, center_pos, function, false, font_name, font_type}
}

NewButtonDefLeft :: proc(text: string, index: int, function: proc(), font_name := FontName.CHANGA_ONE, font_type := FontType.REGULAR) -> Button {
	pos := rl.Vector2{300, 400 + f32(index) * 80}
	return NewButton(text, pos, function, font_name, font_type)
}

NewButtonDefCenter :: proc(text: string, index: int, function: proc(), font_name := FontName.CHANGA_ONE, font_type := FontType.REGULAR) -> Button {
	text_size := MeasureText(text, BUTTON_FONT_SIZE.x, BUTTON_FONT_SPACING.x, font_name, font_type)
	pos := rl.Vector2{SCREEN_SIZE.x / 2, 600 + f32(index) * 80}
	return NewButton(text, pos, function, font_name, font_type)
}

UpdateButton :: proc(self: ^Button) {
	was_hovered := self.hovered
	text_size := MeasureText(self.text, self.font_size, self.font_spacing, self.font_name, self.font_type)
	top_left_pos := self.center_pos - (text_size / 2)
	button_rect := rl.Rectangle{top_left_pos.x, top_left_pos.y, text_size.x, text_size.y}
	mouse_pos := rl.GetMousePosition()
	self.hovered = rl.CheckCollisionPointRec(mouse_pos, button_rect)
	if(self.hovered && !was_hovered) do rl.PlaySound(ui_hover_sound)
	
	if(self.hovered && self.font_size < BUTTON_FONT_SIZE.y) do self.font_size += rl.GetFrameTime() * 100
	if(!self.hovered && self.font_size > BUTTON_FONT_SIZE.x) do self.font_size -= rl.GetFrameTime() * 100
	if(self.hovered && self.font_spacing < BUTTON_FONT_SPACING.y) do self.font_spacing += rl.GetFrameTime() * 100
	if(!self.hovered && self.font_spacing > BUTTON_FONT_SPACING.x) do self.font_spacing -= rl.GetFrameTime() * 100
	
	if(self.hovered && rl.IsMouseButtonPressed(.LEFT)) {
		self.function()
		rl.PlaySound(ui_click_sound)
	}
}

DrawButton :: proc(self: ^Button) {
	text_size := MeasureText(self.text, self.font_size, self.font_spacing, .CHANGA_ONE, .REGULAR)
	top_left_pos := self.center_pos - (text_size / 2)
	DrawTextShakyBordered(self.text, top_left_pos, self.font_size, self.font_spacing, 3, .CHANGA_ONE, .REGULAR)
}

MeasureButtonText :: proc(self: ^Button) -> rl.Vector2 {
	return MeasureText(self.text, self.font_size, self.font_spacing, .CHANGA_ONE, .REGULAR)
}

// Titles

DrawTitle :: proc(text: string) {
	TITLE_TEXT_FONT_SIZE :: 64
	TITLE_TEXT_FONT_SPACING :: 5
	text_size := MeasureText(text, TITLE_TEXT_FONT_SIZE, TITLE_TEXT_FONT_SPACING, .CHANGA_ONE, .REGULAR)
	pos := rl.Vector2{SCREEN_SIZE.x / 2 - text_size.x / 2, 100}
	DrawTextBordered(text, pos, TITLE_TEXT_FONT_SIZE, TITLE_TEXT_FONT_SPACING, 5, .CHANGA_ONE, .REGULAR)
}

DrawSubtitle :: proc(text: string) {
	SUBTITLE_TEXT_FONT_SIZE :: 24
	SUBTITLE_TEXT_FONT_SPACING :: 5
	text_size := MeasureText(text, SUBTITLE_TEXT_FONT_SIZE, SUBTITLE_TEXT_FONT_SPACING, .CHANGA_ONE, .REGULAR)
	pos := rl.Vector2{SCREEN_SIZE.x / 2 - text_size.x / 2, 180}
	DrawTextBordered(text, pos, SUBTITLE_TEXT_FONT_SIZE, SUBTITLE_TEXT_FONT_SPACING, 3, .CHANGA_ONE, .REGULAR)
}