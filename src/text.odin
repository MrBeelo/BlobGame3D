package bb3d

import "core:fmt"
//import "core:math/rand"
import "core:unicode/utf8"
import rl "vendor:raylib"

changa_one: [2]rl.Font // regular, italic

FontName :: enum { CHANGA_ONE }
FontType :: enum { REGULAR, ITALIC }

LoadFonts :: proc() {
	changa_one[0] = LoadFontDef("changa_one_regular")
	changa_one[1] = LoadFontDef("changa_one_italic")
}

UnloadFonts :: proc() {
	rl.UnloadFont(changa_one[0])
	rl.UnloadFont(changa_one[1])
}

GetFont :: proc(name: FontName, type: FontType) -> rl.Font {
	switch(name) {
		case .CHANGA_ONE: switch(type) {
			case .REGULAR: return changa_one[0]
			case .ITALIC: return changa_one[1]
		}
	}
	
	return rl.GetFontDefault()
}

DrawText :: proc(text: string, pos: rl.Vector2, font_size: f32, font_spacing: f32 = 5, font_name := FontName.CHANGA_ONE, font_type := FontType.REGULAR, color := rl.WHITE) {
	rl.DrawTextEx(GetFont(font_name, font_type), to_cstr(text), pos, font_size, font_spacing, color)
}

MeasureText :: proc(text: string, font_size: f32, font_spacing: f32 = 5, font_name := FontName.CHANGA_ONE, font_type := FontType.REGULAR) -> rl.Vector2 {
	return rl.MeasureTextEx(GetFont(font_name, font_type), to_cstr(text), font_size, font_spacing)
}

DrawTextBordered :: proc(text: string, pos: rl.Vector2, font_size: f32, font_spacing: f32 = 5, border_thickness: f32 = 3, font_name := FontName.CHANGA_ONE, font_type := FontType.REGULAR, 
color := rl.WHITE, border_color := rl.BLACK) {
	DrawText(text, {pos.x, pos.y + border_thickness}, font_size, font_spacing, font_name, font_type, border_color)
	DrawText(text, {pos.x, pos.y - border_thickness}, font_size, font_spacing, font_name, font_type, border_color)
	DrawText(text, {pos.x + border_thickness, pos.y}, font_size, font_spacing, font_name, font_type, border_color)
	DrawText(text, {pos.x - border_thickness, pos.y}, font_size, font_spacing, font_name, font_type, border_color)
	DrawText(text, {pos.x + border_thickness, pos.y + border_thickness}, font_size, font_spacing, font_name, font_type, border_color)
	DrawText(text, {pos.x + border_thickness, pos.y - border_thickness}, font_size, font_spacing, font_name, font_type, border_color)
	DrawText(text, {pos.x - border_thickness, pos.y + border_thickness}, font_size, font_spacing, font_name, font_type, border_color)
	DrawText(text, {pos.x - border_thickness, pos.y - border_thickness}, font_size, font_spacing, font_name, font_type, border_color)
	
	DrawText(text, pos, font_size, font_spacing, font_name, font_type, color)
}

DrawTextShaky :: proc(text: string, pos: rl.Vector2, font_size: f32, font_spacing: f32 = 5, font_name := FontName.CHANGA_ONE, font_type := FontType.REGULAR, 
color := rl.WHITE, shakiness := rl.Vector2{2, 1.5}, shake_length: f32 = 2, modifier := "") {
	random_text := concat({text, modifier})
	off_x := sin((f32(rl.GetTime()) + djb2_hash(random_text)) * shakiness.x) * shake_length
	off_y := cos((f32(rl.GetTime()) + djb2_hash(random_text)) * shakiness.y) * shake_length
	DrawText(text, {pos.x + off_x, pos.y + off_y}, font_size, font_spacing, font_name, font_type, color)
}

