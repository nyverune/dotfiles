pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: theme

    // Canonical Nyverune Brand Design Tokens
    readonly property color defaultBackground: "#100D16"
    readonly property color defaultForeground: "#F6F0FC"
    readonly property color defaultSurface: "#181224"
    readonly property color defaultSurfaceMuted: "#21182B"
    readonly property color defaultPrimary: "#A855F7"
    readonly property color defaultSecondary: "#FF5CB8"
    readonly property color defaultAccent: "#C084FC"
    readonly property color defaultMuted: "#8B8297"
    readonly property color defaultSelection: "#4C3268"
    readonly property color defaultBorder: "#2E2242"
    readonly property color defaultError: "#FF5C72"
    readonly property color defaultWarning: "#FFC36B"
    readonly property color defaultSuccess: "#75D6A3"
    readonly property color defaultInfo: "#72B7FF"

    // Typography
    readonly property string fontFamily: "JetBrainsMono Nerd Font, Symbols Nerd Font, Noto Sans, sans-serif"

    property color background: defaultBackground
    property color foreground: defaultForeground
    property color surface: defaultSurface
    property color surfaceMuted: defaultSurfaceMuted
    property color primary: defaultPrimary
    property color secondary: defaultSecondary
    property color accent: defaultAccent
    property color muted: defaultMuted
    property color selection: defaultSelection
    property color border: defaultBorder
    property color error: defaultError
    property color warning: defaultWarning
    property color success: defaultSuccess
    property color info: defaultInfo

    property var colorProc: Process {
        id: colorReader
        command: ["cat", Quickshell.env("HOME") + "/.cache/wal/colors.json"]
        stdout: StdioCollector {
            onTextChanged: theme.parseColors(text)
        }
    }

    property var reloadTimer: Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: theme.reloadColors()
    }

    Component.onCompleted: theme.reloadColors()

    function reloadColors() {
        if (colorProc) {
            colorProc.running = true
        }
    }

    function parseColors(raw) {
        if (!raw || raw.trim().length === 0) return

        try {
            let data = JSON.parse(raw)
            if (data.special) {
                if (data.special.background) background = data.special.background
                if (data.special.foreground) foreground = data.special.foreground
            }
            if (data.colors) {
                if (data.colors.color0) surface = data.colors.color0
                if (data.colors.color1) error = data.colors.color1
                if (data.colors.color2) success = data.colors.color2
                if (data.colors.color3) warning = data.colors.color3
                if (data.colors.color4) info = data.colors.color4
                if (data.colors.color5) primary = data.colors.color5
                if (data.colors.color6) accent = data.colors.color6
                if (data.colors.color7) foreground = data.colors.color7
                if (data.colors.color8) border = data.colors.color8
                if (data.colors.color13) secondary = data.colors.color13
                if (data.colors.color14) accent = data.colors.color14
            }
        } catch (e) {
            // Keep default tokens on parse error
        }
    }
}
