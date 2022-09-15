--[[

     Based on
     Powerarrow Dark Awesome WM theme

--]]

local gears = require("gears")
local lain  = require("lain")
local awful = require("awful")
local wibox = require("wibox")
local dpi   = require("beautiful.xresources").apply_dpi
-- local jira_widget = require("jira")
-- local weather_widget = require("weather")

local os = os
local my_table = awful.util.table or gears.table -- 4.{0,1} compatibility

local theme                                     = {}
theme.dir                                       = os.getenv("HOME") .. "/.config/awesome"
theme.wallpaper                                 = os.getenv("WALLPAPER")
theme.font                                      = "Arimo Nerd Font 11"
theme.fg_normal                                 = "#d6deeb"
theme.fg_focus                                  = "#6fc3ea"
theme.fg_urgent                                 = "#CC9393"
theme.bg_normal                                 = "#24292e"
theme.bg_focus                                  = "#000000"
theme.bg_occupied                               = "#444b52"
theme.bg_urgent                                 = "#1A1A1A"
theme.bg_systray                                = theme.bg_normal
theme.border_width                              = dpi(2)
theme.border_normal                             = "#3F3F3F"
theme.border_focus                              = "#7F7F7F"
theme.border_marked                             = "#CC9393"
theme.tasklist_bg_focus                         = theme.bg_normal
theme.titlebar_bg_focus                         = theme.bg_focus
theme.titlebar_bg_normal                        = theme.bg_normal
theme.titlebar_fg_focus                         = theme.fg_focus
theme.menu_height                               = dpi(28)
theme.menu_width                                = dpi(200)
theme.layout_tile                               = theme.dir .. "/icons/tile.png"
theme.layout_tileleft                           = theme.dir .. "/icons/tileleft.png"
theme.layout_tilebottom                         = theme.dir .. "/icons/tilebottom.png"
theme.layout_tiletop                            = theme.dir .. "/icons/tiletop.png"
theme.layout_fairv                              = theme.dir .. "/icons/fairv.png"
theme.layout_fairh                              = theme.dir .. "/icons/fairh.png"
theme.layout_spiral                             = theme.dir .. "/icons/spiral.png"
theme.layout_dwindle                            = theme.dir .. "/icons/dwindle.png"
theme.layout_max                                = theme.dir .. "/icons/max.png"
theme.layout_fullscreen                         = theme.dir .. "/icons/fullscreen.png"
theme.layout_magnifier                          = theme.dir .. "/icons/magnifier.png"
theme.layout_floating                           = theme.dir .. "/icons/floating.png"
theme.layout_termfair                           = theme.dir .. "/icons/termfair.png"
theme.layout_treetile                           = theme.dir .. "/icons/treetile.png"
theme.widget_ac                                 = theme.dir .. "/icons/ac.png"
theme.widget_battery                            = theme.dir .. "/icons/battery.png"
theme.widget_battery_low                        = theme.dir .. "/icons/battery_low.png"
theme.widget_battery_empty                      = theme.dir .. "/icons/battery_empty.png"
theme.widget_brightness                         = theme.dir .. "/icons/brightness.png"
theme.widget_clock                              = theme.dir .. "/icons/clock.png"
theme.widget_music                              = theme.dir .. "/icons/note.png"
theme.widget_music_on                           = theme.dir .. "/icons/note_on.png"
theme.widget_vol                                = theme.dir .. "/icons/vol.png"
theme.widget_vol_low                            = theme.dir .. "/icons/vol_low.png"
theme.widget_vol_no                             = theme.dir .. "/icons/vol_no.png"
theme.widget_vol_mute                           = theme.dir .. "/icons/vol_mute.png"
theme.widget_mail                               = theme.dir .. "/icons/mail.png"
theme.widget_mail_on                            = theme.dir .. "/icons/mail_on.png"
theme.widget_weather                            = theme.dir .. "/icons/dish.png"
theme.tasklist_plain_task_name                  = true
theme.tasklist_disable_icon                     = true
theme.useless_gap                               = dpi(9)
theme.titlebar_close_button_focus               = theme.dir .. "/icons/titlebar/close_focus.png"
theme.titlebar_close_button_normal              = theme.dir .. "/icons/titlebar/close_normal.png"
theme.titlebar_ontop_button_focus_active        = theme.dir .. "/icons/titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active       = theme.dir .. "/icons/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive      = theme.dir .. "/icons/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive     = theme.dir .. "/icons/titlebar/ontop_normal_inactive.png"
theme.titlebar_sticky_button_focus_active       = theme.dir .. "/icons/titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active      = theme.dir .. "/icons/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive     = theme.dir .. "/icons/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive    = theme.dir .. "/icons/titlebar/sticky_normal_inactive.png"
theme.titlebar_floating_button_focus_active     = theme.dir .. "/icons/titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active    = theme.dir .. "/icons/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive   = theme.dir .. "/icons/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive  = theme.dir .. "/icons/titlebar/floating_normal_inactive.png"
theme.titlebar_maximized_button_focus_active    = theme.dir .. "/icons/titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active   = theme.dir .. "/icons/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive  = theme.dir .. "/icons/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = theme.dir .. "/icons/titlebar/maximized_normal_inactive.png"

