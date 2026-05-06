package bg3d

import rl "vendor:raylib"
import "core:math/rand"

RunUpgradeType :: enum {
	EXTRA_WALLJUMPS,
	EXTRA_JUMP_HEIGHT,
	EXTRA_MAX_HEALTH
}

run_upgrades: map[RunUpgradeType]int

UPGRADE_BUTTON_TYPE_AMOUNT :: 4
UpgradeButtonType :: enum {
	BONUS_HEALTH,
	EXTRA_WALLJUMP,
	INCREASE_JUMP_HEIGHT,
	INCREASE_MAX_HEALTH
}

UPGRADE_BUTTON_SIZE :: rl.Vector2{250, 330}

UpgradeButton :: struct {
	center_pos: rl.Vector2,
	type: UpgradeButtonType,
	size: rl.Vector2,
	hovered: bool,
	bought: bool
}

NewUpgradeButton :: proc(center_pos: rl.Vector2, type: UpgradeButtonType) -> UpgradeButton {
	return UpgradeButton{center_pos, type, UPGRADE_BUTTON_SIZE, false, false}
}

GetUpgradeCost :: proc(type: UpgradeButtonType) -> int {
	switch(type) {
		case .BONUS_HEALTH: return 100
		case .EXTRA_WALLJUMP: return 400
		case .INCREASE_JUMP_HEIGHT: return 250
		case .INCREASE_MAX_HEALTH: return 500
	}
	
	return 0
}

ResetUpgradeButton :: proc(self: ^UpgradeButton) {
	self.type = UpgradeButtonType(rand.int_range(0, UPGRADE_BUTTON_TYPE_AMOUNT))
	self.bought = false
}

UpdateUpgradeButton :: proc(self: ^UpgradeButton) {
	was_hovered := self.hovered
	pos := self.center_pos - self.size / 2
	button_rect := rl.Rectangle{pos.x, pos.y, self.size.x, self.size.y}
	mouse_pos := rl.GetMousePosition()
	self.hovered = rl.CheckCollisionPointRec(mouse_pos, button_rect)
	if(self.hovered && !was_hovered) do rl.PlaySound(ui_hover_sound)
	
	UPGRADE_BUTTON_SIZE_MAX :: rl.Vector2{UPGRADE_BUTTON_SIZE.x * 120 / 100, UPGRADE_BUTTON_SIZE.y * 120 / 100}
	
	if(self.hovered && self.size.x < UPGRADE_BUTTON_SIZE_MAX.x) do self.size.x += rl.GetFrameTime() * 500
	if(self.hovered && self.size.y < UPGRADE_BUTTON_SIZE_MAX.y) do self.size.y += rl.GetFrameTime() * 500
	if(!self.hovered && self.size.x > UPGRADE_BUTTON_SIZE.x) do self.size.x -= rl.GetFrameTime() * 500
	if(!self.hovered && self.size.y > UPGRADE_BUTTON_SIZE.y) do self.size.y -= rl.GetFrameTime() * 500
	
	if(self.hovered && rl.IsMouseButtonPressed(.LEFT) && !self.bought && run_stats.points >= GetUpgradeCost(self.type)) {
		rl.PlaySound(ui_click_sound)
		self.bought = true
		run_stats.points -= GetUpgradeCost(self.type)
		switch(self.type) {
			case .BONUS_HEALTH: player.health += 30
			case .EXTRA_WALLJUMP: run_upgrades[.EXTRA_WALLJUMPS] += 1
			case .INCREASE_JUMP_HEIGHT: run_upgrades[.EXTRA_JUMP_HEIGHT] += 1
			case .INCREASE_MAX_HEALTH: run_upgrades[.EXTRA_MAX_HEALTH] += 10
		}
	}
}

DrawUpgradeButton :: proc(self: ^UpgradeButton) {
	pos := self.center_pos - self.size / 2
	button_rect := rl.Rectangle{pos.x, pos.y, self.size.x, self.size.y}
	
	button_color: rl.Color
	switch(self.type) {
		case .BONUS_HEALTH: button_color = rl.RED
		case .EXTRA_WALLJUMP: button_color = rl.ORANGE
		case .INCREASE_JUMP_HEIGHT: button_color = rl.YELLOW
		case .INCREASE_MAX_HEALTH: button_color = rl.RED
	}
	
	button_text: string
	switch(self.type) {
		case .BONUS_HEALTH: button_text = "BONUS HEALTH"
		case .EXTRA_WALLJUMP: button_text = "EXTRA WALLJUMP"
		case .INCREASE_JUMP_HEIGHT: button_text = "MORE JUMP HEIGHT"
		case .INCREASE_MAX_HEALTH: button_text = "MORE MAX HEALTH"
	}
	
	rl.DrawRectanglePro(button_rect, {}, 0, {30, 30, 30, 255})
	rl.DrawRectangleLinesEx(button_rect, 5, button_color if(!self.bought) else rl.BLACK)
	
	if(!self.bought) {
		BUTTON_TEXT_FONT_SIZE :: 24
		text_size := MeasureText(button_text, BUTTON_TEXT_FONT_SIZE)
		DrawText(button_text, {pos.x + self.size.x / 2 - text_size.x / 2, pos.y + self.size.y * 3 / 4}, 
			BUTTON_TEXT_FONT_SIZE, color = button_color, border_info = {true, 3, rl.BLACK})
		text_size_2 := MeasureText(to_string(GetUpgradeCost(self.type)), BUTTON_TEXT_FONT_SIZE)
		DrawText(to_string(GetUpgradeCost(self.type)), {self.center_pos.x - self.size.x / 2 + self.size.x - text_size_2.x - 10, 
			self.center_pos.y - self.size.y / 2 + 10}, BUTTON_TEXT_FONT_SIZE, color = rl.DARKGRAY)
	} else {
		BUTTON_TEXT_FONT_SIZE :: 96
		text := "X"
		text_size := MeasureText(text, BUTTON_TEXT_FONT_SIZE)
		DrawText(text, {pos.x + self.size.x / 2 - text_size.x / 2, pos.y + self.size.y / 2 - text_size.y / 2}, 
			BUTTON_TEXT_FONT_SIZE, color = rl.RED, border_info = {true, 2, rl.BLACK})
	}
}