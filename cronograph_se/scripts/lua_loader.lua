package.path = package.path .. ";" .. os.getenv ("HOME") .. "/.conky/cronograph_se/scripts/?.lua"

require("clock_rings")
require("multi_rings")

function conky_lua_loader ()
	-- Check that Conky has been running for at least 5s
	if (conky_window == nil) or (tonumber(conky_parse('${updates}')) < 5) then return end
	conky_multi_rings()
	conky_clock_rings()
end
