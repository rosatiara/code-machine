
import PlaygroundSupport
import UIKit
import Cutscenes

let item = SPCCutSceneItem(
    name: "Code Machine",
    sourcePath: "hourOfCode2017Intro/hourOfCode2017Intro.html",
    timeline: [
        (name: "Main Timeline", seconds: 0.0),
        (name: "Main Timeline", seconds: 3.0),
        (name: "Main Timeline", seconds: 20.23),
        (name: "Main Timeline", seconds: 35.87)]
)

PlaygroundPage.current.liveView = SPCHypeCutSceneController.makeFromStoryboard(for: item)
