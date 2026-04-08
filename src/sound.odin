package bb3d

import "core:math/rand"
import rl "vendor:raylib"

walk_sounds: [10]rl.Sound
run_sounds: [10]rl.Sound
jump_sounds: [4]rl.Sound
slide_sound: rl.Sound
whoosh_sound: rl.Sound
flashlight_switch_sound: rl.Sound
ui_hover_sound: rl.Sound
ui_click_sound: rl.Sound
ui_gun_shoot_sound: rl.Sound
ui_gun_load_sound: rl.Sound

walk_timer: Timer
run_timer: Timer

PoolSoundType :: enum{ WALK, RUN, JUMP }

LoadSounds :: proc() {
	for i := 1; i <= len(walk_sounds); i += 1 do walk_sounds[i - 1] = LoadSound(concat({"walk/walk", string(rl.TextFormat("%d", i)), ".wav"}))
	for i := 1; i <= len(run_sounds); i += 1 do run_sounds[i - 1] = LoadSound(concat({"run/run", string(rl.TextFormat("%d", i)), ".wav"}))
	for i := 1; i <= len(jump_sounds); i += 1 do jump_sounds[i - 1] = LoadSound(concat({"jump/jump", string(rl.TextFormat("%d", i)), ".wav"}))
	for sound in (walk_sounds) do rl.SetSoundVolume(sound, 0.6)
	for sound in (run_sounds) do rl.SetSoundVolume(sound, 0.6)
	
	slide_sound = LoadSound("slide.wav")
	rl.SetSoundVolume(slide_sound, 0.2)
	rl.SetSoundPitch(slide_sound, 1.5)
	
	whoosh_sound = LoadSound("whoosh.wav")
	rl.SetSoundVolume(whoosh_sound, 0.6)
	
	flashlight_switch_sound = LoadSound("flashlight_switch.wav")
	rl.SetSoundVolume(flashlight_switch_sound, 0.3)
	
	ui_hover_sound = LoadSound("ui/hover.wav")
	rl.SetSoundVolume(ui_hover_sound, 0.1)
	ui_click_sound = LoadSound("ui/click.wav")
	
	ui_gun_shoot_sound = LoadSound("ui/gun_shoot.wav")
	ui_gun_load_sound = LoadSound("ui/gun_load.wav")
	
	walk_timer = NewTimer(0.7, true)
	run_timer = NewTimer(0.2, true)
}

UnloadSounds :: proc() {
	for sound in (walk_sounds) do rl.UnloadSound(sound)
	for sound in (run_sounds) do rl.UnloadSound(sound)
	for sound in (jump_sounds) do rl.UnloadSound(sound)
	rl.UnloadSound(slide_sound)
	rl.UnloadSound(whoosh_sound)
	rl.UnloadSound(flashlight_switch_sound)
	rl.UnloadSound(ui_hover_sound)
	rl.UnloadSound(ui_click_sound)
	rl.UnloadSound(ui_gun_shoot_sound)
	rl.UnloadSound(ui_gun_load_sound)
}

PlayPoolSound :: proc(type: PoolSoundType) {
	sound: rl.Sound
	switch(type) {
		case .WALK: sound = walk_sounds[rand.int32_range(0, len(walk_sounds))]
		case .RUN: sound = run_sounds[rand.int32_range(0, len(run_sounds))]
		case .JUMP: sound = jump_sounds[rand.int32_range(0, len(jump_sounds))]
	}
	
	rl.PlaySound(sound)
}

UpdateSounds :: proc() {
	UpdateTimer(&walk_timer)
	UpdateTimer(&run_timer)
	
	if(walk_timer.ding) do PlayPoolSound(.WALK)
	if(run_timer.ding) do PlayPoolSound(.RUN)
	
	if(IsPlayerMovingAxis() && IsCollidingYDown(&player) && !IsPlayerSliding()) {
		if(IsPlayerSprinting()) {
			run_timer.active = true
			walk_timer.active = false
		} else {
			run_timer.active = false
			walk_timer.active = true
		}
	} else {
		walk_timer.active = false
		run_timer.active = false
	}
	
	if(IsPlayerSliding() && !rl.IsSoundPlaying(slide_sound) && IsCollidingYDown(&player)) do rl.PlaySound(slide_sound)
	if((!IsPlayerSliding() || !IsCollidingYDown(&player)) && rl.IsSoundPlaying(slide_sound)) do rl.StopSound(slide_sound)
	if(PlayerPressedCrouch()) do rl.PlaySound(whoosh_sound)
}