DrawTextShakyBordered :: proc(text: string, pos: rl.Vector2, font_size: f32, font_spacing: f32 = 5, border_thickness: f32 = 3, font_name := FontName.CHANGA_ONE, font_type := FontType.REGULAR, 
color := rl.WHITE, border_color := rl.BLACK, shakiness := rl.Vector2{2, 1.5}, shake_length: f32 = 2, modifier := "") {
	DrawTextShaky(text, {pos.x, pos.y + border_thickness}, font_size, font_spacing, font_name, font_type, border_color, shakiness, shake_length, modifier)
	DrawTextShaky(text, {pos.x, pos.y - border_thickness}, font_size, font_spacing, font_name, font_type, border_color, shakiness, shake_length, modifier)
	DrawTextShaky(text, {pos.x + border_thickness, pos.y}, font_size, font_spacing, font_name, font_type, border_color, shakiness, shake_length, modifier)
	DrawTextShaky(text, {pos.x - border_thickness, pos.y}, font_size, font_spacing, font_name, font_type, border_color, shakiness, shake_length, modifier)
	DrawTextShaky(text, {pos.x + border_thickness, pos.y + border_thickness}, font_size, font_spacing, font_name, font_type, border_color, shakiness, shake_length, modifier)
	DrawTextShaky(text, {pos.x + border_thickness, pos.y - border_thickness}, font_size, font_spacing, font_name, font_type, border_color, shakiness, shake_length, modifier)
	DrawTextShaky(text, {pos.x - border_thickness, pos.y + border_thickness}, font_size, font_spacing, font_name, font_type, border_color, shakiness, shake_length, modifier)
	DrawTextShaky(text, {pos.x - border_thickness, pos.y - border_thickness}, font_size, font_spacing, font_name, font_type, border_color, shakiness, shake_length, modifier)
	
	DrawTextShaky(text, pos, font_size, font_spacing, font_name, font_type, color, shakiness, shake_length, modifier)
}

DrawTextIndividiShaky :: proc(text: string, pos: rl.Vector2, font_size: f32, font_spacing: f32 = 5, font_name := FontName.CHANGA_ONE, font_type := FontType.REGULAR, 
color := rl.WHITE, shakiness := rl.Vector2{1, 0.75}, shake_length: f32 = 2) {
	built_string := ""
	cursor_x := pos.x
	for char, index in text {
		buf, n := utf8.encode_rune(char)
		str := string(buf[:n])
			
		DrawTextShaky(str, {cursor_x, pos.y}, font_size, font_spacing, font_name, font_type, color, shakiness, shake_length, string(fmt.ctprintf("%f", cursor_x)))
        size := MeasureText(str, font_size, font_spacing, font_name, font_type)
        cursor_x += size.x + font_spacing
	}
}

DrawTextIndividiShakyBordered :: proc(text: string, pos: rl.Vector2, font_size: f32, font_spacing: f32 = 5, border_thickness: f32 = 3, 
font_name := FontName.CHANGA_ONE, font_type := FontType.REGULAR, color := rl.WHITE, border_color := rl.BLACK, shakiness := rl.Vector2{1, 0.75}, 
shake_length: f32 = 2) {
	built_string := ""
	cursor_x := pos.x
	for char, index in text {
		buf, n := utf8.encode_rune(char)
		str := string(buf[:n])
		
		modifier := string(fmt.ctprintf("%f", cursor_x))
		
		DrawTextShaky(str, {cursor_x, pos.y + border_thickness}, font_size, font_spacing, font_name, font_type, border_color, shakiness, shake_length, modifier)
		DrawTextShaky(str, {cursor_x, pos.y - border_thickness}, font_size, font_spacing, font_name, font_type, border_color, shakiness, shake_length, modifier)
		DrawTextShaky(str, {cursor_x + border_thickness, pos.y}, font_size, font_spacing, font_name, font_type, border_color, shakiness, shake_length, modifier)
		DrawTextShaky(str, {cursor_x - border_thickness, pos.y}, font_size, font_spacing, font_name, font_type, border_color, shakiness, shake_length, modifier)
		DrawTextShaky(str, {cursor_x + border_thickness, pos.y + border_thickness}, font_size, font_spacing, font_name, font_type, border_color, shakiness, shake_length, modifier)
		DrawTextShaky(str, {cursor_x + border_thickness, pos.y - border_thickness}, font_size, font_spacing, font_name, font_type, border_color, shakiness, shake_length, modifier)
		DrawTextShaky(str, {cursor_x - border_thickness, pos.y + border_thickness}, font_size, font_spacing, font_name, font_type, border_color, shakiness, shake_length, modifier)
		DrawTextShaky(str, {cursor_x - border_thickness, pos.y - border_thickness}, font_size, font_spacing, font_name, font_type, border_color, shakiness, shake_length, modifier)
		
		DrawTextShaky(str, {cursor_x, pos.y}, font_size, font_spacing, font_name, font_type, color, shakiness, shake_length, modifier)
		
        size := MeasureText(str, font_size, font_spacing, font_name, font_type)
        cursor_x += size.x + font_spacing
	}
}