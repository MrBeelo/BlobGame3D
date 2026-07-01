package helper

import rl "vendor:raylib"

Timer :: struct {
	duration: f32,
	start_time: f32,
	active: bool,
	repeat: bool,
	no_disable: bool,
	ding: bool,
}

new_timer :: proc(duration: f32, repeat: bool, auto_start := false, no_disable := false) -> Timer {
	timer := Timer{duration, 0, true, repeat, no_disable, false}
	if auto_start do activate_timer(&timer)
	return timer
}

activate_timer :: proc(self: ^Timer) {
	self.active = true
	self.start_time = f32(rl.GetTime())
}

deactivate_timer :: proc(self: ^Timer) {
	if self.repeat do activate_timer(self); else do finish_timer(self)
}

finish_timer :: proc(self: ^Timer) {
	self.ding = false
	if !self.no_disable do self.active = false
}

get_remaining_time :: proc(self: ^Timer) -> f32 {
	return self.duration - (f32(rl.GetTime()) - self.start_time) 
}

update_timer :: proc(self: ^Timer) {
	self.ding = false
	if self.active && get_remaining_time(self) <= 0 {
		deactivate_timer(self)
		self.ding = true
	}	
}