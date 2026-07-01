package bg3d

import hlp "helper"
import "core:strings"
import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:unicode/utf8"
import rl "vendor:raylib"

//FontName :: enum { CHANGA_ONE, INSTRUMENT_SERIF, }
//FontType :: enum { REGULAR, ITALIC, }
FontTyp :: enum { CHANGA_ONE, CHANGA_ONE_ITALIC, INSTRUMENT_SERIF, INSTRUMENT_SERIF_ITALIC }
FontInfo :: struct { type: FontTyp, size: f32 }
font_cache: map[FontInfo]rl.Font

StaticAnim :: struct {}
ShakyAnim :: struct { shakiness: rl.Vector2, shake_length: f32, modifier: string }
IndividiShakyAnim :: struct { shakiness: rl.Vector2, shake_length: f32 }
SpikyAnim :: struct { spikyness: rl.Vector2 }
IndividiSpikyAnim :: struct { spikyness: rl.Vector2 }
TextAnimation :: union { StaticAnim, ShakyAnim, IndividiShakyAnim, SpikyAnim, IndividiSpikyAnim }
BorderInfo :: struct { bordered: bool, border_thickness: f32, border_color: rl.Color, }

LoadFonts :: proc() {
	font_cache = make(map[FontInfo]rl.Font)
}

UnloadFonts :: proc() {
	for _, font in font_cache do rl.UnloadFont(font)
}

GetFontName :: proc(type: FontTyp) -> string {
	switch type {
	case .CHANGA_ONE: return "changa_one_regular"
	case .CHANGA_ONE_ITALIC: return "changa_one_italic"
	case .INSTRUMENT_SERIF: return "instrument_serif_regular"
	case .INSTRUMENT_SERIF_ITALIC: return "instrument_serif_italic"
	}
	return ""
}

GetFont :: proc(type: FontTyp, size: f32) -> rl.Font {
	ROUND_VAL :: f32(16)
	rounded_size := math.round(size / ROUND_VAL) * ROUND_VAL
	rounded_size = math.max(rounded_size, ROUND_VAL)
	info := FontInfo{type, rounded_size}
	
	if font, ok := font_cache[info]; ok {
		return font
	} else {
		new_font := LoadFontDef(GetFontName(type), i32(rounded_size))
		rl.SetTextureFilter(new_font.texture, .BILINEAR)
		font_cache[info] = new_font
		return new_font
	}
	
	return rl.GetFontDefault()
}

DrawText :: proc(text: string, pos: rl.Vector2, font_size: f32, font_spacing: f32 = 5, font_type := FontTyp.CHANGA_ONE, 
color := rl.WHITE, border_info := BorderInfo{}, anim: TextAnimation = StaticAnim{}) {
	switch a in anim {
	case StaticAnim: DrawTextStatic(text, pos, font_size, font_spacing, font_type, color, border_info)
	case ShakyAnim: DrawTextShaky(text, pos, font_size, font_spacing, font_type, color, border_info, a.shakiness, a.shake_length, a.modifier)
	case IndividiShakyAnim: DrawTextIndividiShaky(text, pos, font_size, font_spacing, font_type, color, border_info, a.shakiness, a.shake_length)
	case SpikyAnim: DrawTextSpiky(text, pos, font_size, font_spacing, font_type, color, border_info, a.spikyness)
	case IndividiSpikyAnim: DrawTextIndividiSpiky(text, pos, font_size, font_spacing, font_type, color, border_info, a.spikyness)
	}
}

MeasureText :: proc(text: string, font_size: f32, font_spacing: f32 = 5, font_type := FontTyp.CHANGA_ONE) -> rl.Vector2 {
	return rl.MeasureTextEx(GetFont(font_type, font_size), strings.clone_to_cstring(text), font_size, font_spacing)
}

DrawTextStatic :: proc(text: string, pos: rl.Vector2, font_size: f32, font_spacing: f32 = 5, font_type := FontTyp.CHANGA_ONE, 
color := rl.WHITE, border_info := BorderInfo{}) {
	ctext := strings.clone_to_cstring(text)
	font := GetFont(font_type, font_size)
	if border_info.bordered do for i in -1..=1 do for j in -1..=1 do if i != 0 || j != 0 {
		thickness := math.max(math.round(font_size / 160), 1) * border_info.border_thickness
		rl.DrawTextEx(font, ctext, pos + {f32(i) * thickness, f32(j) * thickness}, font_size, font_spacing, border_info.border_color) 
	}
	rl.DrawTextEx(font, ctext, pos, font_size, font_spacing, color)
}

