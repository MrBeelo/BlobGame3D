package bg3d

import rl "vendor:raylib"

saferoom_start_sequence_timer: Timer
SAFEROOM_START_SEQUENCE_TIME :: 0.3
blob_row: rl.Texture2D
BLOB_ROW_SIZE :: rl.Vector2{SCREEN_SIZE.y / 2 * 5, SCREEN_SIZE.y / 2}

LoadSaferoomSequences :: proc() {
	blob_row = LoadTexture("blob_row.png")
	saferoom_start_sequence_timer = NewTimer(SAFEROOM_START_SEQUENCE_TIME, false, false)
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