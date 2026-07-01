#+feature dynamic-literals

package bg3d

import hlp "helper"
import "core:math"
import rl "vendor:raylib"

// Gamestates & Menus

GameState :: enum{ MAIN, PLAYING, INFO, CREDITS, PAUSED, DEAD, COMMAND, SAFEROOM_ENTER, SAFEROOM, SAFEROOM_CHECK, SAFEROOM_EXIT }
game_state := GameState.MAIN
menus: map[GameState]Menu

Menu :: struct {
	buttons: []Button,
	init: proc(buttons: []Button),
	update: proc(buttons: []Button),
	draw: proc(buttons: []Button),
}

NewMenu :: proc(
	buttons := []Button{},
	init := proc(buttons: []Button) {},
	update := proc(buttons: []Button) { for &button in buttons do UpdateButton(&button) },
	draw := proc(buttons: []Button) { for &button in buttons do DrawButton(&button) },
) -> Menu {
	btns := make([]Button, len(buttons))
	copy(btns, buttons)
	return {btns, init, update, draw} 
}

ChangeGameState :: proc(new_game_state: GameState) {
	old_game_state := game_state
	game_state = new_game_state
	if new_game_state == .PLAYING {
		rl.DisableCursor()
	} else {
		if old_game_state == .PLAYING do rl.EnableCursor()
		light_position = {0, 0.5, 0}
		if new_game_state != .PAUSED do is_light_on = true 
		if old_game_state == .PAUSED && new_game_state == .MAIN do main_bg_camera = rl.Camera{{-2.43, 0.4951, -2.167}, 
			{-1.461, 0.5351, -1.924}, {0, 1, 0}, 60, .PERSPECTIVE}
	}

	ResetButton :: proc(button: ^Button) { button.hovered = false; button.font_size = button.font_sizes.x }
	for _, menu in menus do for &button in menu.buttons do ResetButton(&button)
}

IsInMainGame :: proc() -> bool { return game_state == .PLAYING }
IsInDeathSequence :: proc() -> bool { return game_state == .DEAD }
IsInSaferoom :: proc() -> bool { return game_state == .SAFEROOM || game_state == .SAFEROOM_CHECK }
CanSeeMainGame :: proc() -> bool { return game_state == .PLAYING || game_state == .PAUSED || game_state == .COMMAND || game_state == .SAFEROOM_ENTER }
CanSeeMainBackground :: proc() -> bool { return game_state == .MAIN || game_state == .INFO || game_state == .CREDITS }

InitMenus :: proc() {
	menus = make(map[GameState]Menu)
	InitMainBackground()

	menus = map[GameState]Menu {
		.MAIN = MainMenu(),
		.PLAYING = NewMenu(),
		.INFO = InfoMenu(),
		.CREDITS = CreditsMenu(),
		.PAUSED = PausedMenu(),
		.DEAD = DeadMenu(),
		.COMMAND = CommandMenu(),
		.SAFEROOM_ENTER = SaferoomEnterSequence(),
		.SAFEROOM = SaferoomMenu(),
		.SAFEROOM_CHECK = SaferoomCheckMenu(),
		.SAFEROOM_EXIT = SaferoomExitSequence(),
	}

	for _, menu in menus do menu.init(menu.buttons)
}

UpdateMenus :: proc() {
	if game_state != .PLAYING do menus[game_state].update(menus[game_state].buttons)
}

DrawMenus :: proc() {
	if game_state != .PLAYING do menus[game_state].draw(menus[game_state].buttons)
}

MainMenu :: proc() -> Menu { return NewMenu(
	buttons = []Button{
		NewButtonDefLeft("PLAY", 0, proc() { BeginSaferoomExitSequence() }),
		NewButtonDefLeft("INFO", 1, proc() { ChangeGameState(.INFO) }),
		NewButtonDefLeft("CREDITS", 2, proc() { ChangeGameState(.CREDITS) }),
		NewButtonDefLeft("LEAVE", 3, proc() { should_close = true }),
	},
	draw = proc(buttons: []Button) {
		DrawTitle("BLOB GAME 3D")
		for &button in buttons do DrawButton(&button)
		SMALL_TEXT_BUFFER :: 10
		SMALL_TEXT_FONT_SIZE :: 24
		DrawTextStatic(VERSION, {SMALL_TEXT_BUFFER, SCREEN_SIZE.y - (SMALL_TEXT_BUFFER + SMALL_TEXT_FONT_SIZE) * 2}, SMALL_TEXT_FONT_SIZE, 3, .CHANGA_ONE, .ITALIC)
		DrawTextStatic("Made By MrBeelo", {SMALL_TEXT_BUFFER, SCREEN_SIZE.y - (SMALL_TEXT_BUFFER + SMALL_TEXT_FONT_SIZE)}, SMALL_TEXT_FONT_SIZE, 3, .CHANGA_ONE, .ITALIC)
	},
)}

