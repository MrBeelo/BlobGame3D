package bg3d

import rl "vendor:raylib"
import "core:math/rand"

MAX_UPGRADES :: 5
BaseUpgradeType :: enum {
	EXTRA_WALLJUMPS,
	EXTRA_JUMP_HEIGHT,
	EXTRA_MAX_HEALTH
}

run_upgrades: map[BaseUpgradeType]int
	
UpgradeType :: union {
	f32, // Health Blessing
	BaseUpgradeType
}

UPGRADE_BUTTON_SIZE :: rl.Vector2{250, 330}

UpgradeButton :: struct {
	center_pos: rl.Vector2,
	type: UpgradeType,
	size: rl.Vector2,
	hovered: bool,
	bought: bool
}

NewUpgradeButton :: proc(center_pos: rl.Vector2, type: UpgradeType) -> UpgradeButton {
	return UpgradeButton{center_pos, type, UPGRADE_BUTTON_SIZE, false, false}
}

GetAvailableBaseUpgradeTypes :: proc() -> []BaseUpgradeType {
	arr: [dynamic]BaseUpgradeType
	for upgrade in BaseUpgradeType do if run_upgrades[upgrade] < MAX_UPGRADES do append(&arr, upgrade)
	return arr[:]
}

ResetUpgradeButton :: proc(self: ^UpgradeButton) {
	chance := rand.int_range(0, 10)
	available_upgrade_types := GetAvailableBaseUpgradeTypes()
	if(chance <= 4 || len(available_upgrade_types) == 0) do self.type = 50; 
		else do self.type = available_upgrade_types[rand.int_range(0, len(available_upgrade_types))]
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
		switch x in self.type {
			case BaseUpgradeType: if run_upgrades[x] < MAX_UPGRADES do run_upgrades[x] += 1
			case f32: player.health += x
		}
	}
	
	if e, ok := self.type.(BaseUpgradeType); ok && run_upgrades[e] >= MAX_UPGRADES && !self.bought do self.bought = true
}

DrawUpgradeButton :: proc(self: ^UpgradeButton) {
	pos := self.center_pos - self.size / 2
	button_rect := rl.Rectangle{pos.x, pos.y, self.size.x, self.size.y}
	
	button_color := GetUpgradeColor(self.type)
	button_text := GetUpgradeText(self.type)
	
	ROUNDNESS :: 0.15
	SEGMENTS :: 4
	rl.DrawRectangleRounded(button_rect, ROUNDNESS, SEGMENTS, {30, 30, 30, 255})
	rl.DrawRectangleRoundedLinesEx(button_rect, ROUNDNESS, SEGMENTS, 5, button_color if(!self.bought) else rl.BLACK)
	
	if(!self.bought) {
		BUTTON_TEXT_FONT_SIZE :: 28
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

GetUpgradeCost :: proc(type: UpgradeType) -> int {
	switch x in type {
		case f32: return 100
		case BaseUpgradeType: switch(x) {
			case .EXTRA_WALLJUMPS: return 400
			case .EXTRA_JUMP_HEIGHT: return 250
			case .EXTRA_MAX_HEALTH: return 500
		}
	}
	return 0
}

GetUpgradeColor :: proc(type: UpgradeType) -> rl.Color {
	switch x in type {
		case f32: return rl.RED
		case BaseUpgradeType: switch(x) {
			case .EXTRA_WALLJUMPS: return rl.ORANGE
			case .EXTRA_JUMP_HEIGHT: return rl.YELLOW
			case .EXTRA_MAX_HEALTH: return rl.RED
		}		
	}
	return rl.BLACK
}

GetUpgradeText :: proc(type: UpgradeType) -> string {
	switch x in type {
		case f32: return concat({"BLESSING (", to_string(x), "HP)"})
		case BaseUpgradeType: switch(x) {
			case .EXTRA_WALLJUMPS: return "WALLJUMP"
			case .EXTRA_JUMP_HEIGHT: return "JUMP HEIGHT"
			case .EXTRA_MAX_HEALTH: return "MAX HEALTH"
		}		
	}
	return "ERROR"
}