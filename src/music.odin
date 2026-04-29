package bg3d

import rl "vendor:raylib"
import "core:os"
import "core:strings"
import "core:math/rand"

musics: [dynamic]rl.Sound
saferoom_music: rl.Sound

LoadMusic :: proc() {
	files, err := os.read_directory_by_path("sounds/music/", 0, context.allocator)
	if(err == nil) do for file in files do if(strings.ends_with(file.name, ".wav")) { 
		if(strings.starts_with(file.name, "game")) do append(&musics, LoadSound(concat({"music/", file.name})))
	}
	
	for music in musics do rl.SetSoundVolume(music, 0.5)
	saferoom_music = LoadSound(concat({"music/safe.wav"}))
	rl.SetSoundVolume(saferoom_music, 0.8)
}

UnloadMusic :: proc() {
	for music in musics do rl.UnloadSound(music)
	rl.UnloadSound(saferoom_music)
}

PlayRandomGameMusic :: proc() {
	if(len(musics) == 0) do return
	music := rand.int32_range(0, i32(len(musics)))
	rl.PlaySound(musics[music])
}

IsGameMusicPlaying :: proc() -> bool {
	for music in musics do if(rl.IsSoundPlaying(music)) do return true
	return false
}

StopGameMusic :: proc() {
	for music in musics do rl.StopSound(music)
}

UpdateMusic :: proc() {
	if((IsInMainGame() || game_state == .SAFEROOM_ENTER) && !IsGameMusicPlaying()) do PlayRandomGameMusic()
	if(game_state == .SAFEROOM && !rl.IsSoundPlaying(saferoom_music)) do rl.PlaySound(saferoom_music)
	
	if(!IsInMainGame() && game_state != .SAFEROOM_ENTER && IsGameMusicPlaying()) do StopGameMusic()
	if(game_state != .SAFEROOM && rl.IsSoundPlaying(saferoom_music)) do rl.StopSound(saferoom_music)
}