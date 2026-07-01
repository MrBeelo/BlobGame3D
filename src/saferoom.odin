package bg3d

import hlp "helper"
import "core:strings"
import rl "vendor:raylib"

saferoom_start_sequence_timer: hlp.Timer
SAFEROOM_START_SEQUENCE_TIME :: 0.3
saferoom_end_sequence_timer: hlp.Timer
SAFEROOM_END_SEQUENCE_TIME :: f32(1)
blob_row: rl.Texture2D
BLOB_ROW_SIZE :: rl.Vector2{SCREEN_SIZE.y / 2 * 5, SCREEN_SIZE.y / 2}

saferoom_menu_upgrades: [3]UpgradeButton

SaferoomMenu :: proc() -> Menu { return NewMenu(
	buttons = []Button{
		NewButton("CONTINUE", {SCREEN_SIZE.x / 2, SCREEN_SIZE.y * 9 / 10}, proc() { ChangeGameState(.SAFEROOM_CHECK) }),
	},
	init = proc(buttons: []Button) {
		X_OFFSET :: 50
		Y_OFFSET :: 150
		saferoom_menu_upgrades = [?]UpgradeButton{
			NewUpgradeButton(SCREEN_SIZE / 2 + {-UPGRADE_BUTTON_SIZE.x - X_OFFSET, Y_OFFSET}),
			NewUpgradeButton(SCREEN_SIZE / 2 + {0, Y_OFFSET}),
			NewUpgradeButton(SCREEN_SIZE / 2 + {UPGRADE_BUTTON_SIZE.x + X_OFFSET, Y_OFFSET}),
		}
	},
	update = proc(buttons: []Button) {
		for &button in buttons do UpdateButton(&button)
		for &upgrade_button in saferoom_menu_upgrades do UpdateUpgradeButton(&upgrade_button)
	},
	draw = proc(buttons: []Button) {
		DrawSaferoomBackground()
		
		DrawTextCenterX(strings.concatenate({"--- SAFEROOM ", hlp.to_string(run_stats.saferooms), " ---"}), 70, 96, 5, .INSTRUMENT_SERIF)
		DrawSubtitle("Take a break, you need it...", .INSTRUMENT_SERIF)
		DrawTextCenterX(strings.concatenate({hlp.float_to_time_str(GetRemainingClockTime()), " - ", hlp.to_string(int(player.health)), "hp - ",
			hlp.to_string(run_stats.points), "p"}), 300, 64, 5, .INSTRUMENT_SERIF, .REGULAR)
		DrawTextCenterX("- UPGRADES -", 430, 64, 5, .INSTRUMENT_SERIF)
		
		for &button in buttons do DrawButton(&button)
		for &upgrade_button in saferoom_menu_upgrades do DrawUpgradeButton(&upgrade_button)
	},
)}

SaferoomCheckMenu :: proc() -> Menu { return NewMenu(
	buttons = []Button{
		NewButtonDefCenter("DO IT", 0.5, proc() { BeginSaferoomExitSequence() }, .INSTRUMENT_SERIF, .REGULAR, IndividiSpikyAnim{{4, 3}}, 
			rl.RED, {128, 160}),
		NewButtonDefCenter("On second thought...", 3, proc() { ChangeGameState(.SAFEROOM) }, .CHANGA_ONE, .ITALIC, IndividiShakyAnim{{1, 0.75}, 2}, 
			rl.WHITE, {32, 40}),
	},
	update = proc(buttons: []Button) {
		do_it := buttons[0]
		SPIKYNESS_MOD :: f32(4)
		local_resize_state := (do_it.font_size - do_it.font_sizes.x) / (do_it.font_sizes.y - do_it.font_sizes.x) // 0 -> 1
		resize_state := local_resize_state * (SPIKYNESS_MOD - 1) + 1 // 1 -> SPIKYNESS_MOD
		spikyness := rl.Vector2{2, 1.5} * resize_state
		buttons[0].animation = IndividiSpikyAnim{spikyness}
		
		for &button in buttons do UpdateButton(&button)
	},
	draw = proc(buttons: []Button) {
		do_it := buttons[0]
		local_resize_state := (do_it.font_size - do_it.font_sizes.x) / (do_it.font_sizes.y - do_it.font_sizes.x) // 0 -> 1
		background_color := rl.ColorLerp({50, 50, 50, 255}, {166, 46, 46, 255}, local_resize_state)
		
		DrawSaferoomBackground(background_color)
		DrawTextCenterX("--- ARE YOU SURE? ---", 70, 96, 5, .INSTRUMENT_SERIF)

		note: []string
		switch run_stats.saferooms {
		case 1: note = []string{
			"Don't touch the red!",
		}
		case 2: note = []string{
			"When the orange eye opens its gaze",
			"stay where you are",
			"don't move a muscle...",
		}
		}

		if len(note) != 0 {
			NOTE_START :: 230
			DrawTextCenterX("Oh, and also...", NOTE_START, 64, 5, .INSTRUMENT_SERIF, .ITALIC)
			for str, index in note {
				FONT_SIZE :: 48
				text_size := MeasureText(str, FONT_SIZE, 5, .INSTRUMENT_SERIF, .REGULAR)
				pos := rl.Vector2{SCREEN_SIZE.x / 2 - text_size.x / 2, NOTE_START + 70 + f32(index) * (FONT_SIZE + 10)}
				DrawTextStatic(str, pos, FONT_SIZE, 5, .INSTRUMENT_SERIF, .REGULAR)
			}
		}
		
		for &button in buttons do DrawButton(&button)
	},
)}

