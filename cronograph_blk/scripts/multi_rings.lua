--==============================================================================
--                            multi_rings.lua
--
--  author  : SLK
--  version : v2011011601
--  license : Distributed under the terms of GNU GPL version 2 or later
--
--==============================================================================

require 'cairo'

--------------------------------------------------------------------------------
--                                                                    clock DATA
-- HOURS
local clock_h = {
	{
		name='time', arg='%H', max_value=12,
		x=150, y=150,
		graph_radius=140,
		graph_thickness=3,
		graph_unit_angle=30, graph_unit_thickness=5,
		graph_bg_colour=0xFFFFFF, graph_bg_alpha=0.0,
		graph_fg_colour=0xFFFFFF, graph_fg_alpha=0.0,
		txt_radius=100,
		txt_weight=1, txt_size=10.0,
		txt_fg_colour=0xFFFFFF, txt_fg_alpha=0.0,
		graduation_radius=127,
		graduation_thickness=10, graduation_mark_thickness=2,
		graduation_unit_angle=30,
		graduation_fg_colour=0x000000, graduation_fg_alpha=0.6
	},
}
--[[
-- MINUTES
local clock_m = {
	{
		name='time', arg='%M', max_value=60,
		x=150, y=150,
		graph_radius=100,
		graph_thickness=1,
		graph_unit_angle=6, graph_unit_thickness=3,
		graph_bg_colour=0xFFFFFF, graph_bg_alpha=0.0,
		graph_fg_colour=0xFFFFFF, graph_fg_alpha=0.0,
		txt_radius=100,
		txt_weight=0, txt_size=9.0,
		txt_fg_colour=0xFFFFFF, txt_fg_alpha=0.0,
		graduation_radius=57,
		graduation_thickness=0, graduation_mark_thickness=2,
		graduation_unit_angle=30,
		graduation_fg_colour=0x000000, graduation_fg_alpha=0.9
	},
}

-- SECONDS
local clock_s = {
	{
		name='time', arg='%S', max_value=60,
		x=150, y=150,
		graph_radius=50,
		graph_thickness=3,
		graph_unit_angle=6, graph_unit_thickness=3,
		graph_bg_colour=0xFFFFFF, graph_bg_alpha=0.0,
		graph_fg_colour=0xFFFFFF, graph_fg_alpha=0.0,
		txt_radius=100,
		txt_weight=0, txt_size=12.0,
		txt_fg_colour=0xFFFFFF, txt_fg_alpha=0.0,
		graduation_radius=0,
		graduation_thickness=0, graduation_mark_thickness=0,
		graduation_unit_angle=0,
		graduation_fg_colour=0xFFFFFF, graduation_fg_alpha=0.0
	},
}
]]

--------------------------------------------------------------------------------
--                                                                    gauge DATA
local gauge = {
	{
		name='fs_used_perc', arg='/', max_value=100,
		x=150, y=75,
		graph_radius=13,
		graph_thickness=23,
		graph_start_angle=0,
		graph_unit_angle=3.5, graph_unit_thickness=3.0,
		graph_bg_colour=0x909090, graph_bg_alpha=0.1,
		graph_fg_colour=0x0099FF, graph_fg_alpha=0.3,
		hand_fg_colour=0x830000, hand_fg_alpha=0.7,
		txt_radius=1,
		txt_weight=0, txt_size=8.0,
		txt_fg_colour=0xFFFFFF, txt_fg_alpha=0.0,
		graduation_radius=22,
		graduation_thickness=4, graduation_mark_thickness=4,
		graduation_unit_angle=30,
		graduation_fg_colour=0x000000, graduation_fg_alpha=0.6,
		caption='',
		caption_weight=1, caption_size=8.0,
		caption_fg_colour=0xFFFFFF, caption_fg_alpha=0.0
	},
	{
		name='cpu', arg='cpu0', max_value=100,
		x=85, y=150,
		graph_radius=16,
		graph_thickness=27,
		graph_start_angle=0,
		graph_unit_angle=3.5, graph_unit_thickness=3.0,
		graph_bg_colour=0x909090, graph_bg_alpha=0.1,
		graph_fg_colour=0xFF0066, graph_fg_alpha=0.3,
		hand_fg_colour=0x830000, hand_fg_alpha=0.7,
		txt_radius=1,
		txt_weight=0, txt_size=8.0,
		txt_fg_colour=0xFFFFFF, txt_fg_alpha=0.0,
		graduation_radius=27,
		graduation_thickness=4, graduation_mark_thickness=4,
		graduation_unit_angle=30,
		graduation_fg_colour=0x000000, graduation_fg_alpha=0.6,
		caption='',
		caption_weight=1, caption_size=8.0,
		caption_fg_colour=0xFFFFFF, caption_fg_alpha=0.0
	},
	{
		name='memperc', arg='', max_value=100,
		x=215, y=150,
		graph_radius=16,
		graph_thickness=27,
		graph_start_angle=0,
		graph_unit_angle=3.5, graph_unit_thickness=3.0,
		graph_bg_colour=0x909090, graph_bg_alpha=0.1,
		graph_fg_colour=0x66FF66, graph_fg_alpha=0.3,
		hand_fg_colour=0x830000, hand_fg_alpha=0.7,
		txt_radius=1,
		txt_weight=0, txt_size=8.0,
		txt_fg_colour=0xFFFFFF, txt_fg_alpha=0.0,
		graduation_radius=27,
		graduation_thickness=4, graduation_mark_thickness=4,
		graduation_unit_angle=30,
		graduation_fg_colour=0x000000, graduation_fg_alpha=0.6,
		caption='',
		caption_weight=1, caption_size=8.0,
		caption_fg_colour=0xFFFFFF, caption_fg_alpha=0.0
	},
}

