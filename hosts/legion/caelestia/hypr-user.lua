-- Hardware-specific dual-monitor layout for legion.
hl.monitor({
    output = "eDP-1",
    mode = "2560x1600@165",
    position = "0x0",
    scale = 1.6,
})

hl.monitor({
    output = "HDMI-A-1",
    mode = "1920x1080@180",
    position = "1600x0",
    scale = 1,
})

-- Fcitx 5 integration for GTK, Qt and XWayland applications.
hl.env("GTK_IM_MODULE", "fcitx")
hl.env("QT_IM_MODULE", "fcitx")
hl.env("XMODIFIERS", "@im=fcitx")
hl.env("SDL_IM_MODULE", "fcitx")

-- Bridge Hyprland into the systemd graphical-session lifecycle.
hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user start hyprland-session.target")
end)

hl.on("hyprland.shutdown", function()
    hl.exec_cmd("systemctl --user stop hyprland-session.target")
end)

hl.config({
    input = {
        numlock_by_default = true,
    },
})

-- Avoid accidental suspend; explicit Super+Shift+L remains available.
hl.gesture({
    fingers = 4,
    direction = "down",
    action = "unset",
})

-- logind ignores lid actions; Hyprland only controls the displays.
hl.bind(
    "switch:on:[Lid Switch]",
    hl.dsp.exec_cmd("hyprctl dispatch dpms off"),
    { locked = true }
)

hl.bind(
    "switch:off:[Lid Switch]",
    hl.dsp.exec_cmd("hyprctl dispatch dpms on"),
    { locked = true }
)
