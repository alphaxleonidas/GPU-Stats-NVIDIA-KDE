import QtQuick 2
import org.kde.plasma.core 2.0 as PlasmaCore

PlasmaCore.Dialog {
  id: root
  width: 150
  height: 50
  
  PlasmaCore.DataSource {
    id: turbostat
    sourceType: "process"
    interval: 1000
    
    function refresh() {
      execute("turbostat --interval 1 --count 1");
    }
  }
  
  Text {
    text: "AMD Wattage: " + turbostat.data["stdout"]
    anchors.centerIn: parent
  }
}
