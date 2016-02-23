import QtQuick 2.3
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtMultimedia 5.5
import Exporter 1.0
import QtQuick.Window 2.0
ApplicationWindow {
    function dp2px(dp){
        return  dp * (0.15875 *Screen.pixelDensity)
    }
    visible: true
    width: 640
    height: 480
    title: qsTr("Realto-Material-Designer")
    property url currentImage;

    Exporter{
        id:exporter
        onError:{
            messageBox.message(err);
        }
    }
    Rectangle{
        id: root
        radius: 5
        border.color: "#F0F0F0"
        border.width: 10
        color: "transparent"
        anchors.fill:parent

        Rectangle{
            anchors.fill: parent
            color: "#2f3439"
            Image {
                anchors.fill: parent
                source: "qrc:/assets/assets/backgroud.jpg"
            }
            Image{
                id:texture_image
                height: width
                width: parent.width/2-40
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.horizontalCenter
                anchors.margins: dp2px(16)
                source:  currentImage!=""? currentImage: "qrc:/assets/assets/image_placeholder.png"
                fillMode: Image.PreserveAspectCrop
                Rectangle{
                    anchors.fill: parent
                    color: currentImage!=""? "#00E0E0E0":"#AAE0E0E0"
                    Column{
                        anchors.fill: parent
                        Item{
                            width: parent.width
                            height: parent.height/2
                            Image {
                                id: take_picture;
                                width: Math.min(parent.width/3,parent.height)
                                height: width
                                anchors.centerIn: parent
                                source: currentImage!=""?"qrc:/assets/assets/camera_icon_trasparent.png" :"qrc:/assets/assets/camera_icon.png"
                                MouseArea{
                                    anchors.fill: parent;
                                    onClicked:{
                                        loader.asynchronous=true;
                                        loader.source="qrc:/TakePicture.qml"
                                    }
                                }
                            }
                        }
                        Item{
                            width: parent.width
                            height: parent.height/2
                            Image{
                                id:take_from_file
                                width: take_picture.width
                                height: width
                                anchors.centerIn: parent
                                source: currentImage!=""? "qrc:/assets/assets/sdcard_transparent.png":"qrc:/assets/assets/sdcard.png"
                                MouseArea{
                                    anchors.fill: parent;
                                    onClicked: {
                                        loader.asynchronous=false;
                                        loader.source="qrc:/TakeFromFile.qml"
                                    }
                                }
                            }
                        }
                    }
                }
            }
            Item{
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.horizontalCenter
                anchors.margins: dp2px(16)
                width: parent.width/2 - dp2px(16)
                height: parent.height
                ColumnLayout{
                    anchors.fill: parent
                    anchors.centerIn: parent
                    anchors.margins: dp2px(16)
                    spacing: 10
                    TextField {
                        id:name_field
                        placeholderText: "Enter Name"
                        font.pointSize:14
                        Layout.fillWidth:true
                        //width: parent.width
                    }
                    TextField {
                        id:density_field
                        placeholderText: "Enter Density (0.1-2 g/cm3)"
                        focus:true
                        validator: DoubleValidator {bottom: 0.1 ; top: 2;}
                        font.pointSize:14
                        Layout.fillWidth:true
                    }
                    TextField {
                        id:price_field
                        placeholderText: "Enter Price"
                        focus:true
                        validator: IntValidator {bottom: 1; top: 100;}
                        font.pointSize:14
                        Layout.fillWidth:true
                    }
                    TextField {
                        id:young_field
                        placeholderText: "Enter Elasticity Module (15000-30000)"
                        font.pointSize:14
                        validator: IntValidator {bottom: 15000; top: 30000;}
                        Layout.fillWidth:true
                    }
                    TextField {
                        id:g_field
                        placeholderText: "Enter Shear Module (1000-1500)"
                        font.pointSize:14
                        validator: IntValidator {bottom: 1000; top: 1500;}
                        Layout.fillWidth:true
                    }
                    Row{
                        id:button_row
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 20
                        Button{
                            text: "Clear"
                            onClicked: {
                                name_field.text=""
                                density_field.text=""
                                price_field.text=""
                                young_field.text=""
                                g_field.text=""
                            }
                        }
                        Button{
                            text: "Create"
                            onClicked: {
                                exporter.createFile(texture_image.source,name_field.text,
                                                    density_field.text,price_field.text,
                                                    young_field.text,g_field.text)
                            }
                        }
                    }
                    Item{
                        anchors.top: button_row.bottom
                        anchors.right: parent.right
                        anchors.topMargin: dp2px(10)
                        Layout.preferredHeight: dp2px(60)
                        Text {
                            id:synch_text
                            text: qsTr("Synchronize on ")
                            font.pointSize: 15
                            anchors.verticalCenter: synch_button.verticalCenter
                            anchors.right: synch_button.left
                        }
                        Image{
                            id:synch_button
                            source: "qrc:/assets/assets/realto_logo.png"
                            height: dp2px(56)
                            width: height
                            anchors.right: parent.right
                            MouseArea{
                                anchors.fill: parent
                                onClicked: {
                                    exporter.pushMaterials();
                                }
                            }
                        }
                    }
                }
            }

            Rectangle{
                color:"#2f3439"
                anchors.fill: parent
                visible:loader.status==Loader.Loading || loader.status==Loader.Ready
                Loader{
                    anchors.fill: parent
                    id:loader
                    focus:true
                    Connections{
                        target:loader.item
                        onExit:{
                            loader.source=""
                        }
                    }
                }
            }
        }

        Rectangle{
            id:loginform
            visible: true;
            radius: 5
            border.color: "#F0F0F0"
            border.width: 10
            color: "transparent"
            anchors.fill: parent
            anchors.centerIn: parent

            Rectangle{
                anchors.fill: parent
                anchors.margins: 20
                color: "#2f3439"

                Image{
                    id:logo_image
                    source: "qrc:/assets/assets/realto_logo.png"
                    height: parent.height/3 - 20
                    width: height
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top:parent.top
                    anchors.margins: 20
                }
                TextField {
                    id:email_field
                    placeholderText: "Enter Email"
                    text:"lorenzo.lucignano@epfl.ch"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: logo_image.bottom
                    anchors.margins: 20
                    font.pointSize:15
                    width: parent.width-40

                }
                TextField {
                    id:host_field
                    placeholderText: "Enter Realto Host"
                    text: "http://10.0.0.15:3003/api/carpenterData"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: email_field.bottom
                    font.pointSize:15
                    anchors.margins: 20
                    width: parent.width-40

                }

                Button{
                    text: "Save"
                    onClicked: {
                        exporter.username=email_field.text
                        exporter.host=host_field.text
                        loginform.visible=false
                    }
                    anchors.top: host_field.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.margins: 20
                }
            }
        }


        ProgressBar{
            id:progressBar;
            visible: exporter.loading
            enabled: visible
            anchors.fill: parent
            indeterminate: true
        }


        Rectangle{
            id:messageBox
            visible:false;
            width: parent.width/3
            height: parent.height/3
            anchors.centerIn: parent
            Text {
                anchors.centerIn: parent
                id: message_text
            }
            function message(text){
                visible=true;
                message_text.text=text;
            }
            Timer{
                running: parent.visible
                onTriggered: parent.visible=false;
                interval: 5000
            }
        }
    }
    onClosing: {
        if(loader.status==Loader.Ready){
            loader.source="";
            close.accepted =false
        }
        else
            Qt.quit()
    }


}
