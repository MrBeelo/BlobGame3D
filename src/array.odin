package bg3d

contains :: proc(arr: []$T, x: T) -> bool { for y in (arr) do if y == x { return true }; return false }