-- Use these settings to define the origin and extent of your clock.
local clock_r=128
local clock_r_in=133 -- 133 or 147?

-- "clock_x" and "clock_y" are the coordinates of the centre of the clock, in pixels, from the top left of the Conky window.
local clock_x=150
local clock_y=150

-------------------------------------------------------------------------------
--                                                                 rgb_to_r_g_b
-- converts color in hexa to decimal
--
local function rgb_to_r_g_b(colour, alpha)
	return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
end

-------------------------------------------------------------------------------
--                                                            angle_to_position
-- convert degree to rad and rotate (0 degree is top/north)
--
local function angle_to_position(start_angle, current_angle)
	local pos = current_angle + start_angle
	return ((pos * (2 * math.pi / 360)) - (math.pi / 2))
end

-------------------------------------------------------------------------------
--                                                              draw_clock_ring
-- displays clock
--
local function draw_clock_ring(display, data, value)
	local max_value = data['max_value']
	local x, y = data['x'], data['y']
	local graph_radius = data['graph_radius']
	local graph_thickness, graph_unit_thickness = data['graph_thickness'], data['graph_unit_thickness']
	local graph_unit_angle = data['graph_unit_angle']
	local graph_bg_colour, graph_bg_alpha = data['graph_bg_colour'], data['graph_bg_alpha']
	local graph_fg_colour, graph_fg_alpha = data['graph_fg_colour'], data['graph_fg_alpha']

	--[[
	-- background ring
	cairo_arc(display, x, y, graph_radius, 0, 2 * math.pi)
	cairo_set_source_rgba(display, rgb_to_r_g_b(graph_bg_colour, graph_bg_alpha))
	cairo_set_line_width(display, graph_thickness)
	cairo_stroke(display)
	]]

	--[[ arc of value
	local val = (value % max_value)
	local i = 1
	-- Set once
	-- This color will then be used for any subsequent drawing operation until a new source pattern is set.
	-- http://www.cairographics.org/manual/cairo-cairo-t.html#cairo-set-source-rgba
	cairo_set_source_rgba(display, rgb_to_r_g_b(graph_fg_colour, graph_fg_alpha))
	while i <= val do
		cairo_arc(display, x, y, graph_radius, (((graph_unit_angle*i) - graph_unit_thickness) * (2*math.pi/360)) - (math.pi/2), ((graph_unit_angle * i) * (2*math.pi/360)) - (math.pi/2) )
		-- cairo_set_source_rgba(display, rgb_to_r_g_b(graph_fg_colour, graph_fg_alpha))
		cairo_stroke(display)
		i = i + 1
	end
	-- local angle = (graph_unit_angle * i) - graph_unit_thickness
	]]

	-- graduations marks
	local graduation_radius = data['graduation_radius']
	local graduation_thickness, graduation_mark_thickness = data['graduation_thickness'], data['graduation_mark_thickness']
	local graduation_unit_angle = data['graduation_unit_angle']
	local graduation_fg_colour, graduation_fg_alpha = data['graduation_fg_colour'], data['graduation_fg_alpha']
	if graduation_radius > 0 and graduation_thickness > 0 and graduation_unit_angle > 0 then
		local nb_graduation = 360 / graduation_unit_angle
		local i = 1
		-- Set once
		-- This color will then be used for any subsequent drawing operation until a new source pattern is set.
		-- http://www.cairographics.org/manual/cairo-cairo-t.html#cairo-set-source-rgba
		cairo_set_source_rgba(display, rgb_to_r_g_b(graduation_fg_colour, graduation_fg_alpha))
		while i <= nb_graduation do
			cairo_arc(display, x, y, graduation_radius, (((graduation_unit_angle * i)-(graduation_mark_thickness/2))*(2*math.pi/360))-(math.pi/2), (((graduation_unit_angle * i)+(graduation_mark_thickness/2))*(2*math.pi/360))-(math.pi/2))
			cairo_set_line_width(display, graduation_thickness)
			cairo_stroke(display)
			cairo_set_line_width(display, graph_thickness)
			i = i + 1
		end
	end

	--[[
	--text
	local txt_radius = data['txt_radius']
	local txt_weight, txt_size = data['txt_weight'], data['txt_size']
	local txt_fg_colour, txt_fg_alpha = data['txt_fg_colour'], data['txt_fg_alpha']
	local movex = txt_radius * (math.cos((angle * 2 * math.pi / 360)-(math.pi/2)))
	local movey = txt_radius * (math.sin((angle * 2 * math.pi / 360)-(math.pi/2)))
	cairo_select_font_face (display, "DejaVu Sans", CAIRO_FONT_SLANT_NORMAL, txt_weight)
	cairo_set_font_size (display, txt_size)
	cairo_set_source_rgba (display, rgb_to_r_g_b(txt_fg_colour, txt_fg_alpha))
	cairo_move_to (display, x + movex - (txt_size / 2), y + movey + 3)
	cairo_show_text (display, value)
	cairo_stroke (display)
	]]