LoadSaferoomSequences :: proc() {
	blob_row = LoadTexture("blob_row.png")
	saferoom_start_sequence_timer = hlp.new_timer(SAFEROOM_START_SEQUENCE_TIME, false, false)
	saferoom_end_sequence_timer = hlp.new_timer(SAFEROOM_END_SEQUENCE_TIME, false, false)
}

UnloadSaferoomSequences :: proc() {
	rl.UnloadTexture(blob_row)
}

BeginSaferoomEnterSequence :: proc() {
	run_stats.saferooms += 1
	hlp.activate_timer(&saferoom_start_sequence_timer)
	ChangeGameState(.SAFEROOM_ENTER)
	for &upgrade_button in saferoom_menu_upgrades do ResetUpgradeButton(&upgrade_button)
}

SaferoomEnterSequence :: proc() -> Menu { return NewMenu(
	update = proc(buttons: []Button) {
		hlp.update_timer(&saferoom_start_sequence_timer)
		if hlp.get_remaining_time(&saferoom_start_sequence_timer) <= 0 { ChangeGameState(.SAFEROOM); AddClockSeconds(15) }
	},
	draw = proc(buttons: []Button) {
		rem_time := hlp.get_remaining_time(&saferoom_start_sequence_timer) // Range SAFEROOM_START_SEQUENCE_TIME -> 0
		progress := 1 - rem_time / SAFEROOM_START_SEQUENCE_TIME // Range 0 -> 1
		ease := progress * progress
		
		interval := hlp.interval(0.2)
		
		source := rl.Rectangle{0, 0, f32(blob_row.width), f32(blob_row.height)}
		rl.DrawTexturePro(blob_row, source, {-BLOB_ROW_SIZE.y * interval, -BLOB_ROW_SIZE.y + BLOB_ROW_SIZE.y * ease, 
			BLOB_ROW_SIZE.x, BLOB_ROW_SIZE.y}, {}, 0, {50, 50, 50, 255})
		rl.DrawTexturePro(blob_row, source, {SCREEN_SIZE.x - BLOB_ROW_SIZE.x + BLOB_ROW_SIZE.y * interval, 
			SCREEN_SIZE.y - BLOB_ROW_SIZE.y * ease, BLOB_ROW_SIZE.x, BLOB_ROW_SIZE.y}, {}, 0, {50, 50, 50, 255})
	},
)}

BeginSaferoomExitSequence :: proc() {
	hlp.activate_timer(&saferoom_end_sequence_timer)
	ChangeGameState(.SAFEROOM_EXIT)
}

SaferoomExitSequence :: proc() -> Menu { return NewMenu(
	update = proc(buttons: []Button) {
		hlp.update_timer(&saferoom_end_sequence_timer)
		if hlp.get_remaining_time(&saferoom_end_sequence_timer) <= 0 { ChangeGameState(.PLAYING); ResetGame(true) }
	},
	draw = proc(buttons: []Button) {
		rl.ClearBackground(rl.BLACK)
		rem_time := hlp.get_remaining_time(&saferoom_end_sequence_timer)
		MAX_TIME :: SAFEROOM_END_SEQUENCE_TIME
		font_size := f32(32)
		switch rem_time {
		case (MAX_TIME * 6 / 8)..=MAX_TIME: font_size = 16 * 6
		case (MAX_TIME * 4 / 8)..<(MAX_TIME * 6 / 8): font_size = 16 * 8
		case (MAX_TIME * 3 / 8)..<(MAX_TIME * 4 / 8): font_size = 16 * 12
		case (MAX_TIME * 2 / 8)..<(MAX_TIME * 3 / 8): font_size = 16 * 16
		case (MAX_TIME * 1 / 8)..<(MAX_TIME * 2 / 8): font_size = 16 * 20
		case 0..<(MAX_TIME * 1 / 8): font_size = 16 * 24
		}
		
		DrawTextCenterXY(hlp.float_to_time_str(GetRemainingClockTime()), font_size, font_name = .INSTRUMENT_SERIF)
	},
)}

DrawSaferoomBackground :: proc(color := rl.Color{50, 50, 50, 255}) {
	interval := hlp.interval(0.2)
	source := rl.Rectangle{0, 0, f32(blob_row.width), f32(blob_row.height)}
	rl.DrawTexturePro(blob_row, source, {-BLOB_ROW_SIZE.y * interval, 0, BLOB_ROW_SIZE.x, BLOB_ROW_SIZE.y}, {}, 0, color)
	rl.DrawTexturePro(blob_row, source, {SCREEN_SIZE.x - BLOB_ROW_SIZE.x + BLOB_ROW_SIZE.y * interval, SCREEN_SIZE.y - BLOB_ROW_SIZE.y, 
		BLOB_ROW_SIZE.x, BLOB_ROW_SIZE.y}, {}, 0, color)
}