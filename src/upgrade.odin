package bg3d

import rl "vendor:raylib"
import "core:math/rand"

MAX_UPGRADES :: 5
run_upgrades: map[BaseUpgradeType]int
BaseUpgradeType :: enum {
	EXTRA_WALLJUMPS,
	EXTRA_JUMP_HEIGHT,
	EXTRA_MAX_HEALTH
}
	
UpgradeType :: union {
	f32, // Health Blessing
	BaseUpgradeType
}

UPGRADE_BUTTON_SIZE :: rl.Vector2{250, 330}
UPGRADE_BUTTON_SIZE_MAX :: rl.Vector2{UPGRADE_BUTTON_SIZE.x * 120 / 100, UPGRADE_BUTTON_SIZE.y * 120 / 100}
UpgradeButton :: struct {
	center_pos: rl.Vector2,
	type: UpgradeType,
	size: rl.Vector2,
	hovered: bool,
	bought: bool
}

button_sprites: [len(ButtonSprite)]rl.Texture2D
ButtonSprite :: enum {
	WALLJUMP,
	JUMP_HEIGHT,
	HEART
}

LoadUpgradeButtons :: proc() {
	button_sprites[int(ButtonSprite.WALLJUMP)] = LoadTexture("powerups/walljump.png")
	button_sprites[int(ButtonSprite.JUMP_HEIGHT)] = LoadTexture("powerups/jump_height.png")
	button_sprites[int(ButtonSprite.HEART)] = LoadTexture("powerups/heart.png")
}

UnloadUpgradeButtons :: proc() {
	for texture in button_sprites do rl.UnloadTexture(texture)
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
	if(chance <= 4 || len(available_upgrade_types) == 0) do self.type = f32(rand.int_range(25, 50))
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

	RESIZE_MOD :: f32(500)
	if(self.hovered && self.size.x < UPGRADE_BUTTON_SIZE_MAX.x) do self.size.x += rl.GetFrameTime() * RESIZE_MOD
	if(self.hovered && self.size.y < UPGRADE_BUTTON_SIZE_MAX.y) do self.size.y += rl.GetFrameTime() * RESIZE_MOD
	if(!self.hovered && self.size.x > UPGRADE_BUTTON_SIZE.x) do self.size.x -= rl.GetFrameTime() * RESIZE_MOD
	if(!self.hovered && self.size.y > UPGRADE_BUTTON_SIZE.y) do self.size.y -= rl.GetFrameTime() * RESIZE_MOD
	
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
	button_sprite := GetUpgradeSprite(self.type)
	
	ROUNDNESS :: 0.15
	SEGMENTS :: 4
	rl.DrawRectangleRounded(button_rect, ROUNDNESS, SEGMENTS, {30, 30, 30, 255})
	rl.DrawRectangleRoundedLinesEx(button_rect, ROUNDNESS, SEGMENTS, 5, button_color if(!self.bought) else rl.BLACK)
	
	if(!self.bought) {
		BUTTON_TEXT_FONT_SIZE :: 28

		// Draw main text (upgrade name)
		for i in 0..=1 do if button_text[i] != nil {
			text := button_text[i].?
			text_size := MeasureText(text, BUTTON_TEXT_FONT_SIZE)
			Y_BACK_OFFSET :: f32(-10)
			DrawText(text, {pos.x + self.size.x / 2 - text_size.x / 2, pos.y + self.size.y * 3 / 4 + Y_BACK_OFFSET + (BUTTON_TEXT_FONT_SIZE + 5 if i == 1 else 0)}, 
				BUTTON_TEXT_FONT_SIZE, color = button_color, border_info = {true, 3, rl.BLACK})
		}

		// Draw cost
		cost_text_size := MeasureText(to_string(GetUpgradeCost(self.type)), BUTTON_TEXT_FONT_SIZE)
		DrawText(to_string(GetUpgradeCost(self.type)), {self.center_pos.x - self.size.x / 2 + self.size.x - cost_text_size.x - 10, 
			self.center_pos.y - self.size.y / 2 + 10}, BUTTON_TEXT_FONT_SIZE, color = rl.DARKGRAY)

		// Draw sprite
		Y_OFFSET :: f32(40)
		size_increase_ratio := self.size.x / UPGRADE_BUTTON_SIZE.x
		sprite_size := 128 * size_increase_ratio
		sprite_src := rl.Rectangle{0, 0, f32(button_sprite.width), f32(button_sprite.height)}
		sprite_dest := rl.Rectangle{button_rect.x + button_rect.width / 2 - sprite_size / 2, button_rect.y + Y_OFFSET, sprite_size, sprite_size}
		rl.DrawTexturePro(button_sprite, sprite_src, sprite_dest, 0, 0, button_color)
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
		case f32: return int(x * 2)
		case BaseUpgradeType: switch(x) {
			case .EXTRA_WALLJUMPS: return 80 + 30 * run_upgrades[.EXTRA_WALLJUMPS]
			case .EXTRA_JUMP_HEIGHT: return 30 + 20 * run_upgrades[.EXTRA_JUMP_HEIGHT]
			case .EXTRA_MAX_HEALTH: return 50 + 20 * run_upgrades[.EXTRA_MAX_HEALTH]
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

GetUpgradeText :: proc(type: UpgradeType) -> [2]Maybe(string) {
	switch x in type {
		case f32: return { "BLESSING", concat({"(", to_string(x), " HP)"}) }
		case BaseUpgradeType: switch(x) {
			case .EXTRA_WALLJUMPS: return {"WALLJUMP", nil}
			case .EXTRA_JUMP_HEIGHT: return {"JUMP HEIGHT", nil}
			case .EXTRA_MAX_HEALTH: return {"MAX HEALTH", nil}
		}		
	}
	return "ERROR"
}

GetUpgradeSprite :: proc(type: UpgradeType) -> rl.Texture2D {
	switch x in type {
		case f32: return button_sprites[int(ButtonSprite.HEART)]
		case BaseUpgradeType: switch(x) {
			case .EXTRA_WALLJUMPS: return button_sprites[int(ButtonSprite.WALLJUMP)]
			case .EXTRA_JUMP_HEIGHT: return button_sprites[int(ButtonSprite.JUMP_HEIGHT)]
			case .EXTRA_MAX_HEALTH: return button_sprites[int(ButtonSprite.HEART)]
		}		
	}
	return button_sprites[int(ButtonSprite.HEART)]
}