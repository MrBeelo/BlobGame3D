package bg3d

import rl "vendor:raylib"

saferoom_start_sequence_timer: Timer
SAFEROOM_START_SEQUENCE_TIME :: 0.3
saferoom_end_sequence_timer: Timer
SAFEROOM_END_SEQUENCE_TIME :: f32(1)
blob_row: rl.Texture2D
BLOB_ROW_SIZE :: rl.Vector2{SCREEN_SIZE.y / 2 * 5, SCREEN_SIZE.y / 2}

LoadSaferoomSequences :: proc() {
	blob_row = LoadTexture("blob_row.png")
	saferoom_start_sequence_timer = NewTimer(SAFEROOM_START_SEQUENCE_TIME, false, false)
	saferoom_end_sequence_timer = NewTimer(SAFEROOM_END_SEQUENCE_TIME, false, false)
}

UnloadSaferoomSequences :: proc() {
	rl.UnloadTexture(blob_row)
}

BeginSaferoomStartSequence :: proc() {
	run_stats.saferooms += 1
	ActivateTimer(&saferoom_start_sequence_timer)
	ChangeGameState(.SAFEROOM_ENTER)
}

UpdateSaferoomStartSequence :: proc() { 
	if(game_state != .SAFEROOM_ENTER) do return
	UpdateTimer(&saferoom_start_sequence_timer)
	if(GetRemainingTime(&saferoom_start_sequence_timer) <= 0) do ChangeGameState(.SAFEROOM)
}

DrawSaferoomStartSequence :: proc() {
	rem_time := GetRemainingTime(&saferoom_start_sequence_timer) // Range SAFEROOM_START_SEQUENCE_TIME -> 0
	progress := 1 - rem_time / SAFEROOM_START_SEQUENCE_TIME // Range 0 -> 1
	ease := progress * progress
	
	interval := Interval(0.2)
	
	source := rl.Rectangle{0, 0, f32(blob_row.width), f32(blob_row.height)}
	rl.DrawTexturePro(blob_row, source, {-BLOB_ROW_SIZE.y * interval, -BLOB_ROW_SIZE.y + BLOB_ROW_SIZE.y * ease, 
		BLOB_ROW_SIZE.x, BLOB_ROW_SIZE.y}, {}, 0, {50, 50, 50, 255})
	rl.DrawTexturePro(blob_row, source, {SCREEN_SIZE.x - BLOB_ROW_SIZE.x + BLOB_ROW_SIZE.y * interval, 
		SCREEN_SIZE.y - BLOB_ROW_SIZE.y * ease, BLOB_ROW_SIZE.x, BLOB_ROW_SIZE.y}, {}, 0, {50, 50, 50, 255})
}

BeginSaferoomEndSequence :: proc() {
	ActivateTimer(&saferoom_end_sequence_timer)
	ChangeGameState(.SAFEROOM_EXIT)
}

UpdateSaferoomEndSequence :: proc() { 
	if(game_state != .SAFEROOM_EXIT) do return
	UpdateTimer(&saferoom_end_sequence_timer)
	if(GetRemainingTime(&saferoom_end_sequence_timer) <= 0) { ChangeGameState(.PLAYING); ResetGame(true) }
}

DrawSaferoomEndSequence :: proc() {
	rl.ClearBackground(rl.BLACK)
	rem_time := GetRemainingTime(&saferoom_end_sequence_timer)
	MAX_TIME :: SAFEROOM_END_SEQUENCE_TIME
	font_size := f32(32)
	switch(rem_time) {
		case (MAX_TIME * 6 / 8)..=MAX_TIME: font_size = 48
		case (MAX_TIME * 4 / 8)..<(MAX_TIME * 6 / 8): font_size = 64
		case (MAX_TIME * 3 / 8)..<(MAX_TIME * 4 / 8): font_size = 96
		case (MAX_TIME * 2 / 8)..<(MAX_TIME * 3 / 8): font_size = 128
		case (MAX_TIME * 1 / 8)..<(MAX_TIME * 2 / 8): font_size = 160
		case 0..<(MAX_TIME * 1 / 8): font_size = 192
	}
	
	DrawTextCenterXY(FloatToTimeStr(GetRemainingClockTime()), font_size)
}