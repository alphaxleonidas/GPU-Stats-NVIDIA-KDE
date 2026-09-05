import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQml 2.15
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.components as PC3

PlasmoidItem {
    id: root
    width: 360
    height: 120

    property string cpuText: "CPU: --"
    property var ds

    function initDataSource() {
        ds = Qt.createQmlObject('
        import QtQuick 2.0;
        import org.kde.plasma.plasma5support as Plasma5Support;
        Plasma5Support.DataSource {
            id: ds;
            engine: "executable";
            connectedSources: [];
            onNewData: {
                var stdout = data["stdout"] || "";
                disconnectSource(sourceName);
                root.parseOutput(stdout);
            }
        }', root);
    }

    function updateCpu() {
        if (!ds) {
            initDataSource();
            return;
        }
        ds.connectSource("/bin/sh -c 'sudo turbostat --Summary --show PkgWatt --interval 1'");
    }

    function parseOutput(stdout) {
        console.log("Raw output:", stdout);
        if (!stdout) {
            cpuText = "CPU: No data";
            return;
        }

        var lines = stdout.trim().split("\n");
        var power = 0;
        
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim();
            var match = line.match(/PkgWatt\s+([\d\.]+)\s*W/);
            if (match && match[1]) {
                power = parseFloat(match[1]);
                break;
            }
        }

        if (power === 0) {
            cpuText = "CPU: -- W";
            powerLabel.text = "Power: -- W";
            return;
        }

        cpuText = "CPU: " + power.toFixed(1) + "W";
        powerLabel.text = "Power: " + power.toFixed(1) + "W";

        var p = power;
        if (p > 150) {
            textItem.color = "#ff4444";
            powerLabel.color = "#ff4444";
        } else if (p > 100) {
            textItem.color = "#ff8800";
            powerLabel.color = "#ff8800";
        } else {
            textItem.color = "#000000";
            powerLabel.color = "#000000";
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: updateCpu()
    }

    Component.onCompleted: updateCpu()

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 6

            PC3.Label {
                id: textItem
                text: root.cpuText
                font.pixelSize: 14
                font.bold: false
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                Layout.bottomMargin: 10
            }

            PC3.Label {
                id: powerLabel
                text: "Power: -- W"
                font.pixelSize: 13
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            PC3.Label {
                text: "sudo turbostat required"
                font.pixelSize: 9
                opacity: 0.5
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
