import QtQuick 2.15
import QtQuick.Controls 2.15

PluginsBackground {
    enum Filter {
        None            = 0b0,
        Effect          = 0b1,
        Analyzer        = 0b10,
        Delay           = 0b100,
        Distortion      = 0b1000,
        Dynamics        = 0b10000,
        EQ              = 0b100000,
        Filter          = 0b1000000,
        Spatial         = 0b10000000,
        Generator       = 0b100000000,
        Mastering       = 0b1000000000,
        Modulation      = 0b10000000000,
        PitchShift      = 0b100000000000,
        Restoration     = 0b1000000000000,
        Reverb          = 0b10000000000000,
        Surround        = 0b100000000000000,
        Tools           = 0b1000000000000000,
        Network         = 0b10000000000000000,
        Drum            = 0b100000000000000000,
        Instrument      = 0b1000000000000000000,
        Piano           = 0b10000000000000000000,
        Sampler         = 0b100000000000000000000,
        Synth           = 0b1000000000000000000000,
        External        = 0b10000000000000000000000
    }

    property int currentFilter: PluginsView.None

    id: pluginsView

    onCurrentFilterChanged: {
        console.log("Filter changed to: ", currentFilter);
    }

    PluginsViewTitle {
        id: pluginsViewTitle
        x: (pluginsForeground.width + (parent.width - pluginsForeground.width) / 2) - width / 2
        y: height
    }

    PluginsForeground {
        id: pluginsForeground
        x: parent.parent.x
        y: parent.parent.y
        width: Math.max(parent.width * 0.2, 350)
        height: parent.height
    }

    PluginsContentArea {
        id: pluginsContentArea
        anchors.top: pluginsViewTitle.bottom
        anchors.left: pluginsForeground.right
        anchors.right: pluginsView.right
        anchors.bottom: pluginsView.bottom
        anchors.margins: parent.width * 0.05
    }
}
