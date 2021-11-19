/*
 * Copyright (C) 2021 Darrel Griët <dgriet@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.9
import org.asteroid.controls 1.0
import org.asteroid.utils 1.0
import Qt.labs.folderlistmodel 2.1
import Nemo.KeepAlive 1.1
import Nemo.Time 1.0
import Nemo.Configuration 1.0

Application {
    id: root
    anchors.fill: parent
    centerColor: "#b04d1c"
    outerColor: "#421c0a"

    ConfigurationValue {
        id: previousPath
        key: "/org/asteroidos/qmltester/previous-path"
        defaultValue: "file://"
    }

    ConfigurationValue {
        id: previousSelected
        key: "/org/asteroidos/qmltester/previous-selected"
        defaultValue: ""
    }

    property bool displayAmbient: false
    WallClock {
        id: wallClock
        enabled: true
        updateFrequency: WallClock.Second
    }

    LayerStack {
        id: layerStack
        firstPage: browser
    }

    Component {
        id: loader
        Item {
            property var path: "file://"
            Loader {
                anchors.fill: parent
                // Use a random see to ensure that it can't be cached
                source: path + "?" + Math.random()
            }
        }
    }

    Component {
        id: browser
        Item {
            property var parentPath: ""
            property var path: previousPath.value
            property var pop

            Component.onCompleted: previousPath.value = path

            Timer {
                id: initalItem
                running: true
                repeat: false
                interval: 100
                onTriggered: {

                    var i = 0
                    while (i < folderModel.count){
                        var fileName = folderModel.get(i, "fileName")
                        var fileBaseName = folderModel.get(i, "fileBaseName")
                        if(previousSelected.value == folderModel.folder + "/" + fileName) {
                            view.currentIndex = i
                            return
                        }
                        i = i+1
                    }
                    view.currentIndex = 2
                }
            }

            ListView {
                id: view
                anchors.fill: parent
                preferredHighlightBegin: view.height/2 - root.height/12
                preferredHighlightEnd: view.height/2 + root.height/12
                highlightRangeMode: ListView.StrictlyEnforceRange

                model: FolderListModel {
                    id: folderModel
                    showDotAndDotDot: true
                    showDirsFirst: true
                    folder: path
                    nameFilters: ["*.qml"]
                }
                delegate: Component {
                    Item {
                        height: root.height/6
                        width: root.width
                        Label {
                            anchors.left: parent.left
                            // We want items to move to the left when an item is near the middle of the screen:
                            //  / 1
                            // | 2
                            //  \ 3
                            // To achieve this we need to know the current y location of the element. This is provided by the FileModel.
                            // Using the index of the item and the current location of the top of the listview(contentY) we can find the location of a specific item.
                            // Next we use the Pythagoras rule (x^2+y^2=r^) to align the item around the left edge.
                            // Rewriting Pythagoras rule: sqrt(r^2 - y^2) => sqrt(listview_height/2^2 - location_item_y^2)
                            // Finally we add a small padding (Dims.w(5)) so that the item is not touching the left 'bezel'.
                            anchors.leftMargin: {
                                if (DeviceInfo.hasRoundScreen) {
                                    var itemLocationY = (parent.height * (view.contentY/parent.height - index) - parent.height/2);
                                    var screenRadius = view.height/2;
                                    screenRadius - Math.sqrt(Math.pow(screenRadius, 2) - Math.pow((screenRadius + itemLocationY),2)) + Dims.w(5);
                                } else {
                                    0;
                                }
                            }
                            anchors.verticalCenter: parent.verticalCenter
                            text: fileName
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                var file = "" + folderModel.folder
                                // String manipulation to extract a proper path.
                                // With correct placement of '/'.
                                if (file.slice(-1) === '/')
                                    file = file + fileName
                                else
                                    file = file + "/" + fileName

                                // Path changed, no need to reselect the previously selected.
                                previousSelected.value = ""

                                if (file.slice(-2) == "..") {
                                    file = file.slice(0, -3)
                                    var n = file.lastIndexOf('/')
                                    var prevPath = file.slice(0, n)
                                    if (prevPath === parentPath) {
                                        pop()
                                    } else if (prevPath === "file://") {
                                        // Wants to traverse to root.
                                        // Due to string manipulation it results in the above case
                                        layerStack.push(browser, {"parentPath": " ", "path": "file:///"})
                                    } else if (prevPath === "file:/") {
                                        // Currently at root, ignore events.
                                    } else {
                                        layerStack.push(browser, {"parentPath": " ", "path": prevPath})
                                    }
                                } else if (file.slice(-1) == ".") {
                                    // Ignore
                                } else if (folderModel.isFolder(index)) {
                                        layerStack.push(browser, {"parentPath": path, "path": file})
                                } else {
                                    previousSelected.value = file
                                    layerStack.push(loader, {"path": file})
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    Component.onCompleted: DisplayBlanking.preventBlanking = true
}
