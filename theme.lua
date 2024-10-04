local gears          = require("gears")
local lain           = require("lain")
local awful          = require("awful")
local wibox          = require("wibox")
local dpi            = require("beautiful.xresources").apply_dpi
local weather_widget = require("weather")
local helpers        = require("helpers")

local my_table = awful.util.table

local theme                    = {}
theme.dir                      = os.getenv("HOME") .. "/.config/awesome"
theme.wallpaper                = os.getenv("WALLPAPER")
theme.font                     = "Arimo Nerd Font 11"
theme.fg_normal                = "#cdd6f4"
theme.fg_focus                 = "#b4befe"
theme.fg_urgent                = "#181825"
theme.fg_occupied              = "#181825"
theme.bg_normal                = "#1e222a"
theme.bg_focus                 = "#81a1c1"
theme.bg_occupied              = "#5e81ac"
theme.bg_urgent                = "#d08770"
theme.bg_systray               = theme.bg_normal
theme.border_width             = dpi(1)
theme.border_normal            = "#1e1e2e"
theme.border_focus             = "#b4befe"
theme.border_marked            = "#1e222a"
theme.tasklist_bg_focus        = theme.bg_normal
theme.titlebar_bg_focus        = theme.bg_focus
theme.titlebar_bg_normal       = theme.bg_normal
theme.titlebar_fg_focus        = theme.bg_normal
theme.menu_height              = dpi(28)
theme.menu_width               = dpi(200)
theme.bar_height               = dpi(20)
theme.layout_tile              = theme.dir .. "/icons/tile.png"
theme.layout_tileleft          = theme.dir .. "/icons/tileleft.png"
theme.layout_tilebottom        = theme.dir .. "/icons/tilebottom.png"
theme.layout_tiletop           = theme.dir .. "/icons/tiletop.png"
theme.layout_fairv             = theme.dir .. "/icons/fairv.png"
theme.layout_fairh             = theme.dir .. "/icons/fairh.png"
theme.layout_spiral            = theme.dir .. "/icons/spiral.png"
theme.layout_dwindle           = theme.dir .. "/icons/dwindle.png"
theme.layout_max               = theme.dir .. "/icons/max.png"
theme.layout_fullscreen        = theme.dir .. "/icons/fullscreen.png"
theme.layout_magnifier         = theme.dir .. "/icons/magnifier.png"
theme.layout_floating          = theme.dir .. "/icons/floating.png"
theme.layout_termfair          = theme.dir .. "/icons/termfair.png"
theme.layout_treetile          = theme.dir .. "/icons/treetile.png"
theme.tasklist_plain_task_name = true
theme.tasklist_disable_icon    = true
theme.useless_gap              = dpi(5)

local markup = lain.util.markup
local separators = lain.util.separators

-- Get openweathermap API-key
local api_key = theme.dir .. "/openweathermap.apikey"
local current_location = theme.dir .. "/current_location"

-- Current ssid
local ssid = awful.widget.watch("ssid.sh", 3, function(widget, stdout)
	local wifi = stdout
	if wifi == "" or wifi == nil then
		widget:set_markup(markup.font(theme.font, "󰖩 Not connected "))
	else
		widget:set_markup(markup.font(theme.font, "󰖩 " .. wifi))
	end
end)

-- Current ssid
local wifi = awful.widget.watch("nmcli -t -f active,ssid dev wifi", 3, function(widget, stdout)
	local w = stdout
	if w == "" or w == nil then
		widget:set_markup(markup.font(theme.font, "󰖩 Not connected"))
	else
		widget:set_markup(markup.font(theme.font, "󰖩 " .. w))
	end
end)

-- Date and time
local clock = awful.widget.watch("date +'%a %d %b %R' ", 60, function(widget, stdout)
	widget:set_markup(" " .. markup.font(theme.font, "󰅐 " .. stdout))
end)

-- Battery
local bat = lain.widget.bat({
	settings = function()
    local icon
    local bat_now = bat_now
		if bat_now.status and bat_now.status ~= "N/A" then
			if bat_now.ac_status == 1 then
				icon = "󰚥 "
			elseif tonumber(bat_now.perc) >= 90 and tonumber(bat_now.perc) <= 99 then
				icon = "󰁹 "
			elseif tonumber(bat_now.perc) >= 80 and tonumber(bat_now.perc) <= 89 then
				icon = "󰂂 "
			elseif tonumber(bat_now.perc) >= 70 and tonumber(bat_now.perc) <= 79 then
				icon = "󰂁 "
			elseif tonumber(bat_now.perc) >= 60 and tonumber(bat_now.perc) <= 69 then
				icon = "󰂀 "
			elseif tonumber(bat_now.perc) >= 50 and tonumber(bat_now.perc) <= 59 then
				icon = "󰁿 "
			elseif tonumber(bat_now.perc) >= 40 and tonumber(bat_now.perc) <= 49 then
				icon = "󰁾 "
			elseif tonumber(bat_now.perc) >= 30 and tonumber(bat_now.perc) <= 39 then
				icon = "󰁽 "
			elseif tonumber(bat_now.perc) >= 20 and tonumber(bat_now.perc) <= 29 then
				icon = "󰁻 "
			elseif tonumber(bat_now.perc) >= 10 and tonumber(bat_now.perc) <= 19 then
				icon = "󰁻 "
			elseif tonumber(bat_now.perc) >= 5 and tonumber(bat_now.perc) <= 9 then
				icon = "󰁺 "
			else
				icon = "󰂃 "
			end
			widget:set_markup(markup.font(theme.font, icon .. bat_now.perc .. "%"))
		else
			icon = "󰚥 "
			widget:set_markup(markup.font(theme.font, icon .. "AC"))
		end
	end,
})

