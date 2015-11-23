package.path = package.path .. ";" .. os.getenv ("HOME") .. "/.conky/cronograph_blk/scripts/?.lua"

require("clock_rings")
require("multi_rings")

function conky_lua_loader ()
	-- Check that Conky has been running for at least 5s
	if (conky_window == nil) or (tonumber(conky_parse('${updates}')) < 5) then return end
	conky_multi_rings()
	conky_clock_rings()

	-- #419 memory leak when calling top objects with conky_parse in lua
	-- http://sourceforge.net/p/conky/bugs/419/
	collectgarbage()

	return
end
