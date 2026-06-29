package bg3d

import "core:strings"
import rl "vendor:raylib"
import "core:math/rand"

MAX_UPGRADES :: 5
run_upgrades: map[UpgradeType]int

UpgradeType :: enum {
	HEALTH_BLESSING,
	TIME_EXTENSION,
	WALLJUMPS,
	JUMP_HEIGHT,
	MAX_HEALTH,
	RUN_SPEED,
	WALLJUMP_SPEED
}
	
Upgrade :: struct {
	type: UpgradeType,
	value: Maybe(f32)
}

UPGRADE_BUTTON_SIZE :: rl.Vector2{250, 330}
UPGRADE_BUTTON_SIZE_MAX :: rl.Vector2{UPGRADE_BUTTON_SIZE.x * 120 / 100, UPGRADE_BUTTON_SIZE.y * 120 / 100}
UpgradeButton :: struct {
	center_pos: rl.Vector2,
	upgrade: Upgrade,
	size: rl.Vector2,
	hovered: bool,
	bought: bool
}

button_sprites: [len(UpgradeType)]rl.Texture2D

LoadUpgradeButtons :: proc() {
	button_sprites[int(UpgradeType.HEALTH_BLESSING)] = LoadTexture("powerups/health_blessing.png")
	button_sprites[int(UpgradeType.TIME_EXTENSION)] = LoadTexture("powerups/time_extension.png")
	button_sprites[int(UpgradeType.WALLJUMPS)] = LoadTexture("powerups/walljumps.png")
	button_sprites[int(UpgradeType.JUMP_HEIGHT)] = LoadTexture("powerups/jump_height.png")
	button_sprites[int(UpgradeType.MAX_HEALTH)] = LoadTexture("powerups/max_health.png")
	button_sprites[int(UpgradeType.RUN_SPEED)] = LoadTexture("powerups/run_speed.png")
	button_sprites[int(UpgradeType.WALLJUMP_SPEED)] = LoadTexture("powerups/walljump_speed.png")
}

UnloadUpgradeButtons :: proc() {
	for texture in button_sprites do rl.UnloadTexture(texture)
}

NewUpgradeButton :: proc(center_pos: rl.Vector2, upgrade := Upgrade{.HEALTH_BLESSING, 0}) -> UpgradeButton {
	return UpgradeButton{center_pos, upgrade, UPGRADE_BUTTON_SIZE, false, false}
}

GetAvailableBaseUpgradeTypes :: proc() -> []UpgradeType {
	arr: [dynamic]UpgradeType
	for upgrade in UpgradeType {
 		if upgrade == .HEALTH_BLESSING || upgrade == .TIME_EXTENSION { append(&arr, upgrade); continue }
		if run_upgrades[upgrade] < MAX_UPGRADES do append(&arr, upgrade)
	}
	return arr[:]
}

ResetUpgradeButton :: proc(self: ^UpgradeButton) {
	chance := rand.int_range(0, 10)
	available_upgrade_types := GetAvailableBaseUpgradeTypes()
	upgrade := available_upgrade_types[rand.int_range(0, len(available_upgrade_types))]
	#partial switch upgrade {
		case .HEALTH_BLESSING: self.upgrade = {upgrade, f32(rand.int_range(25, 50))}
		case .TIME_EXTENSION: self.upgrade = {upgrade, f32(rand.int_range(5, 30))}
		case: self.upgrade = {upgrade, nil}
	}
	self.bought = false
}

