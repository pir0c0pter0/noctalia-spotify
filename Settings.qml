import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

ColumnLayout {
    id: root

    property var pluginApi: null

    readonly property var settings: pluginApi?.pluginSettings ?? ({})
    readonly property var defaults: pluginApi?.manifest?.metadata?.defaultSettings ?? ({})

    property bool valueShowArtist: settings.showArtist ?? defaults.showArtist ?? true
    property int valueMaxTitleLength: settings.maxTitleLength ?? defaults.maxTitleLength ?? 25

    spacing: Style.marginM

    // Show artist toggle
    NSettingsToggle {
        Layout.fillWidth: true
        label: pluginApi?.tr("settings.show-artist") ?? "Show artist in bar"
        description: pluginApi?.tr("settings.show-artist-desc") ?? ""
        checked: root.valueShowArtist
        onToggled: {
            root.valueShowArtist = checked
        }
    }

    // Max title length
    NSettingsSlider {
        Layout.fillWidth: true
        label: pluginApi?.tr("settings.max-title-length") ?? "Max title length"
        description: pluginApi?.tr("settings.max-title-length-desc") ?? ""
        from: 10
        to: 60
        stepSize: 5
        value: root.valueMaxTitleLength
        onMoved: {
            root.valueMaxTitleLength = value
        }
    }

    function saveSettings() {
        if (!pluginApi) return
        pluginApi.pluginSettings.showArtist = root.valueShowArtist
        pluginApi.pluginSettings.maxTitleLength = root.valueMaxTitleLength
        pluginApi.saveSettings()
    }
}