local markup = lain.util.markup
local separators = lain.util.separators

-- Textclock
local clockicon = wibox.widget.imagebox(theme.widget_clock)
local clock = awful.widget.watch(
  "date +'%a %d %b %R' ", 60,
  function(widget, stdout)
    widget:set_markup(" " .. markup.font(theme.font, stdout))
  end
)

-- Battery
local baticon = wibox.widget.imagebox(theme.widget_battery)
local bat = lain.widget.bat({
  settings = function()
    if bat_now.status and bat_now.status ~= "N/A" then
      if bat_now.ac_status == 1 then
        baticon:set_image(theme.widget_ac)
      elseif not bat_now.perc and tonumber(bat_now.perc) <= 5 then
        baticon:set_image(theme.widget_battery_empty)
      elseif not bat_now.perc and tonumber(bat_now.perc) <= 15 then
        baticon:set_image(theme.widget_battery_low)
      else
        baticon:set_image(theme.widget_battery)
      end
      widget:set_markup(markup.font(theme.font, " " .. bat_now.perc .. "% "))
    else
      widget:set_markup(markup.font(theme.font, " AC "))
      baticon:set_image(theme.widget_ac)
    end
  end
})

-- ALSA volume
local volicon = wibox.widget.imagebox(theme.widget_vol)
theme.volume = lain.widget.alsa({
  settings = function()
    if volume_now.status == "off" then
      volicon:set_image(theme.widget_vol_mute)
    elseif tonumber(volume_now.level) == 0 then
      volicon:set_image(theme.widget_vol_no)
    elseif tonumber(volume_now.level) <= 50 then
      volicon:set_image(theme.widget_vol_low)
    else
      volicon:set_image(theme.widget_vol)
    end

    widget:set_markup(markup.font(theme.font, " " .. volume_now.level .. "% "))
  end
})

-- Brightness
local brighticon = wibox.widget.imagebox(theme.widget_brightness)
local brightwidget = awful.widget.watch('light -G', 0.1,
  function(widget, stdout, stderr, exitreason, exitcode)
    local brightness_level = tonumber(string.format("%.0f", stdout))
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
  --
  -- Create a tasklist widget
  s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, awful.util.tasklist_buttons)

  -- Create the wibox
  s.mywibox = awful.wibar({ position = "top", screen = s, height = dpi(20), bg = theme.bg_normal, fg = theme.fg_normal })

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
      theme.volume.widget,
      baticon,
      bat.widget,
      brighticon,
      brightwidget,
      clockicon,
      clock,
      spr,
      wibox.widget.systray(),
      spr,
      s.mylayoutbox,
    },
  }
end

return theme
