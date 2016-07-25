package.path = package.path .. ";" .. os.getenv ("HOME") .. "/.conky/cronograph_blk/scripts/?.lua"

require("clock_rings")
require("multi_rings")


function conky_main_loader ()
	-- Check that Conky has been running for at least 2s
	if (conky_window == nil) or (tonumber(conky_parse('${updates}')) < 2) then return end

	clock_rings()
	multi_rings()

	-- #419 memory leak when calling top objects with conky_parse in lua
	-- http://sourceforge.net/p/conky/bugs/419/
	collectgarbage()

	return
end
