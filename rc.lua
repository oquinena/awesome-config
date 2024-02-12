pcall(require, "luarocks.loader")

-- {{{ Required libraries
local awesome, client, mouse, screen, tag = awesome, client, mouse, screen, tag
local ipairs, string, os, table, tostring, tonumber, type = ipairs, string, os, table, tostring, tonumber, type

local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local lain = require("lain")
local xrandr = require("xrandr")
local freedesktop = require("freedesktop")
local hotkeys_popup = require("awful.hotkeys_popup").widget
require("awful.hotkeys_popup.keys")
local my_table = awful.util.table or gears.table -- 4.{0,1} compatibility
local dpi = require("beautiful.xresources").apply_dpi
local revelation = require("revelation")
local bling = require("bling")
local mouse_focus = require("mouse_follow_focus")
-- }}}

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Errors during startup!",
		text = awesome.startup_errors,
	})
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        if in_error then
            return
        end
        in_error = true

        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Configuration error!",
            text = tostring(err),
        })
        in_error = false
    end)
end
-- }}}

-- {{{ Notifications
naughty.config.defaults.ontop = true
-- }}}

local modkey = "Mod4"
local altkey = "Mod1"
local terminal = "alacritty"
local editor = os.getenv("EDITOR") or "vim"
local browser = "MOZ_DBUS_REMOTE=1 firefox"
local guieditor = "code"
local scrlocker = "betterlockscreen -l dim"
local password_generator = "/home/nomad/go/bin/go-pass"

awful.util.terminal = terminal
awful.util.tagnames = { "1", "2", "3", "4", "5", "6", "7", "8", "9" }
awful.layout.layouts = {
	--treetile,
	awful.layout.suit.tile,
	-- awful.layout.suit.tile.left,
	-- awful.layout.suit.tile.bottom,
	-- awful.layout.suit.floating,
	-- awful.layout.suit.tile.top,
	-- awful.layout.suit.fair,
	-- awful.layout.suit.fair.horizontal,
	-- awful.layout.suit.spiral,
	-- awful.layout.suit.spiral.dwindle,
	-- awful.layout.suit.max,
	-- awful.layout.suit.max.fullscreen,
	-- awful.layout.suit.magnifier,
	-- awful.layout.suit.corner.nw,
	-- awful.layout.suit.corner.ne,
	-- awful.layout.suit.corner.sw,
	-- awful.layout.suit.corner.se,
	-- lain.layout.cascade,
	-- lain.layout.cascade.tile,
	-- lain.layout.centerwork,
	-- lain.layout.centerwork.horizontal,
	-- lain.layout.termfair,
	-- lain.layout.termfair.center,
}

awful.util.taglist_buttons = my_table.join(
	awful.button({}, 1, function(t)
		t:view_only()
	end),
	awful.button({ modkey }, 1, function(t)
		if client.focus then
			client.focus:move_to_tag(t)
		end
	end),
	awful.button({}, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, function(t)
		if client.focus then
			client.focus:toggle_tag(t)
		end
	end),
	awful.button({}, 4, function(t)
		awful.tag.viewnext(t.screen)
	end),
	awful.button({}, 5, function(t)
		awful.tag.viewprev(t.screen)
	end)
)

awful.util.tasklist_buttons = my_table.join(
	awful.button({}, 1, function(c)
		if c == client.focus then
			c.minimized = true
		else
			--c:emit_signal("request::activate", "tasklist", {raise = true})<Paste>

			-- Without this, the following
			-- :isvisible() makes no sense
			c.minimized = false
			if not c:isvisible() and c.first_tag then
				c.first_tag:view_only()
			end
			-- This will also un-minimize
			-- the client, if needed
			client.focus = c
			c:raise()
		end
	end),
	awful.button({}, 2, function(c)
		c:kill()
	end),
	awful.button({}, 3, function()
		local instance = nil

		return function()
			if instance and instance.wibox.visible then
				instance:hide()
				instance = nil
			else
				instance = awful.menu.clients({ theme = { width = dpi(150) } })
			end
		end
	end),
	awful.button({}, 4, function()
		awful.client.focus.byidx(1)
	end),
	awful.button({}, 5, function()
		awful.client.focus.byidx(-1)
	end)
)

