package bg3d

import "core:math"
import rl "vendor:raylib"

Interval :: proc(mod: f32) -> f32 {
	t := f32(rl.GetTime()) / (1 / mod)
	return t - math.floor(t)
}

FloatToTimeStr :: proc(value: f32, miliseconds := false, use_x := true) -> string {
	mins := int(math.floor(value / 60))
	secs := int(math.floor(value)) % 60
	mils := int(math.floor(value - math.floor(value) * 1000))
	mins = clamp_low(mins, 0)
	secs = clamp_low(secs, 0)
	mils = clamp_low(mils, 0)
	str := string(rl.TextFormat("%2d:%02d.%d", mins, secs, mils)) if miliseconds else string(rl.TextFormat("%2d:%02d", mins, secs))
	if use_x && mins == 0 && secs == 0 do str = "XX:XX.XXX" if miliseconds else "XX:XX"
	return str
}