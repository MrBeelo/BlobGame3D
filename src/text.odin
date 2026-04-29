package bg3d

import "core:fmt"
import "core:math/rand"
import "core:unicode/utf8"
import rl "vendor:raylib"

changa_one: [2]rl.Font // Regular, Italic
instrument_serif: [2]rl.Font // Regular, Italic

FontName :: enum { CHANGA_ONE, INSTRUMENT_SERIF }
FontType :: enum { REGULAR, ITALIC }

BorderInfo :: struct {
	bordered: bool,
	border_thickness: f32,
	border_color: rl.Color
}

LoadFonts :: proc() {
	changa_one[0] = LoadFontDef("changa_one_regular")
	changa_one[1] = LoadFontDef("changa_one_italic")
	instrument_serif[0] = LoadFontDef("instrument_serif_regular")
	instrument_serif[1] = LoadFontDef("instrument_serif_italic")
}

UnloadFonts :: proc() {
	rl.UnloadFont(changa_one[0])
	rl.UnloadFont(changa_one[1])
	rl.UnloadFont(instrument_serif[0])
	rl.UnloadFont(instrument_serif[1])
}

GetFont :: proc(name: FontName, type: FontType) -> rl.Font {
	switch(name) {
		case .CHANGA_ONE: switch(type) {
			case .REGULAR: return changa_one[0]
			case .ITALIC: return changa_one[1]
		}
		case .INSTRUMENT_SERIF: switch(type) {
			case .REGULAR: return instrument_serif[0]
			case .ITALIC: return instrument_serif[1]
		}
	}
	
	return rl.GetFontDefault()
}

DrawText :: proc(text: string, pos: rl.Vector2, font_size: f32, font_spacing: f32 = 5, font_name := FontName.CHANGA_ONE, font_type := FontType.REGULAR, 
color := rl.WHITE, border_info := BorderInfo{}) {
	if(border_info.bordered) do for i in -1..=1 do for j in -1..=1 do if(i != 0 || j != 0) {
		rl.DrawTextEx(GetFont(font_name, font_type), to_cstr(text), pos + {f32(i) * border_info.border_thickness, f32(j) * border_info.border_thickness}, 
			font_size, font_spacing, border_info.border_color) }
	rl.DrawTextEx(GetFont(font_name, font_type), to_cstr(text), pos, font_size, font_spacing, color)
}

MeasureText :: proc(text: string, font_size: f32, font_spacing: f32 = 5, font_name := FontName.CHANGA_ONE, font_type := FontType.REGULAR) -> rl.Vector2 {
	return rl.MeasureTextEx(GetFont(font_name, font_type), to_cstr(text), font_size, font_spacing)
}

DrawTextShaky :: proc(text: string, pos: rl.Vector2, font_size: f32, font_spacing: f32 = 5, font_name := FontName.CHANGA_ONE, font_type := FontType.REGULAR, 
color := rl.WHITE, border_info := BorderInfo{}, shakiness := rl.Vector2{2, 1.5}, shake_length: f32 = 2, modifier := "") {
	random_text := concat({text, modifier})
	time := f32(rl.GetTime())
	hash_offset := djb2_hash(random_text)
	off_x := sin((time + hash_offset) * shakiness.x) * shake_length
	off_y := cos((time + hash_offset) * shakiness.y) * shake_length
	DrawText(text, {pos.x + off_x, pos.y + off_y}, font_size, font_spacing, font_name, font_type, color, border_info)
}

DrawTextIndividiShaky :: proc(text: string, pos: rl.Vector2, font_size: f32, font_spacing: f32 = 5, font_name := FontName.CHANGA_ONE, font_type := FontType.REGULAR, 
color := rl.WHITE, border_info := BorderInfo{}, shakiness := rl.Vector2{1, 0.75}, shake_length: f32 = 2) {
	built_string := ""
	cursor_x := pos.x
	for char, index in text {
		buf, n := utf8.encode_rune(char)
		str := string(buf[:n])
			
		DrawTextShaky(str, {cursor_x, pos.y}, font_size, font_spacing, font_name, font_type, color, border_info,
			shakiness, shake_length, string(fmt.ctprintf("%f", cursor_x)))
        size := MeasureText(str, font_size, font_spacing, font_name, font_type)
        cursor_x += size.x + font_spacing
	}
}

DrawTextSpiky :: proc(text: string, pos: rl.Vector2, font_size: f32, font_spacing: f32 = 5, font_name := FontName.CHANGA_ONE, font_type := FontType.REGULAR, 
color := rl.WHITE, border_info := BorderInfo{}, spikyness := rl.Vector2{2, 1.5}) {
	offset_x := rand.float32_range(-spikyness.x, spikyness.x)
	offset_y := rand.float32_range(-spikyness.y, spikyness.y)
	DrawText(text, {pos.x + offset_x, pos.y + offset_y}, font_size, font_spacing, font_name, font_type, color, border_info)
}

DrawTextCenterX :: proc(text: string, pos_y: f32, font_size: f32, font_spacing: f32 = 5, 
font_name := FontName.CHANGA_ONE, font_type := FontType.REGULAR, color := rl.WHITE, border_info := BorderInfo{}) {
	text_size := MeasureText(text, font_size, font_spacing, font_name, font_type)
	DrawText(text, {SCREEN_SIZE.x / 2 - text_size.x / 2, pos_y}, font_size, font_spacing, font_name, font_type, color, border_info)
}

DrawTextCenterXY :: proc(text: string, font_size: f32, font_spacing: f32 = 5, 
font_name := FontName.CHANGA_ONE, font_type := FontType.REGULAR, color := rl.WHITE, border_info := BorderInfo{}) {
	text_size := MeasureText(text, font_size, font_spacing, font_name, font_type)
	DrawText(text, {SCREEN_SIZE.x / 2 - text_size.x / 2, SCREEN_SIZE.y / 2 - text_size.y / 2}, font_size, font_spacing, 
		font_name, font_type, color, border_info)
}