lain.layout.termfair.nmaster = 3
lain.layout.termfair.ncol = 1
lain.layout.termfair.center.nmaster = 3
lain.layout.termfair.center.ncol = 1
lain.layout.cascade.tile.offset_x = dpi(2)
lain.layout.cascade.tile.offset_y = dpi(32)
lain.layout.cascade.tile.extra_padding = dpi(5)
lain.layout.cascade.tile.nmaster = 5
lain.layout.cascade.tile.ncol = 2

beautiful.init(string.format("%s/.config/awesome/theme.lua", os.getenv("HOME")))
revelation.init()
-- }}}

-- {{{ Menu
local menu = {
	{
		"hotkeys",
		function()
			return false, hotkeys_popup.show_help
		end,
	},
	{ "manual", terminal .. " -e man awesome" },
	{ "edit config", string.format("%s -e %s %s", terminal, editor, awesome.conffile) },
	{ "restart", awesome.restart },
	{
		"quit",
		function()
			awesome.quit()
		end,
	},
}
awful.util.mymainmenu = freedesktop.menu.build({
	icon_size = beautiful.menu_height or dpi(12),
	before = {
		{ "Awesome", menu, beautiful.awesome_icon },
		-- other triads can be put here
	},
	after = {
		{ "Open terminal", terminal },
		-- other triads can be put here
	},
})
-- }}}

-- {{{ Scratchpad
local term_scratch = bling.module.scratchpad({
	command = "alacritty --class spad", -- How to spawn the scratchpad
	rule = { instance = "spad" }, -- The rule that the scratchpad will be searched by
	sticky = true, -- Whether the scratchpad should be sticky
	autoclose = false, -- Whether it should hide itself when losing focus
	floating = true, -- Whether it should be floating (MUST BE TRUE FOR ANIMATIONS)
	ontop = true,
	geometry = { x = 360, y = 90, height = 900, width = 1200 }, -- The geometry in a floating state
	reapply = true, -- Whether all those properties should be reapplied on every new opening of the scratchpad (MUST BE TRUE FOR ANIMATIONS)
	dont_focus_before_close = false, -- When set to true, the scratchpad will be closed by the toggle function regardless of whether its focused or not. When set to false, the toggle function will first bring the scratchpad into focus and only close it on a second call
})
-- local slack_scratch = bling.module.scratchpad {
--   command                 = "slack", -- How to spawn the scratchpad
--   rule                    = { instance = "slack" }, -- The rule that the scratchpad will be searched by
--   sticky                  = true, -- Whether the scratchpad should be sticky
--   autoclose               = false, -- Whether it should hide itself when losing focus
--   floating                = true, -- Whether it should be floating (MUST BE TRUE FOR ANIMATIONS)
--   ontop                   = true,
--   geometry                = { x = 180, y = 90, height = 900, width = 1500 }, -- The geometry in a floating state
--   reapply                 = true, -- Whether all those properties should be reapplied on every new opening of the scratchpad (MUST BE TRUE FOR ANIMATIONS)
--   dont_focus_before_close = false, -- When set to true, the scratchpad will be closed by the toggle function regardless of whether its focused or not. When set to false, the toggle function will first bring the scratchpad into focus and only close it on a second call
-- }
-- }}}

