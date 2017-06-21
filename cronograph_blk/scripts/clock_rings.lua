--[[
Clock Rings by londonali1010 (2009)

This script draws percentage meters as rings, and also draws clock hands if you want!
It is fully customisable; all options are described in the script. This script is
based off a combination of my clock.lua script and my rings.lua script.

IMPORTANT: if you are using the 'cpu' function, it will cause a segmentation fault
	   if it tries to draw a ring straight away. The if statement near the end
	   of the script uses a delay to make sure that this doesn't happen.
	   It calculates the length of the delay by the number of updates since
	   Conky started. Generally, a value of 5s is long enough, so if you update
	   Conky every 1s, use update_num > 5 in that if statement (the default).
	   If you only update Conky every 2s, you should change it to update_num > 3;
	   conversely if you update Conky every 0.5s, you should use update_num > 10.
	   ALSO, if you change your Conky, is it best to use "killall conky; conky"
	   to update it, otherwise the update_num will not be reset and you will get an error.

To call this script in Conky, use the following (assuming that you save this script to ~/scripts/rings.lua):
	lua_load ~/scripts/clock_rings-v1.1.1.lua
	lua_draw_hook_pre clock_rings

Changelog:
+ v1.1.1	-- Fixed minor bug that caused the script to crash if conky_parse() returns a nil value (20.10.2009)
+ v1.1		-- Added colour option for clock hands (07.10.2009)
+ v1.0		-- Original release (30.09.2009)
]]

require 'cairo'

local settings_table = {
	{
		-- Edit this table to customise your rings.
		-- You can create more rings simply by adding more elements to settings_table.
		-- "name" is the type of stat to display; you can choose from 'cpu',
		-- 'memperc', 'fs_used_perc', 'battery_used_perc'.
		name='time',
		-- "arg" is the argument to the stat type, e.g. if in Conky you
		-- would write ${cpu cpu0}, 'cpu0' would be the argument. If you
		-- would not use an argument in the Conky variable, use ''.
		arg='%I', -- .%M',
		-- "max" is the maximum value of the ring. If the Conky variable outputs a percentage, use 100.
		max=12,
		-- "bg_colour" is the colour of the base ring.
		bg_colour=0x333333,
		-- "bg_alpha" is the alpha value of the base ring.
		bg_alpha=0.6,
		-- "fg_colour" is the colour of the indicator part of the ring.
		fg_colour=0x000000,
		-- "fg_alpha" is the alpha value of the indicator part of the ring.
		fg_alpha=0.9,
		-- "x" and "y" are the x and y coordinates of the centre of the ring, relative to the top left corner of the Conky window.
		x=150, y=150,
		-- "radius" is the radius of the ring.
		radius=145,
		-- "thickness" is the thickness of the ring, centred around the radius.
		thickness=4,
		-- "start_angle" is the starting angle of the ring, in degrees, clockwise from top. Value can be either positive or negative.
		start_angle=0,
		-- "end_angle" is the ending angle of the ring, in degrees, clockwise from top. Value can be either positive or negative, but must be larger than start_angle.
		end_angle=360
	},
	{
		name='time',
		arg='%M', -- .%S',
		max=60,
		bg_colour=0x555555, bg_alpha=0.6,
		fg_colour=0x000000, fg_alpha=0.7,
		x=150, y=150,
		radius=140,
		thickness=4,
		start_angle=0,
		end_angle=360
	},
	{
		name='time',
		arg='%S',
		max=60,
		bg_colour=0x777777, bg_alpha=0.6,
		fg_colour=0x000000, fg_alpha=0.5,
		x=150, y=150,
		radius=135,
		thickness=4,
		start_angle=0,
		end_angle=360
	},
	--[[ -- due to background circle image
	{
		-- Watch inside drawing
		name='',
		arg='',
		max=100,
		--bg_colour=0x404040,
		--bg_alpha=0.2,
		bg_colour=0xFFFFFF,
		bg_alpha=0.0,
		fg_colour=0xFFFFFF,
		fg_alpha=0.0,
		x=150, y=150,
		radius=66,
		thickness=130,
		start_angle=0,
		end_angle=360
	},
	{
		-- Watch center circle
		name='',
		arg='',
		max=100,
		bg_colour=0xFFD700,
		bg_alpha=0.3,
		fg_colour=0x000000,
		fg_alpha=0.0,
		x=150, y=150,
		radius=1,
		thickness=40,
		start_angle=0,
		end_angle=360
	},]]
	{
		-- cpu outline
		name='',
		arg='',
		max=100,
		bg_colour=0x000000,
		bg_alpha=1.0,
		fg_colour=0x000000,
		fg_alpha=0.0,
		x=85, y=150,
		radius=30,
		thickness=1,
		start_angle=0,
		end_angle=360
	},
	{
		-- cpu inside
		name='',
		arg='',
		max=100,
		bg_colour=0xF3F9FF,
		bg_alpha=0.33,
		fg_colour=0xFFFFFF,
		fg_alpha=0.0,
		x=85, y=150,
		radius=16,
		thickness=27,
		start_angle=0,
		end_angle=360
	},
	{
		-- cpu inside dot
		name='',
		arg='',
		max=100,
		bg_colour=0xFFD700,
		bg_alpha=0.9,
		fg_colour=0x000000,
		fg_alpha=0.0,
		x=85, y=150,
		radius=1,
		thickness=3,
		start_angle=0,
		end_angle=360
	},
	{
		-- mem outline
		name='',
		arg='',
		max=100,
		bg_colour=0x000000,
		bg_alpha=1.0,
		fg_colour=0x000000,
		fg_alpha=0.0,
		x=215, y=150,
		radius=30,
		thickness=1,
		start_angle=0,
		end_angle=360
	},
	{
		-- mem inside
		name='',
		arg='',
		max=100,
		bg_colour=0xF3F9FF,
		bg_alpha=0.33,
		fg_colour=0xFFFFFF,
		fg_alpha=0.0,
		x=215, y=150,
		radius=16,
		thickness=27,
		start_angle=0,
		end_angle=360
	},
	{
		-- mem inside dot
		name='',
		arg='',
		max=100,
		bg_colour=0xFFD700,
		bg_alpha=0.9,
		fg_colour=0x000000,
		fg_alpha=0.0,
		x=215, y=150,
		radius=1,
		thickness=3,
		start_angle=0,
		end_angle=360
	},
	{

		-- hdd outline
		name='',
		arg='',
		max=100,
		bg_colour=0x000000,
		bg_alpha=1.0,
		fg_colour=0x000000,
		fg_alpha=0.0,
		x=150, y=75,
		radius=25,
		thickness=1,
		start_angle=0,
		end_angle=360
	},
	{
		-- hdd inside
		name='',
		arg='',
		max=100,
		bg_colour=0xF3FFFF,
		bg_alpha=0.33,
		fg_colour=0xFFFFFF,
		fg_alpha=0.0,
		x=150, y=75,
		radius=14,
		thickness=22,
		start_angle=0,
		end_angle=360
	},
	{
		-- hdd inside dot
		name='',
		arg='',
		max=100,
		bg_colour=0xFFD700,
		bg_alpha=0.9,
		fg_colour=0xFFFFFF,
		fg_alpha=0.0,
		x=150, y=75,
		radius=1,
		thickness=3,
		start_angle=0,
		end_angle=360
	},
}

