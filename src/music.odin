package bg3d

import rl "vendor:raylib"
import "core:strings"
import "core:fmt"
import "core:math/rand"

musics: [dynamic]rl.Sound
saferoom_music: rl.Sound

LoadMusic :: proc() {
	START_PATH :: "sounds/music"
	files := rl.LoadDirectoryFiles(START_PATH)
	for index in 0..<files.count {
		path := string(files.paths[index])
		name, _ := strings.substring_from(path, len(START_PATH) + 1)
		fmt.printfln("path %s name %s", path, name)
		if strings.ends_with(name, ".wav") || strings.ends_with(name, ".mp3") {
			if strings.starts_with(name, "game") do append(&musics, LoadSound(strings.concatenate({"music/", name})))
		}
	}
	
	for music in musics do rl.SetSoundVolume(music, 0.3)
	saferoom_music = LoadSound(strings.concatenate({"music/safe.wav"}))
	rl.SetSoundVolume(saferoom_music, 0.8)
}

UnloadMusic :: proc() {
	for music in musics do rl.UnloadSound(music)
	rl.UnloadSound(saferoom_music)
}

PlayRandomGameMusic :: proc() {
	if len(musics) == 0 do return
	music := rand.int32_range(0, i32(len(musics)))
	rl.PlaySound(musics[music])
}

IsGameMusicPlaying :: proc() -> bool {
	for music in musics do if rl.IsSoundPlaying(music) do return true
	return false
}

StopGameMusic :: proc() {
	for music in musics do rl.StopSound(music)
}

UpdateMusic :: proc() {
	if (IsInMainGame() || game_state == .SAFEROOM_ENTER) && !IsGameMusicPlaying() do PlayRandomGameMusic()
	if IsInSaferoom() && !rl.IsSoundPlaying(saferoom_music) do rl.PlaySound(saferoom_music)
	
	if !IsInMainGame() && game_state != .SAFEROOM_ENTER && IsGameMusicPlaying() do StopGameMusic()
	if !IsInSaferoom() && rl.IsSoundPlaying(saferoom_music) do rl.StopSound(saferoom_music)
}