InfoMenu :: proc() -> Menu { return NewMenu(
	buttons = []Button{
		NewButton("BACK", {SCREEN_SIZE.x / 2, SCREEN_SIZE.y * 9 / 10}, proc() { ChangeGameState(.MAIN) }),
	},
	draw = proc(buttons: []Button) {
		DrawTitle("INFO")
		for &button in buttons do DrawButton(&button)
		
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
			"F - Close / Open Flashlight",
		}
		
		for str, index in strings {
			FONT_SIZE :: 24
			FONT_SPACING :: 4
			text_size := MeasureText(str, FONT_SIZE, FONT_SPACING, .CHANGA_ONE, .REGULAR)
			pos := rl.Vector2{SCREEN_SIZE.x / 2 - text_size.x / 2, 300 + f32(index) * 30}
			DrawTextStatic(str, pos, FONT_SIZE, FONT_SPACING, .CHANGA_ONE, .REGULAR)
		}
	},
)}

CreditsMenu :: proc() -> Menu { return NewMenu(
	buttons = []Button{
		NewButton("BACK", {SCREEN_SIZE.x / 2, SCREEN_SIZE.y * 9 / 10}, proc() { ChangeGameState(.MAIN) }),
	},
	draw = proc(buttons: []Button) {
		DrawTitle("INFO")
		for &button in buttons do DrawButton(&button)
		
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
			"Almost everything else has been made by me! (might've forgot something lol)",
		}
		
		for str, index in strings {
			FONT_SIZE :: 24
			FONT_SPACING :: 4
			text_size := MeasureText(str, FONT_SIZE, FONT_SPACING, .CHANGA_ONE, .REGULAR)
			pos := rl.Vector2{SCREEN_SIZE.x / 2 - text_size.x / 2, 250 + f32(index) * 30}
			DrawTextStatic(str, pos, FONT_SIZE, FONT_SPACING, .CHANGA_ONE, .REGULAR)
		}
	},
)}

PausedMenu :: proc() -> Menu { return NewMenu(
	buttons = []Button{
		NewButtonDefCenter("CONTINUE", 0, proc() { ChangeGameState(.PLAYING) }),
		NewButtonDefCenter("BACK TO MAIN MENU", 1, proc() { ChangeGameState(.MAIN) }),
	},
	draw = proc(buttons: []Button) {
		DrawTitle("PAUSED")
		DrawSubtitle("A bit tired, huh?")
		for &button in buttons do DrawButton(&button)
	},
)}

// Main Background

main_bg_camera := rl.Camera{{-2.43, 0.4951, -2.167}, {-1.461, 0.5351, -1.924}, {0, 1, 0}, 60, .PERSPECTIVE}
main_bg_objects: [dynamic]Object

InitMainBackground :: proc() {
	append(&main_bg_objects, NewBlob({2, 0, 2}, {0, 25, 0}, 1, hlp.MAX_INT, true, false))
	append(&main_bg_objects, NewCube({0, -0.01, 0}, {}, {50, 0.01, 50}, .FLOOR, hlp.MAX_INT, {true, true, true}))
}

UpdateMainBackground :: proc() {
	ROTATION_SPEED :: 0.003
	offset := main_bg_camera.position - main_bg_camera.target
    angle := ROTATION_SPEED * f32(rl.GetFrameTime())
    main_bg_camera.position = main_bg_camera.target + {offset.x * math.cos(angle) - offset.z * math.sin(angle), 
    	offset.y, offset.x * math.sin(angle) + offset.z * math.cos(angle)}
}