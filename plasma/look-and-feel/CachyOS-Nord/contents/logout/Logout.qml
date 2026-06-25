/***************************************************************************
 *   Copyright (C) 2014 by Aleix Pol Gonzalez <aleixpol@blue-systems.com>  *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.coreaddons as KCoreAddons

import "../components"
import "timer.js" as AutoTriggerTimer

import org.kde.plasma.private.sessions

PlasmaCore.ColorScope {
    id: root
    colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
    height: screenGeometry.height
    width: screenGeometry.width

    signal logoutRequested()
    signal haltRequested()
    signal haltUpdateRequested()
    signal suspendRequested(int spdMethod)
    signal rebootRequested()
    signal rebootRequested2(int opt)
    signal rebootUpdateRequested()
    signal cancelRequested()
    signal lockScreenRequested()
    signal cancelSoftwareUpdateRequested()

    property alias backgroundColor: backgroundRect.color

    function sleepRequested() {
        root.suspendRequested(2);
    }

    function hibernateRequested() {
        root.suspendRequested(4);
    }
 
    property real timeout: 30
    property real remainingTime: root.timeout
    property var currentAction: {
        switch (sdtype) {
            case ShutdownType.ShutdownTypeReboot:
                return () => softwareUpdatePending ? rebootUpdateRequested() : rebootRequested();
            case ShutdownType.ShutdownTypeHalt:
                return () => softwareUpdatePending ? haltUpdateRequested() : haltRequested();
            default:
                return () => logoutRequested();
        }
    }

    KCoreAddons.KUser {
        id: kuser
    }

    // For showing a "other users are logged in" hint
    SessionsModel {
        id: sessionsModel
        includeUnusedSessions: false
        includeOwnSession: false
    }

    Controls.Action {
        onTriggered: root.cancelRequested()
        shortcut: "Escape"
    }

    onRemainingTimeChanged: {
        if (remainingTime <= 0) {
            root.currentAction();
        }
    }

    Timer {
        id: countDownTimer
        running: true
        repeat: true
        interval: 1000
        onTriggered: remainingTime--
        Component.onCompleted: {
            AutoTriggerTimer.addCancelAutoTriggerCallback(function() {
                countDownTimer.running = false;
            });
        }
    }

    function isLightColor(color) {
        return Math.max(color.r, color.g, color.b) > 0.5
    }

    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        //use "black" because this is intended to look like a general darkening of the scene. a dark gray as normal background would just look too "washed out"
        color: "#0F111A"
        opacity: 0.7
    }
    MouseArea {
        anchors.fill: parent
        onClicked: root.cancelRequested()
    }
    UserDelegate {
        width: units.gridUnit * 7
        height: width
        nameFontSize: theme.defaultFont.pointSize + 2
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.verticalCenter
        }
        constrainText: false
        avatarPath: kuser.faceIconUrl
        iconSource: "user-identity"
        isCurrent: true
        name: kuser.fullName
    }
    ColumnLayout {
        anchors {
            top: parent.verticalCenter
            topMargin: units.gridUnit * 2
            horizontalCenter: parent.horizontalCenter
        }
        spacing: units.largeSpacing

        height: Math.max(implicitHeight, units.gridUnit * 10)
        width: Math.max(implicitWidth, units.gridUnit * 16)

        PlasmaComponents.Label {
            font.pointSize: theme.defaultFont.pointSize + 1
            Layout.maximumWidth: units.gridUnit * 16
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.italic: true
            text: i18ndp("plasma_lookandfeel_org.kde.lookandfeel",
                         "One other user is currently logged in. If the computer is shut down or restarted, that user may lose work.",
                         "%1 other users are currently logged in. If the computer is shut down or restarted, those users may lose work.",
                         sessionsModel.count)
            visible: sessionsModel.count > 0
        }

        PlasmaComponents.Label {
            font.pointSize: theme.defaultFont.pointSize + 1
            Layout.maximumWidth: units.gridUnit * 16
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.italic: true
            text: {
                if (isUefi) {
                    return i18nd("plasma_lookandfeel_org.kde.lookandfeel", "When restarted, the computer will enter UEFI firmware settings.");
                } else {
                    return i18nd("plasma_lookandfeel_org.kde.lookandfeel", "When restarted, the computer will enter the firmware setup screen.");
                }
            }
            visible: rebootToFirmwareSetup
        }

        PlasmaComponents.Label {
            font.pointSize: theme.defaultFont.pointSize + 1
            Layout.maximumWidth: units.gridUnit * 16
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.italic: true
            text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "When restarted, the computer will enter the boot loader menu.")
            visible: rebootToBootLoaderMenu
        }

        PlasmaComponents.Label {
            font.pointSize: theme.defaultFont.pointSize + 1
            Layout.maximumWidth: units.gridUnit * 16
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.italic: true
            text: i18ndc("plasma_lookandfeel_org.kde.lookandfeel", "%1 is a boot loader entry", "When restarted, the computer will switch to %1.", rebootToBootLoaderEntry)
            visible: rebootToBootLoaderEntry != ""
        }

        RowLayout {
            spacing: units.largeSpacing * 2
            Layout.alignment: Qt.AlignHCenter
            LogoutButton {
                id: suspendButton
                iconSource: "system-suspend"
                text: i18ndc("plasma_lookandfeel_org.kde.lookandfeel", "Suspend to RAM", "Sleep")
                action: root.sleepRequested
                KeyNavigation.left: logoutButton
                KeyNavigation.right: hibernateButton
                visible: spdMethods.SuspendState
            }
            LogoutButton {
                id: hibernateButton
                iconSource: "system-suspend-hibernate"
                text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Hibernate")
                action: root.hibernateRequested
                KeyNavigation.left: suspendButton
                KeyNavigation.right: rebootButton
                visible: spdMethods.HibernateState
            }
            LogoutButton {
                id: rebootButton
                iconSource: softwareUpdatePending ? "system-reboot-update" : "system-reboot"
                text: softwareUpdatePending ? i18ndc("plasma_lookandfeel_org.kde.lookandfeel", "@action:button Keep short", "Install Updates and Restart")
                                            : i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Restart")
                action: softwareUpdatePending ? root.rebootUpdateRequested : root.rebootRequested
                KeyNavigation.left: hibernateButton
                KeyNavigation.right: rebootWithoutUpdatesButton.visible ? rebootWithoutUpdatesButton : shutdownButton
                focus: sdtype === ShutdownType.ShutdownTypeReboot
                visible: maysd
            }
            LogoutButton {
                id: rebootWithoutUpdatesButton
                iconSource: "system-reboot"
                text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Restart")
                action: root.rebootRequested
                KeyNavigation.left: rebootButton
                KeyNavigation.right: shutdownButton
                visible: maysd && softwareUpdatePending
            }
            LogoutButton {
                id: shutdownButton
                iconSource: softwareUpdatePending ? "system-shutdown-update" : "system-shutdown"
                text: softwareUpdatePending ? i18ndc("plasma_lookandfeel_org.kde.lookandfeel", "@action:button Keep short", "Install Updates and Shut Down")
                                            : i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Shut Down")
                action: softwareUpdatePending ? root.haltUpdateRequested : root.haltRequested
                KeyNavigation.left: rebootWithoutUpdatesButton.visible ? rebootWithoutUpdatesButton : rebootButton
                KeyNavigation.right: shutdownWithoutUpdatesButton.visible ? shutdownWithoutUpdatesButton : logoutButton
                focus: sdtype === ShutdownType.ShutdownTypeHalt
                visible: maysd
            }
            LogoutButton {
                id: shutdownWithoutUpdatesButton
                iconSource: "system-shutdown"
                text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Shut Down")
                action: root.haltRequested
                KeyNavigation.left: shutdownButton
                KeyNavigation.right: logoutButton
                visible: maysd && softwareUpdatePending
            }
            LogoutButton {
                id: logoutButton
                iconSource: "system-log-out"
                text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Log Out")
                action: root.logoutRequested
                KeyNavigation.left: shutdownWithoutUpdatesButton.visible ? shutdownWithoutUpdatesButton : shutdownButton
                KeyNavigation.right: suspendButton
                focus: sdtype === ShutdownType.ShutdownTypeNone
                visible: canLogout
            }
        }

        PlasmaComponents.Label {
            font.pointSize: theme.defaultFont.pointSize + 1
            Layout.alignment: Qt.AlignHCenter
            //opacity, as visible would re-layout
            opacity: countDownTimer.running ? 1 : 0
            Behavior on opacity {
                OpacityAnimator {
                    duration: units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
            text: {
                switch (sdtype) {
                    case ShutdownType.ShutdownTypeReboot:
                        return softwareUpdatePending ? i18ndp("plasma_lookandfeel_org.kde.lookandfeel", "Installing software updates and restarting in 1 second", "Installing software updates and restarting in %1 seconds", root.remainingTime)
                                                     : i18ndp("plasma_lookandfeel_org.kde.lookandfeel", "Restarting in 1 second", "Restarting in %1 seconds", root.remainingTime);
                    case ShutdownType.ShutdownTypeHalt:
                        return softwareUpdatePending ? i18ndp("plasma_lookandfeel_org.kde.lookandfeel", "Installing software updates and shutting down in 1 second", "Installing software updates and shutting down in %1 seconds", root.remainingTime)
                                                     : i18ndp("plasma_lookandfeel_org.kde.lookandfeel", "Shutting down in 1 second", "Shutting down in %1 seconds", root.remainingTime);
                    default:
                        return i18ndp("plasma_lookandfeel_org.kde.lookandfeel", "Logging out in 1 second", "Logging out in %1 seconds", root.remainingTime);
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            PlasmaComponents.Button {
                font.pointSize: theme.defaultFont.pointSize + 1
                enabled: root.currentAction !== null
                text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "OK")
                onClicked: root.currentAction()
            }
            PlasmaComponents.Button {
                font.pointSize: theme.defaultFont.pointSize + 1
                text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Cancel")
                onClicked: root.cancelRequested()
            }
        }
    }
}
