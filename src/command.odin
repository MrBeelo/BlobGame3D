package bg3d

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

cmd_text := ""
past_texts: [dynamic]string
past_text_index: int

ManageCommands :: proc(args: []string) {
	switch args[0] {
		case "kill": BeginDeathSequence()
		case "health": {
			val := Parse(args[2], f32)
			if args[1] == "set" do player.health = val
			if args[1] == "add" do player.health += val
		}
		case "time": {
			val := Parse(args[2], f32)
			if args[1] == "set" do SetClockSeconds(val)
			if args[1] == "add" do AddClockSeconds(val)
		}
		case "points": {
			val := Parse(args[2], int)
			if args[1] == "set" do run_stats.points = val
			if args[1] == "add" do run_stats.points += val
		}
		case "saferoom": if IsInMainGame() do BeginSaferoomStartSequence()
	}
}

UpdateCommandMenu :: proc() {
	char_pressed := rl.GetCharPressed()
	cmd_text = strings.concatenate({cmd_text, to_string(char_pressed)})
	if rl.IsKeyPressed(.BACKSPACE) do cmd_text = string_pop(cmd_text)
	if rl.IsKeyPressed(.RIGHT_SHIFT) do cmd_text = ""
	if rl.IsKeyPressed(.ENTER) {
		ChangeGameState(.PLAYING)
		append(&past_texts, cmd_text)
		past_text_index = -1
		args := strings.split(cmd_text, " ")
		if len(args) == 0 do return
		fmt.printfln("GAME: Recieved command with arguments: %v", args)
		ManageCommands(args)
		cmd_text = ""
	}
	
	if rl.IsKeyPressed(.UP) {
		if past_text_index == -1 {
			cmd_text = past_texts[len(past_texts) - 1]
			past_text_index = len(past_texts) - 1
		} else if past_text_index > 0 {
			cmd_text = past_texts[past_text_index - 1]
			past_text_index -= 1
		}
	} else if rl.IsKeyPressed(.DOWN) {
		if past_text_index >= 0 && past_text_index < len(past_texts) - 1 {
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