end

-------------------------------------------------------------------------------
--                                                              draw_gauge_ring
-- displays gauges
--
local function draw_gauge_ring(display, data, value)
	local max_value = data['max_value']
	local x, y = data['x'], data['y']
	local graph_radius = data['graph_radius']
	local graph_thickness, graph_unit_thickness = data['graph_thickness'], data['graph_unit_thickness']
	local graph_start_angle = data['graph_start_angle']
	local graph_unit_angle = data['graph_unit_angle']
	local graph_bg_colour, graph_bg_alpha = data['graph_bg_colour'], data['graph_bg_alpha']
	local graph_fg_colour, graph_fg_alpha = data['graph_fg_colour'], data['graph_fg_alpha']
	local hand_fg_colour, hand_fg_alpha = data['hand_fg_colour'], data['hand_fg_alpha']
	local graph_end_angle = (max_value * graph_unit_angle) % 360

	-- background ring
	cairo_arc(display, x, y, graph_radius, angle_to_position(graph_start_angle, 0), angle_to_position(graph_start_angle, graph_end_angle))
	cairo_set_source_rgba(display, rgb_to_r_g_b(graph_bg_colour, graph_bg_alpha))
	cairo_set_line_width(display, graph_thickness)
	cairo_stroke(display)

	-- arc of value
	local val = value % (max_value + 1)
	local start_arc = 0
	local stop_arc = 0
	local i = 1
	while i <= val do
		start_arc = (graph_unit_angle * i) - graph_unit_thickness
		stop_arc = (graph_unit_angle * i)
		cairo_arc(display, x, y, graph_radius, angle_to_position(graph_start_angle, start_arc), angle_to_position(graph_start_angle, stop_arc))
		cairo_set_source_rgba(display, rgb_to_r_g_b(graph_fg_colour, graph_fg_alpha))
		cairo_stroke(display)
		i = i + 1
	end
	-- local angle = start_arc

	-- hand
	start_arc = (graph_unit_angle * val) - (graph_unit_thickness * 2) - 1
	stop_arc = (graph_unit_angle * val)
	cairo_arc(display, x, y, graph_radius - 2, angle_to_position(graph_start_angle, start_arc), angle_to_position(graph_start_angle, stop_arc))
	cairo_set_source_rgba(display, rgb_to_r_g_b(hand_fg_colour, hand_fg_alpha))
	cairo_stroke(display)

	-- graduations marks
	local graduation_radius = data['graduation_radius']
	local graduation_thickness, graduation_mark_thickness = data['graduation_thickness'], data['graduation_mark_thickness']
	local graduation_unit_angle = data['graduation_unit_angle']
	local graduation_fg_colour, graduation_fg_alpha = data['graduation_fg_colour'], data['graduation_fg_alpha']
	if graduation_radius > 0 and graduation_thickness > 0 and graduation_unit_angle > 0 then
		local nb_graduation = graph_end_angle / graduation_unit_angle
		local i = 0
		while i < nb_graduation do
			cairo_set_line_width(display, graduation_thickness)
			start_arc = (graduation_unit_angle * i) - (graduation_mark_thickness / 2)
			stop_arc = (graduation_unit_angle * i) + (graduation_mark_thickness / 2)
			cairo_arc(display, x, y, graduation_radius, angle_to_position(graph_start_angle, start_arc), angle_to_position(graph_start_angle, stop_arc))
			cairo_set_source_rgba(display, rgb_to_r_g_b(graduation_fg_colour, graduation_fg_alpha))
			cairo_stroke(display)
			cairo_set_line_width(display, graph_thickness)
			i = i + 1
		end
	end

	--[[
	-- text
	local txt_radius = data['txt_radius']
	local txt_weight, txt_size = data['txt_weight'], data['txt_size']
	local txt_fg_colour, txt_fg_alpha = data['txt_fg_colour'], data['txt_fg_alpha']
	local movex = txt_radius * math.cos(angle_to_position(graph_start_angle, angle))
	local movey = txt_radius * math.sin(angle_to_position(graph_start_angle, angle))
	cairo_select_font_face (display, "DejaVu Sans", CAIRO_FONT_SLANT_NORMAL, txt_weight)
	cairo_set_font_size (display, txt_size)
	cairo_set_source_rgba (display, rgb_to_r_g_b(txt_fg_colour, txt_fg_alpha))
	cairo_move_to (display, x + movex - (txt_size / 2), y + movey + 3)
	cairo_show_text (display, value)
	cairo_stroke (display)

	-- caption
	local caption = data['caption']
	local caption_weight, caption_size = data['caption_weight'], data['caption_size']
	local caption_fg_colour, caption_fg_alpha = data['caption_fg_colour'], data['caption_fg_alpha']
	local tox = graph_radius * (math.cos((graph_start_angle * 2 * math.pi / 360)-(math.pi/2)))
	local toy = graph_radius * (math.sin((graph_start_angle * 2 * math.pi / 360)-(math.pi/2)))
	cairo_select_font_face (display, "DejaVu Sans", CAIRO_FONT_SLANT_NORMAL, caption_weight)
	cairo_set_font_size (display, caption_size)
	cairo_set_source_rgba (display, rgb_to_r_g_b(caption_fg_colour, caption_fg_alpha))
	cairo_move_to (display, x + tox + 5, y + toy + 1)
	-- bad hack but not enough time !
	if graph_start_angle < 105 then
		cairo_move_to (display, x + tox - 30, y + toy + 1)
	end
	cairo_show_text (display, caption)
	cairo_stroke (display)
	]]
