-- Стандартные библиотеки
local gears = require("gears")
local awful = require("awful")
--require("awful.autofocus")
-- Виджеты и слои
local wibox = require("wibox")
-- Темы
local beautiful = require("beautiful")
-- Оповещение
local naughty = require("naughty")
local hotkeys_popup = require("awful.hotkeys_popup").widget
-- Дополнительные возможности
local lain = require("lain")
-- мои либы
require("lib.function")
-------------------------------------------------------------------------------
--Константы
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--	Устанавливаем системную локаль (русскую)
-------------------------------------------------------------------------------
os.setlocale(os.getenv("LANG"))
-------------------------------------------------------------------------------
--	Устанавливаем тему
-------------------------------------------------------------------------------
-- beautiful.init("/home/andrew/.config/awesome/themes/dark32/theme.lua")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
  naughty.notify({ preset = naughty.config.presets.critical,
      title = "Упс! Эти ошибки появились во время зпуска!",
      text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
  local in_error = false
  awesome.connect_signal("debug::error", function (err)
      -- Make sure we don't go into an endless error loop
      if in_error then return end
      in_error = true

      naughty.notify({ preset = naughty.config.presets.critical,
          title = "Упс! Случилась ошибка",
          text = tostring(err) })
      in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(awful.util.get_themes_dir() .. "default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "x-terminal-emulator"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor


-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
altKey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
  --awful.layout.suit.floating,
  awful.layout.suit.tile,
  --awful.layout.suit.tile.left,
  --awful.layout.suit.tile.bottom,
  --awful.layout.suit.tile.top,
   awful.layout.suit.fair,
  -- awful.layout.suit.fair.horizontal,
  -- awful.layout.suit.spiral,
  -- awful.layout.suit.spiral.dwindle,
  awful.layout.suit.max,
  --awful.layout.suit.max.fullscreen,
  -- awful.layout.suit.magnifier,
  awful.layout.suit.corner.nw,
  --awful.layout.suit.corner.ne,
  --awful.layout.suit.corner.sw,
  --awful.layout.suit.corner.se,
  --lain.layout.termfair,
  --lain.layout.termfair.center,
  --lain.layout.cascade,
  --lain.layout.cascade.tile,
  lain.layout.centerwork,
  --lain.layout.centerwork.horizontal,
}
-- }}}

-- {{{ Helper functions
local function client_menu_toggle_fn()
  local instance = nil

  return function ()
    if instance and instance.wibox.visible then
      instance:hide()
      instance = nil
    else
      instance = awful.menu.clients({ theme = { width = 250 } })
    end
  end
end
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
  { "hotkeys", function() return false, hotkeys_popup.show_help end},
  { "manual", terminal .. " -e man awesome" },
  { "edit config", editor_cmd .. " " .. awesome.conffile },
  { "restart", awesome.restart },
  { "quit", function() awesome.quit() end}
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
      --{ "Debian", debian.menu.Debian_menu.Debian },
      { "open terminal", terminal }
    }
  })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,   menu = mymainmenu })

appmenu = require("lib.appmenu")
applauncher = awful.menu({ items =  appmenu })



-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

local tasklist_buttons = awful.util.table.join(
  awful.button({ }, 1, function (c)
      if c == client.focus then
        c.minimized = true
      else
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
  awful.button({ }, 3, client_menu_toggle_fn()),
  awful.button({ }, 4, function ()
      awful.client.focus.byidx(1)
    end),
  awful.button({ }, 5, function ()
      awful.client.focus.byidx(-1)
    end))

local function set_wallpaper(s)
  -- Wallpaper
  if beautiful.wallpaper then
    local wallpaper = beautiful.wallpaper
    -- If wallpaper is a function, call it with the screen
    if type(wallpaper) == "function" then
      wallpaper = wallpaper(s)
    end
    gears.wallpaper.maximized(wallpaper, s, true)
  end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)
s.quake = lain.util.quake({
    width=1,
    height = 0.5,
    app = terminal,
    border = 0,
    })
    -- Each screen has its own tag table.
    awful.tag({ "1: ", "2: ", "3: ", "4: ", "5: ", "6: ", "7: ", "8: ", "9: " ,"10: "}, s, awful.layout.layouts[1])

    
    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)
    -- Create the wibox
     s.wibox_bottom =  require("lib.wibox_bottom")(s)
  
    s.wibox_tasklist= awful.wibar({ position = "top", screen = s })
    s.wibox_tasklist:setup {
      layout = wibox.layout.flex.horizontal,
      s.mytasklist, -- Middle widget
    }
  end)
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end)
  ))
-- }}}

-- {{{ Key bindings
require("lib.globalkey")

clientkeys = require("lib.clientkeys")



clientbuttons = awful.util.table.join(
  awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
  awful.button({ modkey }, 1, function (c)
      if (c.floating) then
           awful.mouse.client.move(c)
      end
    end),
   awful.button({ modkey }, 3, function (c)
     if (c.floating) then
           awful.mouse.client.resize(c)
      end
    end)
  )


-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = require("lib.rule")
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
    not c.size_hints.user_position
    and not c.size_hints.program_position then
      -- Prevent clients from being unreachable after screen count changes.
      awful.placement.no_offscreen(c)
    end
  end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.

client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = awful.util.table.join(
      awful.button({ }, 1, function()
          client.focus = c
          c:raise()
          awful.mouse.client.move(c)
        end),

      awful.button({ }, 3, function()
          client.focus = c
          c:raise()
          --awful.mouse.client.resize(c)
        end)
      
    )
    
    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            --awful.titlebar.widget.maximizedbutton(c),
            --awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
    
  end)

-- Enable sloppy focus, so that focus follows mouse.
--client.connect_signal("mouse::enter", function(c)
--   if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
--       and awful.client.focus.filter(c) then
--       client.focus = c
--   end
--end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}