package bg3d

import rl "vendor:raylib"

//BUTTON_FONT_SIZE :: rl.Vector2{48, 64} // Not Hovered, Hovered
//BUTTON_FONT_SPACING :: rl.Vector2{5, 10} // Not Hovered, Hovered

Button :: struct {
	text: string,
	font_size: f32,
	font_spacing: f32,
	center_pos: rl.Vector2, 
	function: proc(),
	hovered: bool,
	font_name: FontName,
	font_type: FontType,
	animation: TextAnimation,
	color: rl.Color,
	font_sizes: [2]f32,
	font_spacings: [2]f32
}

NewButton :: proc(text: string, center_pos: rl.Vector2, function: proc(), font_name := FontName.CHANGA_ONE, 
font_type := FontType.REGULAR, anim := TextAnimation.SHAKY, color := rl.WHITE, font_sizes := rl.Vector2{48, 64},
font_spacings := rl.Vector2{5, 10}) -> Button {
	return Button{text, font_sizes.x, font_spacings.x, center_pos, function, false, font_name, font_type, anim, color, 
		font_sizes, font_spacings}
}

NewButtonDefLeft :: proc(text: string, index: int, function: proc(), font_name := FontName.CHANGA_ONE, 
font_type := FontType.REGULAR, anim := TextAnimation.SHAKY, color := rl.WHITE, font_sizes := rl.Vector2{48, 64},
font_spacings := rl.Vector2{5, 10}) -> Button {
	pos := rl.Vector2{300, 400 + f32(index) * 80}
	return NewButton(text, pos, function, font_name, font_type, anim, color, font_sizes, font_spacings)
}

NewButtonDefCenter :: proc(text: string, index: int, function: proc(), font_name := FontName.CHANGA_ONE, 
font_type := FontType.REGULAR, anim := TextAnimation.SHAKY, color := rl.WHITE, font_sizes := rl.Vector2{48, 64},
font_spacings := rl.Vector2{5, 10}) -> Button {
	pos := rl.Vector2{SCREEN_SIZE.x / 2, 600 + f32(index) * 80}
	return NewButton(text, pos, function, font_name, font_type, anim, color, font_sizes, font_spacings)
}

UpdateButton :: proc(self: ^Button) {
	was_hovered := self.hovered
	text_size := MeasureText(self.text, self.font_size, self.font_spacing, self.font_name, self.font_type)
	top_left_pos := self.center_pos - (text_size / 2)
	button_rect := rl.Rectangle{top_left_pos.x, top_left_pos.y, text_size.x, text_size.y}
	mouse_pos := GetVMousePos()
	self.hovered = rl.CheckCollisionPointRec(mouse_pos, button_rect)
	if self.hovered && !was_hovered do rl.PlaySound(ui_hover_sound)
	
	if self.hovered && self.font_size < self.font_sizes.y do self.font_size += rl.GetFrameTime() * 100
	if !self.hovered && self.font_size > self.font_sizes.x do self.font_size -= rl.GetFrameTime() * 100
	if self.hovered && self.font_spacing < self.font_spacings.y do self.font_spacing += rl.GetFrameTime() * 100
	if !self.hovered && self.font_spacing > self.font_spacings.x do self.font_spacing -= rl.GetFrameTime() * 100
	
	if self.hovered && rl.IsMouseButtonPressed(.LEFT) {
		self.function()
		rl.PlaySound(ui_click_sound)
	}
	
	self.font_size = clamp(self.font_size, self.font_sizes.x, self.font_sizes.y)
	self.font_spacing = clamp(self.font_size, self.font_spacings.x, self.font_spacings.y)
}

DrawButton :: proc(self: ^Button) {
	text_size := MeasureText(self.text, self.font_size, self.font_spacing, self.font_name, self.font_type)
	top_left_pos := self.center_pos - (text_size / 2)
	DrawTextDef(self.animation, self.text, top_left_pos, self.font_size, self.font_spacing, 
		self.font_name, self.font_type, self.color, {true, 3, rl.BLACK})
}

MeasureButtonText :: proc(self: ^Button) -> rl.Vector2 {
	return MeasureText(self.text, self.font_size, self.font_spacing, self.font_name, self.font_type)
}