-- {{{ Screen
-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", function(s)
	-- Wallpaper
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		-- If wallpaper is a function, call it with the screen
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.maximized(wallpaper, s, true)
	end
end)

-- No borders when rearranging only 1 non-floating or maximized client
screen.connect_signal("arrange", function(s)
	local only_one = #s.tiled_clients == 1
	for _, c in pairs(s.clients) do
		if only_one and not c.floating or c.maximized then
			c.border_width = 0
		else
			c.border_width = beautiful.border_width
		end
	end
end)
-- Create a wibox for each screen and add it
awful.screen.connect_for_each_screen(function(s)
	beautiful.at_screen_connect(s)
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(my_table.join(
	awful.button({}, 3, function()
		awful.util.mymainmenu:toggle()
	end)
	--awful.button({ }, 4, awful.tag.viewnext),
	--awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = my_table.join(
	-- Take a screenshot
	awful.key({}, "Print", function()
		os.execute("scrot '/home/nomad/Pictures/Screenshots/%Y-%m-%d-%H-%M-%S_$wx$h.jpg'")
	end, { description = "take a screenshot", group = "hotkeys" }),

	-- X screen locker
	awful.key({ altkey, "Control" }, "l", function()
		os.execute(scrlocker)
	end, { description = "lock screen", group = "hotkeys" }),

	-- xrandr extension
	awful.key({ modkey, "Control" }, "m", function()
		xrandr.xrandr()
	end, { description = "Toggle xrandr", group = "hotkeys" }),

	-- scratchpads
	awful.key({ modkey }, "l", function()
		term_scratch:toggle()
	end, { description = "Scratchpad terminal", group = "hotkeys" }),
	-- awful.key({ modkey, }, "i", function() slack_scratch:toggle() end,
	--   { description = "Slack", group = "hotkeys" }),

	-- Hotkeys
	awful.key({ modkey }, "s", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),
	-- Tag browsing
	awful.key({ modkey }, "Left", awful.tag.viewprev, { description = "view previous", group = "tag" }),
	awful.key({ modkey }, "Right", awful.tag.viewnext, { description = "view next", group = "tag" }),
	awful.key({ modkey }, "Escape", awful.tag.history.restore, { description = "go back", group = "tag" }),

	-- Non-empty tag browsing
	-- awful.key({ altkey }, "Left", function() lain.util.tag_view_nonempty(-1) end,
	--   { description = "view  previous nonempty", group = "tag" }),
	-- awful.key({ altkey }, "Right", function() lain.util.tag_view_nonempty(1) end,
	--   { description = "view  previous nonempty", group = "tag" }),

	-- By direction client focus
	awful.key({ modkey }, "n", function()
		awful.client.focus.global_bydirection("down")
		if client.focus then
			client.focus:raise()
		end
	end, { description = "focus down", group = "client" }),
	awful.key({ modkey }, "e", function()
		awful.client.focus.global_bydirection("up")
		if client.focus then
			client.focus:raise()
		end
	end, { description = "focus up", group = "client" }),
	awful.key({ modkey }, "m", function()
		awful.client.focus.global_bydirection("left")
		if client.focus then
			client.focus:raise()
		end
	end, { description = "focus left", group = "client" }),
	awful.key({ modkey }, "i", function()
		awful.client.focus.global_bydirection("right")
		if client.focus then
			client.focus:raise()
		end
	end, { description = "focus right", group = "client" }),
	awful.key({ modkey }, "w", function()
		awful.util.mymainmenu:show()
	end, { description = "show main menu", group = "awesome" }),

	-- Layout manipulation
	awful.key({ modkey, "Shift" }, "n", function()
		awful.client.swap.byidx(1)
	end, { description = "swap with next client by index", group = "client" }),
	awful.key({ modkey, "Shift" }, "e", function()
		awful.client.swap.byidx(-1)
	end, { description = "swap with previous client by index", group = "client" }),
	awful.key({ modkey, "Control" }, "n", function()
		awful.screen.focus_relative(1)
	end, { description = "focus the next screen", group = "screen" }),
	awful.key({ modkey, "Control" }, "e", function()
		awful.screen.focus_relative(-1)
	end, { description = "focus the previous screen", group = "screen" }),
	-- awful.key({ modkey, }, "u", awful.client.urgent.jumpto,
	--   { description = "jump to urgent client", group = "client" }),
	awful.key({ modkey }, "Tab", function()
		awful.client.focus.history.previous()
		if client.focus then
			client.focus:raise()
		end
	end, { description = "go back", group = "client" }),

	-- On the fly useless gaps change
	awful.key({ altkey, "Control" }, "+", function()
		lain.util.useless_gaps_resize(1)
	end, { description = "increment useless gaps", group = "tag" }),
	awful.key({ altkey, "Control" }, "-", function()
		lain.util.useless_gaps_resize(-1)
	end, { description = "decrement useless gaps", group = "tag" }),

	-- Dynamic tagging
	-- awful.key({ modkey, "Shift" }, "y", function()
	--     lain.util.add_tag()
	-- end, { description = "add new tag", group = "tag" }),
	-- awful.key({ modkey, "Shift" }, "r", function()
	--     lain.util.rename_tag()
	-- end, { description = "rename tag", group = "tag" }),
	awful.key({ modkey, "Shift" }, "Left", function()
		lain.util.move_tag(-1)
	end, { description = "move tag to the left", group = "tag" }),
	awful.key({ modkey, "Shift" }, "Right", function()
		lain.util.move_tag(1)
	end, { description = "move tag to the right", group = "tag" }),
	awful.key({ modkey, "Shift" }, "d", function()
		lain.util.delete_tag()
	end, { description = "delete tag", group = "tag" }),

	-- Standard program
	awful.key({ modkey }, "Return", function()
		awful.spawn(terminal)
	end, { description = "open a terminal", group = "launcher" }),
	awful.key({ modkey, "Control" }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),
	awful.key({ modkey, "Shift" }, "x", awesome.quit, { description = "quit awesome", group = "awesome" }),
	awful.key({ altkey, "Shift" }, "l", function()
		awful.tag.incmwfact(0.05)
	end, { description = "increase master width factor", group = "layout" }),
	awful.key({ altkey, "Shift" }, "h", function()
		awful.tag.incmwfact(-0.05)
	end, { description = "decrease master width factor", group = "layout" }),
	awful.key({ modkey, "Shift" }, "h", function()
		awful.tag.incnmaster(1, nil, true)
	end, { description = "increase the number of master clients", group = "layout" }),
	awful.key({ modkey, "Shift" }, "l", function()
		awful.tag.incnmaster(-1, nil, true)
	end, { description = "decrease the number of master clients", group = "layout" }),
	awful.key({ modkey, "Control" }, "h", function()
		awful.tag.incncol(1, nil, true)
	end, { description = "increase the number of columns", group = "layout" }),
	awful.key({ modkey, "Control" }, "l", function()
		awful.tag.incncol(-1, nil, true)
	end, { description = "decrease the number of columns", group = "layout" }),
	awful.key({ modkey }, "space", function()
		awful.layout.inc(1)
	end, { description = "select next", group = "layout" }),
	awful.key({ modkey, "Shift" }, "space", function()
		awful.layout.inc(-1)
	end, { description = "select previous", group = "layout" }),

	awful.key({ modkey, "Control" }, "n", function()
		local c = awful.client.restore()
		-- Focus restored client
		if c then
			client.focus = c
			c:raise()
		end
	end, { description = "restore minimized", group = "client" }),

	-- Brightness
	awful.key({}, "XF86MonBrightnessUp", function()
		os.execute("sudo light -A 10")
	end, { description = "+10%", group = "hotkeys" }),
	awful.key({}, "XF86MonBrightnessDown", function()
		os.execute("sudo light -U 10")
	end, { description = "-10%", group = "hotkeys" }),

	-- PulseAudio volume control
	awful.key({}, "XF86AudioRaiseVolume", function()
		os.execute(string.format("pactl set-sink-volume @DEFAULT_SINK@ +10%%"))
	end, { description = "volume up", group = "hotkeys" }),
	awful.key({}, "XF86AudioLowerVolume", function()
		os.execute(string.format("pactl set-sink-volume @DEFAULT_SINK@ -10%%"))
	end, { description = "volume down", group = "hotkeys" }),
	awful.key({}, "XF86AudioMute", function()
		os.execute(string.format("pactl set-sink-mute @DEFAULT_SINK@ toggle"))
	end, { description = "volume mute", group = "hotkeys" }),
	awful.key({}, "XF86AudioMicMute", function()
		os.execute(string.format("pactl set-source-mute 1 toggle"))
	end, { description = "microphone mute", group = "hotkeys" }),

	-- User programs
	-- awful.key({ modkey }, "q", function()
	--     awful.spawn(browser)
	-- end, { description = "run browser", group = "launcher" }),
	-- awful.key({ modkey }, "y", function()
	--     awful.spawn(guieditor)
	-- end, { description = "run gui editor", group = "launcher" }),
	awful.key({}, "XF86Calculator", function()
		awful.spawn("galculator")
	end, { description = "run calculator", group = "launcher" }),
	awful.key({ modkey, "Shift" }, "m", function()
		awful.spawn("toggle_touchpad.sh")
	end, { description = "Toggle touchpad active/inactive", group = "hotkeys" }),
	awful.key({ modkey }, "v", function()
		awful.spawn(password_generator)
	end, { description = "Generate password and place in clipboard buffer", group = "launcher" }),

	-- Prompt
	-- awful.key({ modkey }, "r", function() awful.screen.focused().mypromptbox:run() end,
	--   { description = "run prompt", group = "launcher" }),
	-- Rofi promt
	awful.key({ modkey }, "p", function()
		awful.spawn("rofi -show run")
	end, { description = "run prompt", group = "launcher" }),

	-- Rofi greenclip
	awful.key({ altkey, "Control" }, "h", function()
		awful.spawn("rofi -modi 'clipboard:greenclip print' -show clipboard -run-command '{cmd}'")
	end, { description = "run prompt", group = "launcher" }),

	awful.key({ modkey }, "x", function()
		awful.prompt.run({
			prompt = "Run Lua code: ",
			textbox = awful.screen.focused().mypromptbox.widget,
			exe_callback = awful.util.eval,
			history_path = awful.util.get_cache_dir() .. "/history_eval",
		})
	end, { description = "lua execute prompt", group = "awesome" })
	--]]
)

clientkeys = my_table.join(
	awful.key({ altkey, "Shift" }, "m", lain.util.magnify_client, { description = "magnify client", group = "client" }),
	awful.key({ modkey }, "f", function(c)
		c.fullscreen = not c.fullscreen
		c:raise()
	end, { description = "toggle fullscreen", group = "client" }),
	awful.key({ modkey, "Shift" }, "q", function(c)
		c:kill()
	end, { description = "close", group = "client" }),
	awful.key(
		{ modkey, "Control" },
		"space",
		awful.client.floating.toggle,
		{ description = "toggle floating", group = "client" }
	),
	awful.key({ modkey, "Control" }, "Return", function(c)
		c:swap(awful.client.getmaster())
	end, { description = "move to master", group = "client" }),
	awful.key({ modkey }, "o", function(c)
		c:move_to_screen()
	end, { description = "move to screen", group = "client" })
	-- awful.key({ modkey }, "t", function(c)
	-- 	c.ontop = not c.ontop
	-- end, { description = "toggle keep on top", group = "client" }),
	-- awful.key({ modkey }, "n", function(c)
	-- 	-- The client currently has the input focus, so it cannot be
	-- 	-- minimized, since minimized clients can't have the focus.
	-- 	c.minimized = true
	-- end, { description = "minimize", group = "client" }),
	-- awful.key({ modkey }, "m", function(c)
	-- 	c.maximized = not c.maximized
	-- 	c:raise()
	-- end, { description = "maximize", group = "client" }),
	-- awful.key({ modkey }, "e", revelation)
)

-- Bind all key numbers to tags.
for i = 1, 9 do
	-- Hack to only show tags 1 and 9 in the shortcut window (mod+s)
	local descr_view, descr_toggle, descr_move, descr_toggle_focus
	if i == 1 or i == 9 then
		descr_view = { description = "view tag #", group = "tag" }
		descr_toggle = { description = "toggle tag #", group = "tag" }
		descr_move = { description = "move focused client to tag #", group = "tag" }
		descr_toggle_focus = { description = "toggle focused client on tag #", group = "tag" }
	end
	globalkeys = my_table.join(
		globalkeys,
		-- View tag only.
		awful.key({ modkey }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				tag:view_only()
			end
		end, descr_view),
		-- Toggle tag display.
		awful.key({ modkey, "Control" }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				awful.tag.viewtoggle(tag)
			end
		end, descr_toggle),
		-- Move client to tag.
		awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:move_to_tag(tag)
				end
			end
		end, descr_move),
		-- Toggle tag on focused client.
		awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:toggle_tag(tag)
				end
			end
		end, descr_toggle_focus)
	)
end

clientbuttons = gears.table.join(
	awful.button({}, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
	end),
	awful.button({ modkey }, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.move(c)
	end),
	awful.button({ modkey }, 3, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.resize(c)
	end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules =
	{
		{
			rule = { instance = "galculator" },
			properties = { floating = true, ontop = true, placement = awful.placement.centered },
		},

		-- All clients will match this rule.
		{
			rule = {},
			properties = {
				border_width = beautiful.border_width,
				border_color = beautiful.border_normal,
				focus = awful.client.focus.filter,
				raise = true,
				keys = clientkeys,
				buttons = clientbuttons,
				screen = awful.screen.preferred,
				placement = awful.placement.no_overlap + awful.placement.no_offscreen,
				size_hints_honor = false,
			},
		},
		-- Titlebars
		{ rule_any = { type = { "dialog", "normal" } }, properties = { titlebars_enabled = false } },
		{ rule = { class = "Gimp", role = "gimp-image-window" }, properties = { maximized = true } },

		-- Zoom
		{
			rule = { name = "zoom" },
			properties = { floating = true, titlebars_enabled = false },
		},
		{
			rule = { name = "Zoom Meeting" },
			properties = { floating = true, titlebars_enabled = false },
		},
	},
	-- }}}
	-- Enable sloppy focus, so that focus follows mouse.
	client.connect_signal("mouse::enter", function(c)
		c:emit_signal("request::activate", "mouse_enter", { raise = true })
	end)

