package bg3d

import "core:math"
import rl "vendor:raylib"

run_stats: RunStats

RunStats :: struct {
	time_survived: f32,
	points: int,
	saferooms: int,
}

ResetRunStats :: proc() {
	run_stats = {}
}

UpdateRunStats :: proc() {
	run_stats.time_survived += rl.GetFrameTime()
}

GetTimeSurvived :: proc() -> string {
	mins := int(math.floor(run_stats.time_survived / 60))
	secs := int(math.floor(run_stats.time_survived)) % 60
	mils := int(math.floor((run_stats.time_survived - math.floor(run_stats.time_survived)) * 1000))
	mins = clamp_low(mins, 0)
	secs = clamp_low(secs, 0)
	mils = clamp_low(mils, 0)
	str := string(rl.TextFormat("%2d:%02d.%d", mins, secs, mils))
	return str
}