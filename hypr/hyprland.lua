-- ~/.config/hypr/hyprland.lua
-- Docs: https://wiki.hypr.land/Configuring/Start/

-- Old: monitor = eDP-1,disable
-- Old: monitor = HDMI-A-1,preferred,auto,1

hl.monitor({ output = "DP-1", mode = "1920x1080@240", position = "1920x0", scale = 1 })
hl.monitor({ output = "HDMI-A-2", mode = "1920x1080@180", position = "0x0", scale = 1 })

---- MY PROGRAMS ----

mainMod    = "SUPER"
terminal   = "kitty"
menu       = "rofi -show drun"
fileManager = "thunar"
browser    = "vivaldi"


---- AUTOSTART ----

-- Old exec-once lines. hl.exec_cmd() fires immediately (not a dispatcher),
-- so these are wrapped in the hyprland.start event, same timing as exec-once.

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("dunst")
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")

    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("sleep 1 && awww img /home/zix/Pictures/Wallpapers/w3.jpg")
end)

---- ENVIRONMENT VARIABLES ----

hl.env("XCURSOR_SIZE", "18")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("MOZ_ENABLE_WAYLAND", "1")

---- INPUT ----

hl.config({
    input = {
        kb_layout = "fr",
        follow_mouse = 1,
        sensitivity = 0.5,
        touchpad = {
            natural_scroll = false,
            tap_to_click = true,
        },
    },
})

---- LOOK AND FEEL ----

hl.config({
    general = {
        gaps_in = 3,
        gaps_out = 5,
        border_size = 0,
        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
    },
    decoration = {
        rounding = 8,
        blur = {
            enabled = true,
            size = 5,
            passes = 1,
            vibrancy = 0.2,
        },
        shadow = {
            enabled = true,
            range = 12,
            render_power = 3,
        },
    },
    animations = {
        enabled = true,
    },
})

-- Old: bezier = easeOut,0.05,0.9,0.1,1.0
hl.curve("easeOut", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.0} } })

-- Old: animation = windows,1,5,easeOut  (enabled, speed, style)
hl.animation({ leaf = "windows",    enabled = true, speed = 5, bezier = "easeOut" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 5, bezier = "easeOut" })
hl.animation({ leaf = "border",     enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "fade",       enabled = true, speed = 4, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "default" })

-- LAYOUT
hl.config({
    dwindle = { preserve_split = true },
})
hl.config({
    master = { new_status = "master" },
})

-- MISC
hl.config({
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
    },
})

---- SPLIT-OUT FILES ----

require("keybinds")
require("rules")
