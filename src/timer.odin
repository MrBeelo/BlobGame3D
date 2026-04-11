package bg3d

import rl "vendor:raylib"

Timer :: struct {
	duration: f32,
	start_time: f32,
	active: bool,
	repeat: bool,
	no_disable: bool,
	ding: bool
}

NewTimer :: proc(duration: f32, repeat: bool, auto_start := false, no_disable := false) -> Timer {
	timer := Timer{duration, 0, true, repeat, no_disable, false}
	if(auto_start) do ActivateTimer(&timer)
	return timer
}

ActivateTimer :: proc(self: ^Timer) {
	self.active = true
	self.start_time = f32(rl.GetTime())
}

DeactivateTimer :: proc(self: ^Timer) {
	if(self.repeat) do ActivateTimer(self); else do FinishTimer(self)
}

FinishTimer :: proc(self: ^Timer) {
	self.ding = false
	if(!self.no_disable) do self.active = false
}

GetRemainingTime :: proc(self: ^Timer) -> f32 {
	return self.duration - (f32(rl.GetTime()) - self.start_time) 
}

UpdateTimer :: proc(self: ^Timer) {
	self.ding = false
	if(self.active && GetRemainingTime(self) <= 0) {
		DeactivateTimer(self)
		self.ding = true
	}	
}