-- Use these settings to define the origin and extent of your clock.
local clock_r=128

-- "clock_x" and "clock_y" are the coordinates of the centre of the clock, in pixels, from the top left of the Conky window.
local clock_x=150
local clock_y=150

-- Colour & alpha of the clock hands
local hours_colour=0x383436
local mins_colour=0x202020
local secs_colour=0x830000
local secs_shd_colour=0x888888
local secs_shade_off=4
local clock_alpha=0.7

-- Do you want to show the seconds hand?
local show_seconds=true

local function rgb_to_r_g_b(colour,alpha)
	return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
end

local function draw_ring(cr,t,pt)
	local w,h=conky_window.width,conky_window.height

	local xc,yc,ring_r,ring_w,sa,ea=pt['x'],pt['y'],pt['radius'],pt['thickness'],pt['start_angle'],pt['end_angle']
	local bgc, bga, fgc, fga=pt['bg_colour'], pt['bg_alpha'], pt['fg_colour'], pt['fg_alpha']

	local angle_0=sa*(2*math.pi/360)-math.pi/2
	local angle_f=ea*(2*math.pi/360)-math.pi/2
	local t_arc=t*(angle_f-angle_0)

	cairo_set_line_width(cr,ring_w)

	-- Draw ring
	cairo_set_source_rgba(cr,rgb_to_r_g_b(bgc,bga))
	cairo_arc(cr,xc,yc,ring_r,angle_0,angle_f)
	cairo_stroke(cr)

	-- Draw indicator ring
	cairo_set_source_rgba(cr,rgb_to_r_g_b(fgc,fga))
	cairo_arc(cr,xc,yc,ring_r,angle_0,angle_0+t_arc)
	cairo_stroke(cr)
end