end

-------------------------------------------------------------------------------
--                                                               go_clock_rings
-- loads data and displays clock
--
local function go_clock_rings(display)
	local function load_clock_rings(display, data)
		local str, value = '', 0
		str = string.format('${%s %s}', data['name'], data['arg'])
		str = conky_parse(str)
		value = tonumber(str)
		draw_clock_ring(display, data, value)
	end

	for i in pairs(clock_h) do
		load_clock_rings(display, clock_h[i])
	end
	--[[
	for i in pairs(clock_m) do
		load_clock_rings(display, clock_m[i])
	end
	for i in pairs(clock_s) do
		load_clock_rings(display, clock_s[i])
	end
	]]
end

-------------------------------------------------------------------------------
--                                                               go_gauge_rings
-- loads data and displays gauges
--
local function go_gauge_rings(display)
	local function load_gauge_rings(display, data)
		local str, value = '', 0
		str = string.format('${%s %s}', data['name'], data['arg'])
		str = conky_parse(str)
		value = tonumber(str)
		draw_gauge_ring(display, data, value)
	end

	for i in pairs(gauge) do
		load_gauge_rings(display, gauge[i])
	end
end

local function draw_background_circle(display)
	cairo_set_source_rgba(display,rgb_to_r_g_b(0xE6FFFF,0.7))
	cairo_set_line_width (display, 0)
	cairo_arc (display, clock_x, clock_y, clock_r_in, 0, 360)
	cairo_fill (display)
end

-------------------------------------------------------------------------------
--                                                            conky_multi_rings
function conky_multi_rings()

	-- Check that Conky has been running for at least 2s
	-- We use the lua_loader script that makes wait for this
	if (conky_window == nil) or (tonumber(conky_parse('${updates}')) < 2) then return end

	local cs = cairo_xlib_surface_create(conky_window.display,
					     conky_window.drawable,
					     conky_window.visual,
					     conky_window.width,
					     conky_window.height)
	local cr = cairo_create(cs)

	-- This function references surface, so you can immediately call
	-- cairo_surface_destroy() on it if you don't need to maintain a separate reference to it.
	cairo_surface_destroy(cs)
	cs = nil

	draw_background_circle(cr)

	go_clock_rings(cr)
	go_gauge_rings(cr)

	cairo_destroy(cr)
	cr = nil

	-- #419 memory leak when calling top objects with conky_parse in lua
	-- http://sourceforge.net/p/conky/bugs/419/
	collectgarbage()

	return
end
