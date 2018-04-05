//
//  Game.swift
//  EcoTrawling
//
//  Created by Geomar Bastiani on 31/03/2018.
//  Copyright © 2018 Geomar Bastiani. All rights reserved.
//
//: Add createGame() to start to play
import UIKit
import Foundation
import PlaygroundSupport
import SpriteKit

public class CreateGame {
    public init() {
        let view = SKView(frame: CGRect(x: 0, y:0, width: 1024, height: 570 ))
        let scene: SKScene = GameScene(size: view.frame.size)
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .aspectFill
        view.presentScene(scene)
        
        PlaygroundPage.current.liveView = view
        PlaygroundPage.current.needsIndefiniteExecution = true
    }
}
