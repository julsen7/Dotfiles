hl.monitor({
    output   = "HDMI-A-1",
    mode     = "2560x1440@144",
    position = "0x0",
    scale    = 1,
})

hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@60",
    position = "2560x500",
    scale    = 1,
})

hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1,
    mirror = "eDP-1"
})

hl.on("hyprland.start", function()
    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice'")
    
    hl.exec_cmd("uwsm app -- wl-paste --type text --watch cliphist store")
    hl.exec_cmd("uwsm app -- wl-paste --type image --watch cliphist store")
    hl.exec_cmd("uwsm app -- udiskie")
    hl.exec_cmd("uwsm app -- snappy-switcher --daemon")
    hl.exec_cmd("uwsm app -- awww-daemon")
    
    hl.exec_cmd("uwsm app -- discord --start-minimized" )
    hl.exec_cmd("uwsm app -- spotify", { workspace = "6 silent" })
end)

for i = 1, 3 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "HDMI-A-1", default = true, persistent = true })
end

for i = 4, 6 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "eDP-1", default = true, persistent = true })
end

hl.config({
    general = {
        border_size      = 0,
        gaps_in          = 5,
        gaps_out         = 10,
        resize_on_border = true,
    },
    decoration = {
        rounding              = 20,
        shadow                = {
            enabled = true,
            range = 50
        }
    },
    input = {
        kb_layout = "de"
    },
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

local terminal    = "uwsm app -- kitty"
local filemanager = "uwsm app -- yazi"
local browser     = "uwsm app -- zen-browser"
local music       = "uwsm app -- spotify"
local code        = "uwsm app -- code"
local menu        = "uwsm app -- rofi -show drun -show-icons -disable-history"
local colorpicker = "uwsm app -- hyprpicker -a"
local screenshot  = "uwsm app -- hyprshot -m region --clipboard-only"
local clipboard   = "uwsm app -- cliphist list | rofi -dmenu -display-columns 2 | cliphist decode | wl-copy"
local lockout     = "uwsm app -- hyprlock"

hl.bind("SUPER + Q", hl.dsp.exec_cmd(terminal))
hl.bind("SUPER + E", hl.dsp.exec_cmd(terminal .. " -e " .. filemanager))
hl.bind("SUPER + B", hl.dsp.exec_cmd(browser))
hl.bind("SUPER + M", hl.dsp.exec_cmd(music))
hl.bind("SUPER + C", hl.dsp.exec_cmd(code))
hl.bind("ALT + Space", hl.dsp.exec_cmd(menu))
hl.bind("SUPER + P", hl.dsp.exec_cmd(colorpicker))
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd(screenshot))
hl.bind("SUPER + V", hl.dsp.exec_cmd(clipboard))
hl.bind("SUPER + L", hl.dsp.exec_cmd(lockout))

hl.bind("CTRL + ALT + Delete", hl.dsp.exit())
hl.bind("SUPER + left", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + up", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + down", hl.dsp.focus({ direction = "down" }))
hl.bind("F11", hl.dsp.window.fullscreen())
hl.bind("ALT + F4", hl.dsp.window.close())
hl.bind("SUPER + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + S", hl.dsp.layout("togglesplit"))
hl.bind("ALT + Tab", hl.dsp.exec_cmd("snappy-switcher next --mod alt"))
hl.bind("SUPER + TAB", hl.dsp.exec_cmd("snappy-switcher next --workspace --mod super"))

for i = 1, 6 do
    hl.bind("SUPER + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind("SUPER + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

hl.bind("ALT + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("ALT + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0 }, { 0.35, 1 } } } )

hl.curve( "rubber", { type = "spring", mass = 1, stiffness = 40, dampening = 10 } )

hl.animation({ leaf = "windows", enabled = true, speed = 2, bezier = "easeInOutCubic", style = "slide" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2, spring = "rubber", style = "slide" })