client.connect_signal("focus", function(c)
	c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c)
	c.border_color = beautiful.border_normal
end)
client.connect_signal("manage", function(c)
	c.shape = function(cr, w, h)
		gears.shape.rounded_rect(cr, w, h, 2)
	end
end)

-- Signals
-- ===================================================================
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- For debugging awful.rules
    -- print('c.class = '..c.class)
    -- print('c.instance = '..c.instance)
    -- print('c.name = '..c.name)

    -- Set every new window as a slave,
    -- i.e. put it at the end of others instead of setting it master.
    if not awesome.startup then awful.client.setslave(c) end

    -- if awesome.startup
    -- and not c.size_hints.user_position
    -- and not c.size_hints.program_position then
    --     -- Prevent clients from being unreachable after screen count changes.
    --     awful.placement.no_offscreen(c)
    --     awful.placement.no_overlap(c)
    -- end

end)


-- Rounded cornered windows
client.connect_signal("manage", function(c)
	c.shape = function(cr, w, h)
		gears.shape.rounded_rect(cr, w, h, 6)
	end
end)

-- spawn command to given tag
function spawn_on_tag(command, class, tag, test)
	local test = test or "class"
	local callback
	callback = function(c)
		if test == "class" then
			if c.class == class then
				c:move_to_tag(tag)
				client.disconnect_signal("manage", callback)
			end
		elseif test == "instance" then
			if c.instance == class then
				c:move_to_tag(tag)
				client.disconnect_signal("manage", callback)
			end
		elseif test == "name" then
			if string.match(c.name, class) then
				c:move_to_tag(tag)
				client.disconnect_signal("manage", callback)
			end
		end
	end
	client.connect_signal("manage", callback)
	awful.spawn.with_shell(command)
end

spawn_on_tag("MOZ_DBUS_REMOTE=1 firefox -P Private", "firefox", screen[1].tags[1], "class")
spawn_on_tag("MOZ_DBUS_REMOTE=1 firefox -P Work", "firefox", screen[1].tags[1], "class")
spawn_on_tag("slack", "Slack", screen[1].tags[2], "class")
spawn_on_tag(terminal, "Alacritty", screen[1].tags[3], "class")
