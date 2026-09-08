import QtQuick
import QtQuick.Window

Rectangle {
    id: root
    color: "black"
    anchors.fill: parent

    property int frameCount: 300
    property int currentFrame: 1
    property bool useImage1: true

    function pad(n, width) {
        var s = n.toString();
        while (s.length < width)
            s = "0" + s;
        return s;
    }

    // Double buffering: one image visible, one loading in background
    Image {
        id: image1
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        cache: false
        visible: useImage1
        
        onStatusChanged: {
            if (status === Image.Error) console.log("Failed to load: " + source)
        }
    }

    Image {
        id: image2
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        cache: false
        visible: !useImage1

        onStatusChanged: {
            if (status === Image.Error) console.log("Failed to load: " + source)
        }
    }

    Component.onCompleted: {
        image1.source = "images/frame-001.png"
        image2.source = "images/frame-002.png"
    }

    Text {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 20
        text: "HxH Splash Loading..."
        color: "#333333"
        font.pixelSize: 14
        // Show loading text if the current visible image isn't ready yet (e.g. startup)
        visible: (useImage1 ? image1 : image2).status !== Image.Ready
    }

    Timer {
        interval: 40 // ~25 FPS
        running: true
        repeat: true
        onTriggered: {
            var nextImg = useImage1 ? image2 : image1
            if (nextImg.status === Image.Ready) {
                // Swap visibility
                useImage1 = !useImage1
                root.currentFrame = (root.currentFrame % root.frameCount) + 1
                
                // Preload the next frame in the now-hidden image
                var hiddenImg = useImage1 ? image2 : image1
                var nextFrameNum = (root.currentFrame % root.frameCount) + 1
                hiddenImg.source = "images/frame-" + pad(nextFrameNum, 3) + ".png"
            }
        }
    }
}
