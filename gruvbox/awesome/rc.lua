pcall(require, "luarocks.loader")
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")
awful.spawn.with_shell("clipman &")
awful.spawn.with_shell("picom &")
awful.spawn.with_shell("$(killall lemonbar &) && /home/hrishabhmittal/.config/awesome/lemonbar.sh &")
awful.spawn.with_shell("$(killall batteryd &) && /home/hrishabhmittal/.config/awesome/batteryd &")
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        if in_error then return end
        in_error = true
        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
beautiful.init(gears.filesystem.get_themes_dir() .. "default/beautiful.lua")
terminal = "alacritty"
editor = os.getenv("EDITOR") or "nvim"
editor_cmd = terminal .. " -e " .. editor
modkey = "Mod4"
altkey = "Mod1"
awful.layout.layouts = {
    awful.layout.suit.spiral,
}
menubar.utils.terminal = terminal
mykeyboardlayout = awful.widget.keyboardlayout()
mytextclock = wibox.widget.textclock()
local function set_wallpaper(s)
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end
screen.connect_signal("property::geometry", set_wallpaper)
awful.screen.connect_for_each_screen(function(s)
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])
    s.mypromptbox = awful.widget.prompt()
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
end)
root.buttons(gears.table.join(
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
globalkeys = gears.table.join(
    awful.key({ modkey,           },"s", hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ }, "Print", function () awful.spawn("flameshot gui") end,
              {description = "take screenshot", group = "screen"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ altkey,           }, "Up",    function ()
        local c = client.focus
        if c and c.floating then
            c:relative_move(0, -25, 0, 0)
        end
    end, {description = "move up", group = "client"}),
    awful.key({ altkey,           }, "Down",  function ()
        local c = client.focus
        if c and c.floating then
            c:relative_move(0, 25, 0, 0)
        end
    end, {description = "move down", group = "client"}),
    awful.key({ altkey,           }, "Left",  function ()
        local c = client.focus
        if c and c.floating then
            c:relative_move(-25, 0, 0, 0)
        end
    end, {description = "move left", group = "client"}),
    awful.key({ altkey,           }, "Right", function ()
        local c = client.focus
        if c and c.floating then
            c:relative_move(25, 0, 0, 0)
        end
    end, {description = "move right", group = "client"}),
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),
    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),
    awful.key({ modkey },            "r",     function () awful.util.spawn("rofi -show drun -no-lazy-grab") end,
              {description = "runs rofi app launcher", group = "launcher"}),
    awful.key({ altkey },            "Tab",     function () awful.util.spawn("rofi -show window -no-lazy-grab") end,
              {description = "switch between windows", group = "launcher"}),
    awful.key({ modkey },            "b",     function () awful.spawn.with_shell("firefox") end,
              {description = "runs browser (firefox)", group = "Apps"}),
    awful.key({ modkey },            "f",     function () awful.spawn.with_shell("pcmanfm") end,
              {description = "runs file manager", group = "Apps"}),
    awful.key({ modkey },            "q",     function () awful.spawn.with_shell("wlogout") end,
              {description = "logout", group = "awesome"})

)
clientkeys = gears.table.join(
    awful.key({                  }, "f11",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey,           }, "a",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  function (c)
                awful.client.floating.toggle()
                if c.floating then
                    c:geometry({x = 200,y = 200})
                end
            end                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)
-- Move focused window to another tag (desktop) and switch to it with wrapping
globalkeys = gears.table.join(
    globalkeys,
    
    -- Super + Shift + Right Arrow -> Move window to next tag (desktop) and switch to it
    awful.key({ modkey, "Shift" }, "Right", function ()
        local c = client.focus
        local screen = awful.screen.focused()
        local current_index = screen.selected_tag.index
        local next_index = current_index + 1
        
        -- Wrap around to the first tag if at the last one
        if next_index > #screen.tags then
            next_index = 1
        end
        
        local tag = screen.tags[next_index]
        if tag then
            if c then
                c:move_to_tag(tag) -- Move window to the new tag
            end
            tag:view_only() -- Switch to the new tag
        end
    end),
    
    -- Super + Shift + Left Arrow -> Move window to previous tag (desktop) and switch to it
    awful.key({ modkey, "Shift" }, "Left", function ()
        local c = client.focus
        local screen = awful.screen.focused()
        local current_index = screen.selected_tag.index
        local prev_index = current_index - 1
        
        -- Wrap around to the last tag if at the first one
        if prev_index < 1 then
            prev_index = #screen.tags
        end
        
        local tag = screen.tags[prev_index]
        if tag then
            if c then
                c:move_to_tag(tag) -- Move window to the new tag
            end
            tag:view_only() -- Switch to the new tag
        end
    end)
)
clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)
root.keys(globalkeys)
awful.rules.rules = {
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },
    { rule_any = {
        instance = {
          "DTA",
          "copyq",
          "pinentry",
        },
        class = {
          "Yad",
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",
          "Sxiv",
          "Tor Browser",
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},
        name = {
          "Event Tester",
        },
        role = {
          "AlarmWindow",
          "ConfigManager",
          "pop-up",
        }
      }, properties = { floating = true }},
}
client.connect_signal("manage", function (c)
    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        awful.placement.no_offscreen(c)
    end
end)
client.connect_signal("request::titlebars", function(c)
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )
    awful.titlebar(c) : setup {
        {
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        {
            {
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        {
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)
client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
client.connect_signal("manage", function (c)
    if c.class == "Yad" then
        gears.timer.start_new(0.01, function()
            local screen_geo = c.screen.geometry
            local x = (screen_geo.width - c.width) / 2
            local y = (screen_geo.height - c.height) / 2
            c:geometry({ x = x, y = y })
        end)
    end
end)
client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
beautiful.useless_gap = 5
local math = require("math")
local function get_wallpapers(wallpaper_dir)
    local wallpapers = {}
    for file in io.popen('find "' .. wallpaper_dir .. '" -type f -iname "*.jpg" -o -iname "*.png"'):lines() do
        table.insert(wallpapers, file)
    end
    return wallpapers
end

-- gears.wallpaper.maximized("/home/hrishabhmittal/Pictures/gruvbox/anime_skull.png")
local function set_random_wallpaper()
    local wallpaper_dir = "/home/hrishabhmittal/Pictures/gruvbox"
    local wallpapers = get_wallpapers(wallpaper_dir)
    if #wallpapers > 0 then
        local random_wallpaper = wallpapers[math.random(#wallpapers)]
        gears.wallpaper.maximized(random_wallpaper, nil, true)
    end
end
gears.timer {
    timeout = 240,
    call_now = true,
    autostart = true,
    callback = set_random_wallpaper
}
