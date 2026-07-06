import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQml 2.15
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.components as PC3
import org.kde.plasma.core 2.0 as PlasmaCore

PlasmoidItem {
    id: root
    width: 360
    height: 160

    property string gpuText: "GPU: --"
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

    function updateGpu() {
        if (!ds) {
            initDataSource();
            return;
        }
        ds.connectSource("/bin/sh -c '/usr/bin/nvidia-smi --query-gpu=temperature.gpu,utilization.gpu,memory.used,memory.total,power.draw --format=csv,noheader,nounits'");
    }

    function parseOutput(stdout) {
        console.log("Raw output:", stdout);
        if (!stdout) {
            gpuText = "GPU: No data";
            return;
        }

        var line = stdout.trim().split("\n")[0];
        var parts = line.split(",");

        if (parts.length !== 5) {
            gpuText = "GPU: Parse error";
            return;
        }

        var temp = parts[0].trim();
        var util = parts[1].trim();
        var memUsed = parseFloat(parts[2].trim());
        var memTotal = parseFloat(parts[3].trim());
        var power = parts[4].trim();

        var usedGB = (memUsed / 1024).toFixed(1);
        var totalGB = (memTotal / 1024).toFixed(0);

        // --- Choose how you want Parameters to appear on the Taskbar (default: all) ---
        gpuText = "GPU: " + util + "% | " + usedGB + "/" + totalGB + "GB | " + power + "W | " + temp + "°C                                                                 ";
        // -----------------------------------

        tempLabel.text = temp + "°C";
        oldTempLabel.text = "Temp:";
        utilLabel.text = "Util: " + util + "%";
        vramLabel.text = "VRAM: " + usedGB + "/" + totalGB + "GB";
        powerLabel.text = "Power: " + power + "W";

        var t = parseInt(temp);
        if (t > 80) {
            textItem.color = "#ff4444";
            tempLabel.color = "#ff4444";
            oldTempLabel.color = "#ff4444";
            utilLabel.color = "#ff4444";
            vramLabel.color = "#ff4444";
            powerLabel.color = "#ff4444";
        } else if (t > 65) {
            textItem.color = "#ff8800";
            tempLabel.color = "#ff8800";
            oldTempLabel.color = "#ff8800";
            utilLabel.color = "#ff8800";
            vramLabel.color = "#ff8800";
            powerLabel.color = "#ff8800";
        } else {
            // System text color – white on dark, black on light
            textItem.color = PlasmaCore.Theme.textColor;
            tempLabel.color = PlasmaCore.Theme.textColor;
            oldTempLabel.color = PlasmaCore.Theme.textColor;
            utilLabel.color = PlasmaCore.Theme.textColor;
            vramLabel.color = PlasmaCore.Theme.textColor;
            powerLabel.color = PlasmaCore.Theme.textColor;
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: updateGpu()
    }

    Component.onCompleted: updateGpu()

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
                text: root.gpuText
                font.pixelSize: 14
                font.bold: false
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                Layout.bottomMargin: 20
            }

            Item { Layout.preferredHeight: 8; Layout.fillWidth: true }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true

                PC3.Label {
                    id: oldTempLabel
                    text: "Temp:"
                    font.pixelSize: 12
                    font.bold: false
                    opacity: tempLabel.text === "--°C" ? 0.3 : 1.0
                }

                PC3.Label {
                    id: tempLabel
                    text: "--°C"
                    font.pixelSize: 12
                    font.bold: false
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                }
            }

            PC3.Label {
                id: utilLabel
                text: "Util: --%"
                font.pixelSize: 12
                font.bold: false
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            PC3.Label {
                id: vramLabel
                text: "VRAM: -- / -- GB"
                font.pixelSize: 12
                font.bold: false
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            PC3.Label {
                id: powerLabel
                text: "Power: -- W"
                font.pixelSize: 12
                font.bold: false
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Item {
            Layout.preferredWidth: 80
            Layout.fillHeight: true
        }
    }
}