-- Pulseaudio
local volume = awful.widget.watch("pactl get-sink-volume @DEFAULT_SINK@", 0.1, function(widget, stdout, _, _, _)
	local vol_level = tonumber(string.match(stdout, "%d*%%"):sub(1, -2))
	if vol_level >= 76 then
		Icon = "  "
	elseif vol_level >= 21 and vol_level <= 75 then
		Icon = " "
	elseif vol_level <= 20 then
		Icon = " "
	end
	widget:set_markup(markup.font(theme.font, Icon .. vol_level .. "%"))
end)

-- Gentoo updates
local updates = awful.widget.watch("cat /home/nomad/.local/share/daniel/available-upgrades", 1, function(widget, stdout)
	local updates_available = tonumber(stdout)
	Icon = " "
	widget:set_markup(markup.font(theme.font, Icon .. updates_available))
end)

-- Brightness
local brightwidget = awful.widget.watch("light -G", 0.1, function(widget, stdout, _, _, _)
	local brightness_level = tonumber(string.format("%.0f", stdout))
	if brightness_level >= 76 and brightness_level <= 100 then
		Icon = "󰃠 "
	elseif brightness_level >= 21 and brightness_level <= 75 then
		Icon = "󰃟 "
	elseif brightness_level <= 20 then
		Icon = "󰃞 "
	end
	widget:set_markup(markup.font(theme.font, Icon .. brightness_level .. "%"))
end)

-- Separators
local spr = wibox.widget.textbox("  ")
local arrl_dl = separators.arrow_left(theme.bg_focus, "alpha")
local arrl_ld = separators.arrow_left("alpha", theme.bg_focus)

function theme.at_screen_connect(s)
	-- If wallpaper is a function, call it with the screen
	local wallpaper = theme.wallpaper
	if type(wallpaper) == "function" then
		wallpaper = wallpaper(s)
	end
	gears.wallpaper.maximized(wallpaper, s, true)

	-- Tags
	awful.tag(awful.util.tagnames, s, awful.layout.layouts)

	-- Create a promptbox for each screen
	s.mypromptbox = awful.widget.prompt()
	-- Create an imagebox widget which will contains an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s.mylayoutbox = awful.widget.layoutbox(s)
	s.mylayoutbox:buttons(my_table.join(
		awful.button({}, 1, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 2, function()
			awful.layout.set(awful.layout.layouts[1])
		end),
		awful.button({}, 3, function()
			awful.layout.inc(-1)
		end),
		awful.button({}, 4, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 5, function()
			awful.layout.inc(-1)
		end)
	))
	s.mytaglist = awful.widget.taglist({
		screen = s,
		filter = awful.widget.taglist.filter.all,
		buttons = awful.util.taglist_buttons,
		style = {
			fg_focus = theme.fg_occupied,
			bg_focus = theme.bg_focus,
			fg_urgent = theme.fg_occupied,
			bg_urgent = theme.bg_urgent,
			bg_occupied = theme.bg_occupied,
			fg_occupied = theme.fg_occupied,
			bg_empty = nil,
			fg_empty = nil,
			spacing = 3,
			shape = gears.shape.circle,
		},
		widget_template = {
			{
				{
					{
						{
							id = "icon_role",
							widget = wibox.widget.imagebox,
						},
						widget = wibox.container.margin,
					},
					{
						id = "text_role",
						widget = wibox.widget.textbox,
					},
					layout = wibox.layout.fixed.horizontal,
				},
				left = 7,
				right = 7,
				widget = wibox.container.margin,
			},
			id = "background_role",
			widget = wibox.container.background,
		},
	})

	-- Create a tasklist widget
	s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, awful.util.tasklist_buttons)

	-- Create the wibox
	s.mywibox = awful.wibar({
		position = "top",
		screen = s,
		height = theme.bar_height,
		bg = theme.bg_normal,
		fg = theme.fg_normal,
	})

	-- Add widgets to the wibox
	s.mywibox:setup({
		layout = wibox.layout.align.horizontal,
		{
			-- Left widgets
			layout = wibox.layout.fixed.horizontal,
			s.mytaglist,
			s.mypromptbox,
			spr,
		},
		s.mytasklist, -- Middle widget
		{
			-- Right widgets
			layout = wibox.layout.fixed.horizontal,
			ssid,
			spr,
			updates,
			spr,
			bat.widget,
			spr,
			volume,
			spr,
			brightwidget,
			weather_widget({
				api_key = helpers.Get_data(api_key),
				coordinates = { 62.5464, 12.5419 },
				show_daily_forecast = true,
        timeout = 240,
			}),
			-- spr,
			-- wifi_widget,
			-- spr,
			clock,
			spr,
			wibox.widget.systray(),
			-- spr,
			-- s.mylayoutbox,
		},
	})
end

return theme
