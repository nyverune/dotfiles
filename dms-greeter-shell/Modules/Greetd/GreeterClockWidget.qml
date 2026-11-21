import QtQuick
import Quickshell
import qs.Common
import qs.DCommon.Widgets as DCommon

DCommon.DClockWidget {
    id: root

    property real widgetWidth: 280
    property real widgetHeight: 200
    property string instanceId: ""
    property var instanceData: null
    property var lockHost: null

    lockScreen: true
    cfg: instanceData?.config ?? ({})
    enabled: instanceData?.enabled ?? true
    now: systemClock.date
    locale: I18n.locale()
    use24HourClock: SettingsData.use24HourClock
    padHours12Hour: SettingsData.padHours12Hour
    dateFormat: SettingsData.lockDateFormat
    fallbackFontFamily: SettingsData.lockScreenFontFamily
    accentColor: lockHost ? lockHost.contentColor(colorMode, customColor) : themeAccent

    SystemClock {
        id: systemClock
        precision: root.needsSeconds ? SystemClock.Seconds : SystemClock.Minutes
    }

    Text {
        id: utcClockLabel
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 4
        text: {
            const d = root.now;
            if (!d) return "";
            const h = String(d.getUTCHours()).padStart(2, "0");
            const m = String(d.getUTCMinutes()).padStart(2, "0");
            return h + ":" + m + " UTC";
        }
        font.pixelSize: 13
        font.family: root.fallbackFontFamily !== "" ? root.fallbackFontFamily : "JetBrainsMono Nerd Font"
        font.weight: Font.DemiBold
        color: root.accentColor
        opacity: 0.85
    }
}
