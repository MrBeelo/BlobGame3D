package bg3d

import hlp "helper"
import "core:strings"
import "core:math"
import rl "vendor:raylib"

death_sequence_timer: hlp.Timer
blob_strip: rl.Texture2D
sound_points: [8]bool

DeadMenu :: proc() -> Menu { return NewMenu(
	buttons = []Button{
		NewButton("PLAY AGAIN", {SCREEN_SIZE.x / 2 - 250, SCREEN_SIZE.y - 250}, proc() { BeginSaferoomExitSequence() }),
		NewButton("LEAVE", {SCREEN_SIZE.x / 2 + 250, SCREEN_SIZE.y - 250}, proc() { ChangeGameState(.MAIN) }),
	},
	update = proc(buttons: []Button) {
		UpdateDeathSequence()
		if hlp.get_remaining_time(&death_sequence_timer) <= 2 do for &button in buttons do UpdateButton(&button)
	},
	draw = proc(buttons: []Button) {
		DrawDeathSequence()
		if hlp.get_remaining_time(&death_sequence_timer) <= 8 do DrawTitle("YOU DIED")
		if hlp.get_remaining_time(&death_sequence_timer) <= 2 do for &button in buttons do DrawButton(&button)
	},
)}

// Sequence

LoadDeathSequence :: proc() {
	blob_strip = LoadTexture("blob_strip.png")
	death_sequence_timer = hlp.new_timer(10, false, false)
}

UnloadDeathSequence :: proc() {
	rl.UnloadTexture(blob_strip)
}

BeginDeathSequence :: proc() {
	hlp.activate_timer(&death_sequence_timer)
	ChangeGameState(.DEAD)
	sound_points = {}
}

UpdateDeathSequence :: proc() {
	hlp.update_timer(&death_sequence_timer)
}

DrawDeathSequence :: proc() {
	rem_time := hlp.get_remaining_time(&death_sequence_timer)
	
	rl.DrawRectangle(0, 0, i32(SCREEN_SIZE.x), i32(SCREEN_SIZE.y), rl.BLACK)
	
	if rem_time <= 8 {
		for i in 0..=16 {
			offset_y := math.sin((rem_time + f32(i)) * math.PI)
			rl.DrawTexturePro(blob_strip, {0, 0, 64, 1024}, {128 * f32(i), -offset_y * 32 - 64, 128, 2048}, {}, 0, {50, 50, 50, 255})
		}
	}
	
	DrawStatText(StatString(6.5, "Time Survived", GetTimeSurvived()), 0)
	DrawStatText(StatString(5.5, "Points", hlp.to_string(run_stats.points)), 1)
	DrawStatText(StatString(4.5, "Saferooms", hlp.to_string(run_stats.saferooms)), 2)
	
	// Handle Sounds
	if CheckSoundPoint(0, 8) do PlaySoundPoint(flashlight_switch_sound, 0)
	if CheckSoundPoint(1, 6.5) do PlaySoundPoint(ui_gun_load_sound, 1)
	if CheckSoundPoint(2, 6) do PlaySoundPoint(ui_gun_shoot_sound, 2)
	if CheckSoundPoint(3, 5.5) do PlaySoundPoint(ui_gun_load_sound, 3)
	if CheckSoundPoint(4, 5) do PlaySoundPoint(ui_gun_shoot_sound, 4)
	if CheckSoundPoint(5, 4.5) do PlaySoundPoint(ui_gun_load_sound, 5)
	if CheckSoundPoint(6, 4) do PlaySoundPoint(ui_gun_shoot_sound, 6)
	if CheckSoundPoint(7, 2) do PlaySoundPoint(ui_gun_shoot_sound, 7)
}

StatString :: proc(appear_time: f32, name: string, value: string) -> string {
	rem_time := hlp.get_remaining_time(&death_sequence_timer)
	VALUE_APPEAR_DELAY :: 0.5
	str := ""
	if rem_time <= appear_time do str = strings.concatenate({name, ": "})
	if rem_time <= appear_time - VALUE_APPEAR_DELAY do str = strings.concatenate({str, value})
	return str
}

DrawStatText :: proc(stat_string: string, index: int, font_name := FontName.CHANGA_ONE, font_type := FontType.ITALIC) {
	FONT_SIZE :: 48
	FONT_SPACING :: 3
	DrawTextCenterX(stat_string, 300 + 70 * f32(index), FONT_SIZE, FONT_SPACING, font_name, font_type)
}

CheckSoundPoint :: proc(index: int, remain_time: f32) -> bool { return !sound_points[index] && hlp.get_remaining_time(&death_sequence_timer) < remain_time }
PlaySoundPoint :: proc(sound: rl.Sound, index: int) {
	rl.PlaySound(sound)
	sound_points[index] = true
}