UpdateUpgradeButton :: proc(self: ^UpgradeButton) {
	was_hovered := self.hovered
	pos := self.center_pos - self.size / 2
	button_rect := rl.Rectangle{pos.x, pos.y, self.size.x, self.size.y}
	mouse_pos := GetVMousePos()
	self.hovered = rl.CheckCollisionPointRec(mouse_pos, button_rect)
	if self.hovered && !was_hovered do rl.PlaySound(ui_hover_sound)

	self.size.x = clamp(self.size.x, UPGRADE_BUTTON_SIZE.x, UPGRADE_BUTTON_SIZE_MAX.x)
	self.size.y = clamp(self.size.y, UPGRADE_BUTTON_SIZE.y, UPGRADE_BUTTON_SIZE_MAX.y)

	RESIZE_MOD :: f32(500)
	if self.hovered && self.size.x < UPGRADE_BUTTON_SIZE_MAX.x do self.size.x += rl.GetFrameTime() * RESIZE_MOD
	if self.hovered && self.size.y < UPGRADE_BUTTON_SIZE_MAX.y do self.size.y += rl.GetFrameTime() * RESIZE_MOD
	if !self.hovered && self.size.x > UPGRADE_BUTTON_SIZE.x do self.size.x -= rl.GetFrameTime() * RESIZE_MOD
	if !self.hovered && self.size.y > UPGRADE_BUTTON_SIZE.y do self.size.y -= rl.GetFrameTime() * RESIZE_MOD
	
	if self.hovered && rl.IsMouseButtonPressed(.LEFT) && !self.bought && run_stats.points >= GetUpgradeCost(self.upgrade) {
		rl.PlaySound(ui_click_sound)
		self.bought = true
		run_stats.points -= GetUpgradeCost(self.upgrade)
		#partial switch self.upgrade.type {
			case .HEALTH_BLESSING: player.health += (self.upgrade.value.? if self.upgrade.value != nil else 0)
			case .TIME_EXTENSION: AddClockSeconds((self.upgrade.value.? if self.upgrade.value != nil else 0))
			case: if run_upgrades[self.upgrade.type] < MAX_UPGRADES do run_upgrades[self.upgrade.type] += 1
		}
	}

	if run_upgrades[self.upgrade.type] >= MAX_UPGRADES && !self.bought do self.bought = true
}

DrawUpgradeButton :: proc(self: ^UpgradeButton) {
	pos := self.center_pos - self.size / 2
	button_rect := rl.Rectangle{pos.x, pos.y, self.size.x, self.size.y}
	
	button_color := GetUpgradeColor(self.upgrade)
	button_text := GetUpgradeText(self.upgrade)
	button_sprite := button_sprites[self.upgrade.type]
	
	ROUNDNESS :: 0.15
	SEGMENTS :: 4
	rl.DrawRectangleRounded(button_rect, ROUNDNESS, SEGMENTS, {30, 30, 30, 255})
	rl.DrawRectangleRoundedLinesEx(button_rect, ROUNDNESS, SEGMENTS, 5, button_color if !self.bought else rl.BLACK)
	
	if !self.bought {
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
		cost_text_size := MeasureText(to_string(GetUpgradeCost(self.upgrade)), BUTTON_TEXT_FONT_SIZE)
		DrawText(to_string(GetUpgradeCost(self.upgrade)), {self.center_pos.x - self.size.x / 2 + self.size.x - cost_text_size.x - 10, 
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

GetUpgradeCost :: proc(upgrade: Upgrade) -> int {
	switch upgrade.type {
		case .HEALTH_BLESSING: return int(upgrade.value.? * 2)
		case .TIME_EXTENSION: return int(upgrade.value.? * 2)
		case .WALLJUMPS: return 80 + 30 * run_upgrades[upgrade.type]
		case .JUMP_HEIGHT: return 30 + 20 * run_upgrades[upgrade.type]
		case .MAX_HEALTH: return 50 + 20 * run_upgrades[upgrade.type]
		case .RUN_SPEED: return 60 + 30 * run_upgrades[upgrade.type]
		case .WALLJUMP_SPEED: return 80 + 30 * run_upgrades[upgrade.type]
	}
	return 0
}

GetUpgradeColor :: proc(upgrade: Upgrade) -> rl.Color {
	switch upgrade.type {
		case .HEALTH_BLESSING: return rl.RED
		case .TIME_EXTENSION: return rl.GREEN
		case .WALLJUMPS: return rl.ORANGE
		case .JUMP_HEIGHT: return rl.YELLOW
		case .MAX_HEALTH: return rl.RED
		case .RUN_SPEED: return rl.SKYBLUE
		case .WALLJUMP_SPEED: return rl.ORANGE
	}
	return rl.BLACK
}

GetUpgradeText :: proc(upgrade: Upgrade) -> [2]Maybe(string) {
	switch upgrade.type {
		case .HEALTH_BLESSING: return { "BLESSING", strings.concatenate({"(", to_string(upgrade.value.?), " HP)"}) }
		case .TIME_EXTENSION: return { "MORE TIME", strings.concatenate({"(", to_string(upgrade.value.?), " seconds)"}) }
		case .WALLJUMPS: return {"MORE", "WALLJUMPS"}
		case .JUMP_HEIGHT: return {"JUMP HEIGHT", nil}
		case .MAX_HEALTH: return {"MAX HEALTH", nil}
		case .RUN_SPEED: return {"RUN SPEED", nil}
		case .WALLJUMP_SPEED: return {"WALLJUMP", "SPEED"}
	}
	return "ERROR"
}