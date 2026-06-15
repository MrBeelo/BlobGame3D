package bg3d

import rl "vendor:raylib"
import "core:strings"

// Gamestates & Menus

GameState :: enum{ MAIN, PLAYING, INFO, CREDITS, PAUSED, DEAD, COMMAND, SAFEROOM_ENTER, SAFEROOM, SAFEROOM_EXIT }
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

IsInMainGame :: proc() -> bool { return game_state == .PLAYING }
IsInDeathSequence :: proc() -> bool { return game_state == .DEAD }
CanSeeMainGame :: proc() -> bool { return game_state == .PLAYING || game_state == .PAUSED || game_state == .COMMAND || game_state == .SAFEROOM_ENTER }
CanSeeMainBackground :: proc() -> bool { return game_state == .MAIN || game_state == .INFO || game_state == .CREDITS }

InitMenus :: proc() {
	InitMainBackground()
	InitMainMenu()
	InitDefaultBackButton()
	InitPausedMenu()
	InitDeadMenu()
	InitSaferoomMenu()
}

UpdateMenus :: proc() {
	#partial switch(game_state) {
		case .MAIN: UpdateMainMenu()
		case .INFO: UpdateInfoMenu()
		case .CREDITS: UpdateCreditsMenu()
		case .PAUSED: UpdatePausedMenu()
		case .DEAD: UpdateDeadMenu()
		case .COMMAND: UpdateCommandMenu()
		case .SAFEROOM_ENTER: UpdateSaferoomStartSequence()
		case .SAFEROOM: UpdateSaferoomMenu()
		case .SAFEROOM_EXIT: UpdateSaferoomEndSequence()
	}
}

DrawMenus :: proc() {
	if(game_state != .MAIN && game_state != .PLAYING && game_state != .COMMAND && game_state != .DEAD) do rl.DrawRectangle(0, 0, i32(SCREEN_SIZE.x), i32(SCREEN_SIZE.y), {0, 0, 0, 100})
	#partial switch(game_state) {
		case .MAIN: DrawMainMenu()
		case .INFO: DrawInfoMenu()
		case .CREDITS: DrawCreditsMenu()
		case .PAUSED: DrawPausedMenu()
		case .DEAD: DrawDeadMenu()
		case .COMMAND: DrawCommandMenu()
		case .SAFEROOM_ENTER: DrawSaferoomStartSequence()
		case .SAFEROOM: DrawSaferoomMenu()
		case .SAFEROOM_EXIT: DrawSaferoomEndSequence()
	}
}

// Main Background

main_bg_camera := rl.Camera{{-2.43, 0.4951, -2.167}, {-1.461, 0.5351, -1.924}, {0, 1, 0}, 60, .PERSPECTIVE}
main_bg_objects: [dynamic]Object

InitMainBackground :: proc() {
	append(&main_bg_objects, NewBlob({2, 0, 2}, {0, 25, 0}, 1, MAX_NUM, true))
	append(&main_bg_objects, NewCube({0, -0.01, 0}, {}, {50, 0.01, 50}, .FLOOR, MAX_NUM, true))
}

UpdateMainBackground :: proc() {
	ROTATION_SPEED :: 0.003
	offset := main_bg_camera.position - main_bg_camera.target
    angle := ROTATION_SPEED * f32(rl.GetFrameTime())
    main_bg_camera.position = main_bg_camera.target + {offset.x * cos(angle) - offset.z * sin(angle), offset.y, offset.x * sin(angle) + offset.z * cos(angle)}
}

// Main Menu

main_menu_buttons: [4]Button

