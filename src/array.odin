package bg3d

contains :: proc(arr: []$T, x: T) -> bool { for y in (arr) do if y == x { return true }; return false }
arr_to_slice :: proc(arr: [$T]$U) -> []U { new_arr := arr; return new_arr[:] }