local gears          = require("gears")
local lain           = require("lain")
local awful          = require("awful")
local wibox          = require("wibox")
local dpi            = require("beautiful.xresources").apply_dpi
local weather_widget = require("weather")
-- require("wifi")

local os = os
local my_table = awful.util.table or gears.table -- 4.{0,1} compatibility

local theme                    = {}
theme.dir                      = os.getenv("HOME") .. "/.config/awesome"
theme.wallpaper                = os.getenv("WALLPAPER")
theme.font                     = "Arimo Nerd Font 11"
theme.fg_normal                = "#d6deeb"
theme.fg_focus                 = "#6fc3ea"
theme.fg_urgent                = "#CC9393"
theme.bg_normal                = "#24292e"
theme.bg_focus                 = "#000000"
theme.bg_occupied              = "#444b52"
theme.bg_urgent                = "#1A1A1A"
theme.bg_systray               = theme.bg_normal
theme.border_width             = dpi(2)
theme.border_normal            = "#3F3F3F"
theme.border_focus             = "#7F7F7F"
theme.border_marked            = "#CC9393"
theme.tasklist_bg_focus        = theme.bg_normal
theme.titlebar_bg_focus        = theme.bg_focus
theme.titlebar_bg_normal       = theme.bg_normal
theme.titlebar_fg_focus        = theme.fg_focus
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
theme.useless_gap              = dpi(9)

local markup = lain.util.markup
local separators = lain.util.separators

-- Get openweathermap API-key
local api_key = theme.dir .. "/openweathermap.apikey"
local current_location = theme.dir .. "/current_location"
local function get_data(file)
  local f = io.open(file, "rb")
  if not f then
    return nil
  end
  local content = f:read "*a"
  content = string.gsub(content, "^%s*(.-)%s*$", "%1") -- strip off any space or newline
  f:close()
  return content
end

-- Textclock
-- local clockicon = wibox.widget.imagebox(theme.widget_clock)
local clockicon = wibox.widget.textbox("󰅐 ")
local clock = awful.widget.watch(
  "date +'%a %d %b %R' ", 60,
  function(widget, stdout)
    widget:set_markup(" " .. markup.font(theme.font, stdout))
  end
)

-- Battery
local baticon = wibox.widget.textbox("󰁹 ")
local bat = lain.widget.bat({
  settings = function()
    if bat_now.status and bat_now.status ~= "N/A" then
      if bat_now.ac_status == 1 then
        baticon.text = "󰚥 "
      elseif tonumber(bat_now.perc) >= 90  and tonumber(bat_now.perc) <= 99 then
        baticon.text = "󰁹 "
      elseif tonumber(bat_now.perc) >= 80  and tonumber(bat_now.perc) <= 89 then
        baticon.text = "󰂂 "
      elseif tonumber(bat_now.perc) >= 70  and tonumber(bat_now.perc) <= 79 then
        baticon.text = "󰂁 "
      elseif tonumber(bat_now.perc) >= 60  and tonumber(bat_now.perc) <= 69 then
        baticon.text = "󰂀 "
      elseif tonumber(bat_now.perc) >= 50  and tonumber(bat_now.perc) <= 59 then
        baticon.text = "󰁿 "
      elseif tonumber(bat_now.perc) >= 40  and tonumber(bat_now.perc) <= 49 then
        baticon.text = "󰁾 "
      elseif tonumber(bat_now.perc) >= 30  and tonumber(bat_now.perc) <= 39 then
        baticon.text = "󰁽 "
      elseif tonumber(bat_now.perc) >= 20  and tonumber(bat_now.perc) <= 29 then
        baticon.text = "󰁻 "
      elseif tonumber(bat_now.perc) >= 10  and tonumber(bat_now.perc) <= 19 then
        baticon.text = "󰁻 "
      elseif tonumber(bat_now.perc) >= 5 and tonumber(bat_now.perc) <= 9 then
        baticon.text = "󰁺 "
      else
        baticon.text = "󰂃 "
      end
      widget:set_markup(markup.font(theme.font, " " .. bat_now.perc .. "% "))
    else
      widget:set_markup(markup.font(theme.font, " AC "))
      baticon.text = "󰚥 "
    end
  end
})

-- PulseAudio volume
local volicon = wibox.widget.textbox("󰕿 ")
local volume = lain.widget.pulse({
  settings = function()
    if volume_now.muted == "yes" then
      volicon.text = "󰖁 "
    elseif tonumber(volume_now.left) == 0 then
      volicon.text = "󰕿 "
    elseif tonumber(volume_now.left) <= 50 then
      volicon.text = "󰖀 "
    else
      volicon.text = "󰕾 "
    end

    widget:set_markup(markup.font(theme.font, " " .. volume_now.left .. "% "))
  end
})

-- Brightness
local brighticon = wibox.widget.textbox(theme.widget_brightness)
local brightwidget = awful.widget.watch('light -G', 0.1,
  function(widget, stdout, stderr, exitreason, exitcode)
    local brightness_level = tonumber(string.format("%.0f", stdout))
    if brightness_level >= 76 and brightness_level <= 100 then
      brighticon.text = "󰃠 "
    elseif brightness_level>= 21 and brightness_level <= 75 then
      brighticon.text = "󰃟 "
    elseif brightness_level <= 20 then
      brighticon.text = "󰃞 "
    end
    widget:set_markup(markup.font(theme.font, " " .. brightness_level .. "% "))
  end)

-- Separators
local spr     = wibox.widget.textbox(' ')
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
    awful.button({}, 1, function() awful.layout.inc(1) end),
    awful.button({}, 2, function() awful.layout.set(awful.layout.layouts[1]) end),
    awful.button({}, 3, function() awful.layout.inc(-1) end),
    awful.button({}, 4, function() awful.layout.inc(1) end),
    awful.button({}, 5, function() awful.layout.inc(-1) end)))
  s.mytaglist = awful.widget.taglist({
    screen = s,
    filter = awful.widget.taglist.filter.all,
    buttons = awful.util.taglist_buttons,
    style = {
      fg_focus = theme.fg_normal,
      bg_focus = theme.bg_focus,
      fg_urgent = theme.fg_urgent,
      bg_urgent = theme.bg_urgent,
      bg_occupied = theme.bg_occupied,
      fg_occupied = theme.fg_normal,
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
  s.mywibox = awful.wibar({ position = "top", screen = s, height = theme.bar_height, bg = theme.bg_normal, fg = theme.fg_normal })

  -- Add widgets to the wibox
  s.mywibox:setup {
    layout = wibox.layout.align.horizontal,
    { -- Left widgets
      layout = wibox.layout.fixed.horizontal,
      s.mytaglist,
      s.mypromptbox,
      spr,
    },
    s.mytasklist, -- Middle widget
    { -- Right widgets
      layout = wibox.layout.fixed.horizontal,
      volicon,
      volume,
      baticon,
      bat.widget,
      brighticon,
      brightwidget,
      clockicon,
      clock,
      weather_widget({
        api_key=get_data(api_key),
        coordinates={59.3293, 18.0686},
        show_daily_forecast=true,
      }),
      spr,
      wibox.widget.systray(),
      spr,
      s.mylayoutbox,
    },
  }
end

return theme