DrawTextShaky :: proc(text: string, pos: rl.Vector2, font_size: f32, font_spacing: f32 = 5, font_type := FontTyp.CHANGA_ONE, 
color := rl.WHITE, border_info := BorderInfo{}, shakiness := rl.Vector2{2, 1.5}, shake_length: f32 = 2, modifier := "") {
	random_text := strings.concatenate({text, modifier})
	time := f32(rl.GetTime())
	hash_offset := hlp.djb2_hash(random_text)
	off_x := math.sin((time + hash_offset) * shakiness.x) * shake_length
	off_y := math.cos((time + hash_offset) * shakiness.y) * shake_length
	DrawTextStatic(text, {pos.x + off_x, pos.y + off_y}, font_size, font_spacing, font_type, color, border_info)
}

DrawTextIndividiShaky :: proc(text: string, pos: rl.Vector2, font_size: f32, font_spacing: f32 = 5, font_type := FontTyp.CHANGA_ONE, 
color := rl.WHITE, border_info := BorderInfo{}, shakiness := rl.Vector2{1, 0.75}, shake_length: f32 = 2) {
	cursor_x := pos.x
	for char in text {
		buf, n := utf8.encode_rune(char)
		str := string(buf[:n])
			
		DrawTextShaky(str, {cursor_x, pos.y}, font_size, font_spacing, font_type, color, border_info,
			shakiness, shake_length, string(fmt.ctprintf("%f", cursor_x)))
        size := MeasureText(str, font_size, font_spacing, font_type)
        cursor_x += size.x + font_spacing
	}
}

DrawTextSpiky :: proc(text: string, pos: rl.Vector2, font_size: f32, font_spacing: f32 = 5, font_type := FontTyp.CHANGA_ONE, 
color := rl.WHITE, border_info := BorderInfo{}, spikyness := rl.Vector2{2, 1.5}) {
	offset_x := rand.float32_range(-spikyness.x, spikyness.x)
	offset_y := rand.float32_range(-spikyness.y, spikyness.y)
	DrawTextStatic(text, {pos.x + offset_x, pos.y + offset_y}, font_size, font_spacing, font_type, color, border_info)
}

DrawTextIndividiSpiky :: proc(text: string, pos: rl.Vector2, font_size: f32, font_spacing: f32 = 5, font_type := FontTyp.CHANGA_ONE, 
color := rl.WHITE, border_info := BorderInfo{}, spikyness := rl.Vector2{2, 1.5}) {
	cursor_x := pos.x
	for char in text {
		buf, n := utf8.encode_rune(char)
		str := string(buf[:n])
		DrawTextSpiky(str, {cursor_x, pos.y}, font_size, font_spacing, font_type, color, border_info, spikyness)
        size := MeasureText(str, font_size, font_spacing, font_type)
        cursor_x += size.x + font_spacing
	}
}

DrawTextCenterX :: proc(text: string, pos_y: f32, font_size: f32, font_spacing: f32 = 5, 
font_type := FontTyp.CHANGA_ONE, color := rl.WHITE, border_info := BorderInfo{}, anim: TextAnimation = StaticAnim{}) {
	text_size := MeasureText(text, font_size, font_spacing, font_type)
	DrawText(text, {SCREEN_SIZE.x / 2 - text_size.x / 2, pos_y}, font_size, font_spacing, font_type, color, border_info, anim)
}

DrawTextCenterXY :: proc(text: string, font_size: f32, font_spacing: f32 = 5, 
font_type := FontTyp.CHANGA_ONE, color := rl.WHITE, border_info := BorderInfo{}, anim: TextAnimation = StaticAnim{}) {
	text_size := MeasureText(text, font_size, font_spacing, font_type)
	DrawText(text, {SCREEN_SIZE.x / 2 - text_size.x / 2, SCREEN_SIZE.y / 2 - text_size.y / 2}, font_size, font_spacing, 
		font_type, color, border_info, anim)
}

DrawTitle :: proc(text: string, font_type := FontTyp.CHANGA_ONE) {
	TITLE_TEXT_FONT_SIZE :: 64
	TITLE_TEXT_FONT_SPACING :: 5
	DrawTextCenterX(text, 100, TITLE_TEXT_FONT_SIZE, TITLE_TEXT_FONT_SPACING, font_type, rl.WHITE, {true, 5, rl.BLACK})
}