local function draw_clock_hands(cr,xc,yc)
	local secs,mins,hours,secs_arc,mins_arc,hours_arc
	local xh,yh,xm,ym,xs,ys
	local xxh,yyh,xxm,yym,xxs,yys
	local saved_lc

	secs=os.date("%S")
	mins=os.date("%M")
	hours=os.date("%I")

	secs_arc=(2*math.pi/60)*secs
	mins_arc=(2*math.pi/60)*mins+secs_arc/60
	hours_arc=(2*math.pi/12)*hours+mins_arc/12

	saved_lc=cairo_get_line_cap (cr);
	cairo_set_line_cap(cr,CAIRO_LINE_CAP_ROUND)

	-- Draw hour hand
	xh=xc+0.55*clock_r*math.sin(hours_arc)
	yh=yc-0.55*clock_r*math.cos(hours_arc)
	-- and hour backhand
	xxh=xc-0.12*clock_r*math.sin(hours_arc)
	yyh=yc+0.12*clock_r*math.cos(hours_arc)
	cairo_set_line_width(cr,11)
	cairo_set_source_rgba(cr,rgb_to_r_g_b(hours_colour,clock_alpha))
	cairo_move_to(cr,xc,yc)
	cairo_line_to(cr,xh,yh)
	cairo_move_to(cr,xc,yc)
	cairo_line_to(cr,xxh,yyh)
	cairo_stroke(cr)

	-- Draw minute hand
	xm=xc+0.80*clock_r*math.sin(mins_arc)
	ym=yc-0.80*clock_r*math.cos(mins_arc)
	-- and minute backhand
	xxm=xc-0.20*clock_r*math.sin(mins_arc)
	yym=yc+0.20*clock_r*math.cos(mins_arc)
	cairo_set_line_width(cr,7)
	cairo_set_source_rgba(cr,rgb_to_r_g_b(mins_colour,clock_alpha))
	cairo_move_to(cr,xc,yc)
	cairo_line_to(cr,xm,ym)
	cairo_move_to(cr,xc,yc)
	cairo_line_to(cr,xxm,yym)
	cairo_stroke(cr)

	if show_seconds then
		xs=xc+0.92*clock_r*math.sin(secs_arc)
		ys=yc-0.92*clock_r*math.cos(secs_arc)
		xxs=xc-0.31*clock_r*math.sin(secs_arc)
		yys=yc+0.31*clock_r*math.cos(secs_arc)

		-- Draw seconds hand shade
		-- and seconds backhand shade
		cairo_set_line_width(cr,1)
		cairo_set_source_rgba(cr,rgb_to_r_g_b(secs_shd_colour,clock_alpha))
		cairo_move_to(cr,xc+secs_shade_off,yc+secs_shade_off)
		cairo_line_to(cr,xs+secs_shade_off,ys+secs_shade_off)
		cairo_move_to(cr,xc+secs_shade_off,yc+secs_shade_off)
		cairo_line_to(cr,xxs+secs_shade_off,yys+secs_shade_off)
		cairo_stroke(cr)

		-- Draw seconds hand
		-- and seconds backhand
		cairo_set_line_width(cr,2)
		cairo_set_source_rgba(cr,rgb_to_r_g_b(secs_colour,clock_alpha))
		cairo_move_to(cr,xc,yc)
		cairo_line_to(cr,xs,ys)
		cairo_move_to(cr,xc,yc)
		cairo_line_to(cr,xxs,yys)
		cairo_stroke(cr)
	end

	-- Draw center dot/screw
	cairo_set_source_rgba(cr,rgb_to_r_g_b(0xFFD700,0.9))
	cairo_set_line_width(cr,3)
	cairo_arc(cr,xc,yc,1,0,360)
	cairo_stroke(cr)

	-- Restore line cap
	cairo_set_line_cap (cr,saved_lc)
end

function conky_clock_rings()

	local function setup_rings(cr,pt)
		local str, value = '', 0
		local pct
		str = string.format('${%s %s}', pt['name'], pt['arg'])
		if pt['name'] == '' then
			str = 0
			value = 0
		else
			str=conky_parse(str)
			value = tonumber(str)
		end
		if (pt['arg'] == '%I' and value > 12) then value = value - 12
		elseif ((pt['arg'] == '%M' or pt['arg'] == '%S') and value == 0) then value = 60 end
		pct=value/pt['max']
		draw_ring(cr,pct,pt)
	end

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

	for i in pairs(settings_table) do
		setup_rings(cr, settings_table[i])
	end

	draw_clock_hands(cr, clock_x, clock_y)

	cairo_destroy(cr)
	cr = nil

	-- #419 memory leak when calling top objects with conky_parse in lua
	-- http://sourceforge.net/p/conky/bugs/419/
	collectgarbage()

	return
end
