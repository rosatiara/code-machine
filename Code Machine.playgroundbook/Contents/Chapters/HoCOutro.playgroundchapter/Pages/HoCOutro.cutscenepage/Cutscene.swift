
import PlaygroundSupport
import UIKit
import Cutscenes

let item = SPCCutSceneItem(
    name: "Congratulations!",
    sourcePath: "hourOfCode2017Outro/hourOfCode2017Outro.html",
    timeline: [
        (name: "Main Timeline", seconds: 0.0),
        (name: "Main Timeline", seconds: 6.77)],
    isOutro: true
)

PlaygroundPage.current.liveView = SPCHypeCutSceneController.makeFromStoryboard(for: item)
