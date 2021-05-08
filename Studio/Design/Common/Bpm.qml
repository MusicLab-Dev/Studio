import QtQuick 2.15
import QtQuick.Controls 2.15

import "../Default"

DefaultSectionWrapper {
    label: "bpm"

   DefaultTextInput {
       id: name
       anchors.centerIn: parent
       text: app.scheduler.bpm
       font.pixelSize: parent.height * 0.75
       color: acceptableInput ? "white" : "red"
       validator: IntValidator {
           bottom: 1
           top: 999
       }

       onTextChanged: {
            if (acceptableInput)
                app.scheduler.bpm = text
       }
   }
}
