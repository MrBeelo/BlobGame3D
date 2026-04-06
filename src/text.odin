package bb3d

import "core:fmt"
import "core:math/rand"
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