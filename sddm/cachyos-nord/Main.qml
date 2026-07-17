import QtQuick 2.0
import SddmComponents 2.0
import QtGraphicalEffects 1.0

Rectangle {
    id: root
    width: 640
    height: 480
    color: "#34495e"

    TextConstants { id: textConstants }


    Connections {
        target: sddm

        onLoginSucceeded: {
            errorMessage.color = "steelgreen"
            errorMessage.text = textConstants.loginSucceeded
        }

        onLoginFailed: {
            errorMessage.color = "red"
            errorMessage.text = textConstants.loginFailed
        }
    }

    Row {
        anchors.fill: parent

        // Left column with the logo
        Item {
            width: root.width / 2
            height: root.height

            Image {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                source: "cachyos.png"
                fillMode: Image.PreserveAspectFit
                width: root.width / 4
            }
        }

        // Right column with the login box
        Item {
            width: root.width / 2
            height: root.height

        Rectangle {
            id: cachyos
            anchors.centerIn: parent
            width: parent.width * 0.5
            height: parent.height * 0.3
            color: "#2c3e50"
            radius: 20
            border.color: "#ecf0f1"
            border.width: 1

            // Blur effect applied to the whole Item, affecting content behind 'cachyos'
            layer.enabled: true
            layer.effect: GaussianBlur {
                radius: 0 // Adjust the blur radius as needed
            }

            Column {
                id: mainColumn
                anchors.centerIn: parent
                width: parent.width * 0.9
                spacing: cachyos.height / 22.5

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    verticalAlignment: Text.AlignVCenter
                    width: parent.width
                    height: text.implicitHeight
                    color: "white"
                    text: textConstants.welcomeText.arg(sddm.hostName)
                    wrapMode: Text.WordWrap
                    font.pixelSize: cachyos.height / 11.75
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }

                Row {
                    width: parent.width
                    spacing: Math.round(cachyos.height / 70)
                    Text {
                        id: lblName
                        width: parent.width * 0.20; height: cachyos.height / 9
                        color: "white"
                        text: textConstants.userName
                        verticalAlignment: Text.AlignVCenter
                        font.bold: true
                        font.pixelSize: cachyos.height / 22.5
                    }

                    TextBox {
                        id: name
                        width: parent.width * 0.8; height: cachyos.height / 9
                        text: userModel.lastUser
                        font.pixelSize: cachyos.height / 20

                        KeyNavigation.backtab: rebootButton; KeyNavigation.tab: password

                        Keys.onPressed: {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                sddm.login(name.text, password.text, session.index)
                                event.accepted = true
                            }
                        }
                    }
                }

                Row {
                    width: parent.width
                    spacing : Math.round(cachyos.height / 70)
                    Text {
                        id: lblPassword
                        width: parent.width * 0.2; height: cachyos.height / 9
                        color: "white"
                        text: textConstants.password
                        verticalAlignment: Text.AlignVCenter
                        font.bold: true
                        font.pixelSize: cachyos.height / 22.5
                    }

                    PasswordBox {
                        id: password
                        width: parent.width * 0.8; height: cachyos.height / 9
                        font.pixelSize: cachyos.height / 20
                        tooltipBG: "lightgrey"

                        KeyNavigation.backtab: name; KeyNavigation.tab: session

                        Keys.onPressed: {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                sddm.login(name.text, password.text, session.index)
                                event.accepted = true
                            }
                        }
                    }
                }

                Row {
                    spacing: Math.round(cachyos.height / 70)
                    width: parent.width / 2
                    z: 102

                    Row {
                        z: 100
                        width: parent.width * 1.2
                        spacing : Math.round(cachyos.height / 70)
                        anchors.bottom: parent.bottom

                        Text {
                            id: lblSession
                            width: parent.width / 3; height: cachyos.height / 9
                            text: textConstants.session
                            verticalAlignment: Text.AlignVCenter
                            color: "white"
                            wrapMode: TextEdit.WordWrap
                            font.bold: true
                            font.pixelSize: cachyos.height / 22.5
                        }

                        ComboBox {
                            id: session
                            width: parent.width * 2 / 3; height: cachyos.height / 9
                            font.pixelSize: cachyos.height / 20

                            arrowIcon: "angle-down.png"

                            model: sessionModel
                            index: sessionModel.lastIndex

                            KeyNavigation.backtab: password; KeyNavigation.tab: layoutBox
                        }
                    }
                    Row {
                        z: 101
                        width: parent.width * 0.8
                        spacing : cachyos.height / 27
                        anchors.bottom: parent.bottom

                        Text {
                            id: lblLayout
                            width: parent.width / 3; height: cachyos.height / 9
                            text: textConstants.layout
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            color: "white"
                            wrapMode: TextEdit.WordWrap
                            font.bold: true
                            font.pixelSize: cachyos.height / 22.5
                        }

                        LayoutBox {
                            id: layoutBox
                            width: (parent.width * 2 / 3) -10; height: cachyos.height / 9
                            font.pixelSize: cachyos.height / 20

                            arrowIcon: "angle-down.png"

                            KeyNavigation.backtab: session; KeyNavigation.tab: loginButton
                        }
                    }
                }

                Column {
                    width: parent.width
                    Text {
                        id: errorMessage
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: textConstants.prompt
                        color: "white"
                        font.pixelSize: cachyos.height / 22.5
                    }
                }

                Row {
                    spacing: Math.round(cachyos.height / 50)
                    anchors.horizontalCenter: parent.horizontalCenter
                    property int btnWidth: Math.max(loginButton.implicitWidth,
                                                    shutdownButton.implicitWidth,
                                                    rebootButton.implicitWidth, cachyos.height / 3) + 8
                    Button {
                        id: loginButton
                        text: textConstants.login
                        width: parent.btnWidth
                        height: cachyos.height / 9
                        font.pixelSize: cachyos.height / 20
                        radius: 8
                        color: "#47adda"

                        onClicked: sddm.login(name.text, password.text, session.index)

                        KeyNavigation.backtab: layoutBox; KeyNavigation.tab: shutdownButton
                    }

                    Button {
                        id: shutdownButton
                        text: textConstants.shutdown
                        width: parent.btnWidth
                        height: cachyos.height / 9
                        font.pixelSize: cachyos.height / 20
                        radius: 8
                        color: "#47adda"

                        onClicked: sddm.powerOff()

                        KeyNavigation.backtab: loginButton; KeyNavigation.tab: rebootButton
                    }

                    Button {
                        id: rebootButton
                        text: textConstants.reboot
                        width: parent.btnWidth
                        height: cachyos.height / 9
                        font.pixelSize: cachyos.height / 20
                        radius: 8
                        color: "#47adda"

                        onClicked: sddm.reboot()

                        KeyNavigation.backtab: shutdownButton; KeyNavigation.tab: name
                    }
                }
            }
        }
        }
    }

    Component.onCompleted: {
        if (name.text == "")
            name.focus = true
        else
            password.focus = true
    }
}
