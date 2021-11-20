//
//  CodeMachineLiveViewController.swift
//
//  Copyright © 2016-2018 Apple Inc. All rights reserved.
//

import SPCCore
import SPCLiveView
import SPCAudio
import PlaygroundSupport
import UIKit

public class CodeMachineLiveViewController: LiveViewController {
    
    private let foundryViewController: FoundryViewController
    
    public init() {
        LiveViewController.contentPresentation = .aspectFitMaximum

        foundryViewController = FoundryViewController.makeFromStoryboard()
        
        super.init(nibName: nil, bundle: nil)
        
        classesToRegister = [CodeMachineLiveViewProxy.self]

        lifeCycleDelegates = [audioController, foundryViewController]
    }

    required init?(coder: NSCoder) {
        fatalError("SonicLiveViewController.init?(coder) not implemented.")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(foundryViewController)
        
        contentView = foundryViewController.view
        
        let audioButton = AudioBarButton()

        audioButton.toggleBackgroundAudioOnly = true

        addBarButton(audioButton)

        if let contentContainerView = foundryViewController.view.superview {
            contentContainerView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                contentContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                contentContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                contentContainerView.widthAnchor.constraint(equalTo: view.widthAnchor),
                contentContainerView.heightAnchor.constraint(equalTo: view.heightAnchor)
            ])
        }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//            setItemA(.metal)
//            setItemB(.cloth)
//            forgeItems()
//        }
    }
}