InitMainMenu :: proc() {
	main_menu_buttons = [?]Button{
		NewButtonDefLeft("PLAY", 0, proc() { ChangeGameState(.PLAYING); ResetGame() }),
		NewButtonDefLeft("INFO", 1, proc() { ChangeGameState(.INFO) }),
		NewButtonDefLeft("CREDITS", 2, proc() { ChangeGameState(.CREDITS) }),
		NewButtonDefLeft("LEAVE", 3, proc() { should_exit = true }),
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
		"UI Sounds by Nathan Gibson, JDSherbert, and PetarS",
		"Other sounds by Chequered Ink",
		"",
		"OTHER",
		"Fonts by Eduardo Tunni, Rodrigo Fuenzalida and Jordan Egstad",
		"Framework (Raylib) by raysan5",
		"Language (Odin) by Ginger Bill",
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
	if(GetRemainingTime(&death_sequence_timer) <= 2) do for &button in (dead_menu_buttons) do UpdateButton(&button)
}

DrawDeadMenu :: proc() {
	DrawDeathSequence()
	if(GetRemainingTime(&death_sequence_timer) <= 8) do DrawTitle("YOU DIED")
	if(GetRemainingTime(&death_sequence_timer) <= 2) do for &button in (dead_menu_buttons) do DrawButton(&button)
}

// Command Menu

cmd_text := ""
past_texts: [dynamic]string
past_text_index: int

UpdateCommandMenu :: proc() {
	char_pressed := rl.GetCharPressed()
	cmd_text = concat({cmd_text, to_string(char_pressed)})
	if(rl.IsKeyPressed(.BACKSPACE)) do cmd_text = string_pop(cmd_text)
	if(rl.IsKeyPressed(.RIGHT_SHIFT)) do cmd_text = ""
	if(rl.IsKeyPressed(.ENTER)) {
		ChangeGameState(.PLAYING)
		append(&past_texts, cmd_text)
		past_text_index = -1
		args := strings.split(cmd_text, " ")
		if(len(args) == 0) do return
		print("GAME: Recieved command with arguments: %v\n", args)
		
		switch(args[0]) {
			case "kill": BeginDeathSequence()
			case "health": {
				val := Parse(args[2], f32)
				if(args[1] == "set") do player.health = val
				if(args[1] == "add") do player.health += val
			}
			case "time": {
				val := Parse(args[2], f32)
				if(args[1] == "set") do SetClockSeconds(val)
				if(args[1] == "add") do AddClockSeconds(val)
			}
			case "points": {
				val := Parse(args[2], int)
				if(args[1] == "set") do run_stats.points = val
				if(args[1] == "add") do run_stats.points += val
			}
			case "saferoom": if(IsInMainGame()) do BeginSaferoomStartSequence()
		}
		
		cmd_text = ""
	}
	
	if(rl.IsKeyPressed(.UP)) {
		if(past_text_index == -1) {
			cmd_text = past_texts[len(past_texts) - 1]
			past_text_index = len(past_texts) - 1
		} else if(past_text_index > 0) {
			cmd_text = past_texts[past_text_index - 1]
			past_text_index -= 1
		}
	} else if(rl.IsKeyPressed(.DOWN)) {
		if(past_text_index >= 0 && past_text_index < len(past_texts) - 1) {
			cmd_text = past_texts[past_text_index + 1]
			past_text_index += 1
		} else {
			cmd_text = ""
			past_text_index = -1
		}
	}
}

DrawCommandMenu :: proc() {
	BUFFER :: 10
	HEIGHT :: 60
	BOX_OPACITY :: 100
	FONT_SIZE :: 56
	FONT_SPACING :: 1
	POS: rl.Vector2 : {BUFFER + 10, SCREEN_SIZE.y - BUFFER - HEIGHT}
	rl.DrawRectangle(BUFFER, i32(SCREEN_SIZE.y) - BUFFER - HEIGHT, i32(SCREEN_SIZE.x) - BUFFER * 2, HEIGHT, {0, 0, 0, BOX_OPACITY})
	DrawText(cmd_text, POS, FONT_SIZE, FONT_SPACING, .CHANGA_ONE, .REGULAR, rl.WHITE)
	size := MeasureText(cmd_text, FONT_SIZE, FONT_SPACING)
	rl.DrawLineEx({POS.x + size.x + BUFFER, POS.y + BUFFER}, {POS.x + size.x + BUFFER, POS.y + HEIGHT - BUFFER}, 3, rl.WHITE)
}

// Saferoom Menu

saferoom_menu_buttons: [1]Button
saferoom_menu_upgrades: [3]UpgradeButton

InitSaferoomMenu :: proc() {
	saferoom_menu_buttons = [?]Button{
		NewButton("CONTINUE", {SCREEN_SIZE.x / 2, SCREEN_SIZE.y * 9 / 10}, proc() { BeginSaferoomEndSequence() }),
	}
	
	X_OFFSET :: 50
	Y_OFFSET :: 150
	saferoom_menu_upgrades = [?]UpgradeButton{
		NewUpgradeButton(SCREEN_SIZE / 2 + {-UPGRADE_BUTTON_SIZE.x - X_OFFSET, Y_OFFSET}, 0),
		NewUpgradeButton(SCREEN_SIZE / 2 + {0, Y_OFFSET}, 0),
		NewUpgradeButton(SCREEN_SIZE / 2 + {UPGRADE_BUTTON_SIZE.x + X_OFFSET, Y_OFFSET}, 0)
	}
}

UpdateSaferoomMenu :: proc() {
	for &button in saferoom_menu_buttons do UpdateButton(&button)
	for &upgrade_button in saferoom_menu_upgrades do UpdateUpgradeButton(&upgrade_button)
}

DrawSaferoomMenu :: proc() {
	interval := Interval(0.2)
	source := rl.Rectangle{0, 0, f32(blob_row.width), f32(blob_row.height)}
	rl.DrawTexturePro(blob_row, source, {-BLOB_ROW_SIZE.y * interval, 0, BLOB_ROW_SIZE.x, BLOB_ROW_SIZE.y}, {}, 0, {50, 50, 50, 255})
	rl.DrawTexturePro(blob_row, source, {SCREEN_SIZE.x - BLOB_ROW_SIZE.x + BLOB_ROW_SIZE.y * interval, SCREEN_SIZE.y - BLOB_ROW_SIZE.y, 
		BLOB_ROW_SIZE.x, BLOB_ROW_SIZE.y}, {}, 0, {50, 50, 50, 255})
	
	DrawTextCenterX(concat({"--- SAFEROOM ", to_string(run_stats.saferooms), " ---"}), 70, 96, 5, .INSTRUMENT_SERIF)
	DrawSubtitle("Take a break, you need it...", .INSTRUMENT_SERIF)
	DrawTextCenterX(concat({FloatToTimeStr(GetRemainingClockTime()), " - ", to_string(player.health), "hp - ",
		to_string(run_stats.points), "p"}), 300, 64, 5, .INSTRUMENT_SERIF, .REGULAR)
	DrawTextCenterX("- UPGRADES -", 430, 64, 5, .INSTRUMENT_SERIF)
	
	for &button in saferoom_menu_buttons do DrawButton(&button)
	for &upgrade_button in saferoom_menu_upgrades do DrawUpgradeButton(&upgrade_button)
}