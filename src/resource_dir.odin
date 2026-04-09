// resource_dir.h (from raylibExtras) translated to Odin and slightly modified by MrBeelo

package bb3d

import rl "vendor:raylib"

SearchAndSetResourceDir :: proc(folder_name: cstring) -> bool {
	if(rl.DirectoryExists(folder_name)) {
		rl.ChangeDirectory(folder_name)
		return true
	}
	
	app_dir := rl.GetApplicationDirectory()
	if(ChangeAndCheckDir(rl.TextFormat("%s%s", app_dir, folder_name))) do return true
	if(ChangeAndCheckDir(rl.TextFormat("%s../%s", app_dir, folder_name))) do return true
	if(ChangeAndCheckDir(rl.TextFormat("%s../../%s", app_dir, folder_name))) do return true
	if(ChangeAndCheckDir(rl.TextFormat("%s../../../%s", app_dir, folder_name))) do return true
	
	return false
}

ChangeAndCheckDir :: proc(dir: cstring) -> bool {
	if(rl.DirectoryExists(dir)) {
		rl.ChangeDirectory(dir)
		return true
	}
	return false
}