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
    property string name;
    property real density:1;
    property real price:1;
    property real young:7000;
    property real g:440;
    property real fmk:10;
    property real fvk:10;
    property real ft0:10;
    property real fc0:10;
    property real fc90:10;
    property real ft90:10;

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
                    TabView{
                        Layout.fillWidth:true
                        Layout.fillHeight:true
                        Tab{
                            title: "General"
                            anchors.fill: parent
                            Rectangle{
                                color:"white"
                                anchors.fill: parent

                                GridLayout{
                                    rows: 5
                                    columns: 2
                                    anchors.fill: parent
                                    Label {
                                        text: "Name"
                                    }
                                    TextField {
                                        id:name_field
                                        placeholderText: "Enter Name"
                                        font.pointSize:12
                                        onTextChanged: name=text;

                                    }

                                    Label {
                                        text: "Density(g/cm3)"
                                    }
                                    SpinBox {
                                        id: density_field
                                        decimals: 1
                                        stepSize: 0.1
                                        value: density
                                        minimumValue: 0.1
                                        maximumValue: 2
                                        font.pointSize: 12
                                        onValueChanged: density=value;

                                    }


                                    Label {
                                        text: "Price(Chf)"
                                    }
                                    SpinBox {
                                        id: price_field
                                        stepSize: 1
                                        value: price
                                        minimumValue: 1
                                        maximumValue: 100
                                        font.pointSize: 12
                                        onValueChanged: price=value;

                                    }


                                    Label {
                                        text: "Elasticity(N/mm2)"
                                    }
                                    SpinBox {
                                        id: young_field
                                        stepSize: 500
                                        value: young
                                        minimumValue: 3000
                                        maximumValue: 30000
                                        font.pointSize: 12
                                        onValueChanged: young=value;

                                    }
                                    Label {
                                        text: "Shear Modulus(N/mm2)"
                                    }
                                    SpinBox {
                                        id: g_field
                                        value: g
                                        stepSize: 50
                                        minimumValue: 100
                                        maximumValue: 1500
                                        font.pointSize: 12
                                        onValueChanged: g=value;

                                    }

                                }
                            }
                        }

                        Tab{
                            title: "Resistance"
                            anchors.fill: parent
                            Rectangle{
                                color:"white"
                                anchors.fill: parent
                                GridLayout{
                                    rows: 6
                                    columns: 2
                                    anchors.fill: parent
                                    Label {
                                        text: "Fmd(N/mm2)"
                                    }
                                    SpinBox {
                                        id: fmk_field
                                        decimals: 1
                                        stepSize: 1
                                        value: fmk
                                        minimumValue: 1
                                        maximumValue: 100
                                        font.pointSize: 12
                                        onValueChanged: fmk=value;

                                    }
                                    Label {
                                        text: "Fvd(N/mm2)"
                                    }
                                    SpinBox {
                                        id: fvk_field
                                        decimals: 1
                                        stepSize: 1
                                        value: fvk
                                        minimumValue: 1
                                        maximumValue: 100
                                        font.pointSize: 12
                                        onValueChanged: fvk=value;

                                    }
                                    Label {
                                        text: "Ft0d(N/mm2)"
                                    }
                                    SpinBox {
                                        id: ft0_field
                                        decimals: 1
                                        stepSize: 1
                                        value: ft0
                                        minimumValue: 1
                                        maximumValue: 100
                                        font.pointSize: 12
                                        onValueChanged: ft0=value;

                                    }
                                    Label {
                                        text: "Fc0d(N/mm2)"
                                    }
                                    SpinBox {
                                        id: fc0_field
                                        decimals: 1
                                        stepSize: 1
                                        value: fc0
                                        minimumValue: 1
                                        maximumValue: 100
                                        font.pointSize: 12
                                        onValueChanged: fc0=value;

                                    }

                                    Label {
                                        text: "Ft90d(N/mm2)"
                                    }
                                    SpinBox {
                                        id: ft90_field
                                        decimals: 1
                                        stepSize: 1
                                        value: ft90
                                        minimumValue: 1
                                        maximumValue: 100
                                        font.pointSize: 12
                                        onValueChanged: ft90=value;

                                    }
                                    Label {
                                        text: "Fc90d(N/mm2)"
                                    }
                                    SpinBox {
                                        id: fc90_field
                                        decimals: 1
                                        stepSize: 1
                                        value: fc90
                                        minimumValue: 1
                                        maximumValue: 100
                                        font.pointSize: 12
                                        onValueChanged: fc90=value;
                                    }

                                }
                            }
                        }

                    }

                    Row{
                        id:button_row
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 20
                        Button{
                            text: "Create"
                            onClicked: {
                                exporter.createFile(texture_image.source,name,
                                                    density,price,
                                                    young,g,
                                                    fc0,fc90,
                                                    fmk,ft0,
                                                    ft90,fvk)
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
