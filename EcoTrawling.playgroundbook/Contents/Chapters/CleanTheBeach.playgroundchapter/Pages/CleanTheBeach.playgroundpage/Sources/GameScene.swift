//
//  GameScene.swift
//  EcoTrawling
//
//  Created by Geomar Bastiani on 26/03/2018.
//  Copyright © 2018 Geomar Bastiani. All rights reserved.
//
//#-hidden-code
import SpriteKit

public class GameScene: SKScene, SKPhysicsContactDelegate {
    let background = SKSpriteNode(imageNamed: "beach")
    var selectedNode = SKSpriteNode()
    var screenSize: CGSize = CGSize(width: 570, height: 1024)
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(size: CGSize) {
        super.init(size: size)
        self.size = screenSize
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        addBackground()
        addGarbage()
        addTrashcan()
    }
    func addBackground() {
        background.name = "background"
        background.size = screenSize
        background.blendMode = .replace
        background.anchorPoint.x = self.anchorPoint.x
        background.anchorPoint.y = self.anchorPoint.x
        background.zPosition = -1
        background.isUserInteractionEnabled = false
        self.addChild(background)
    }
    func addGarbage() {
        Garbage.load(size: self.size)
        //run all garbages, set them and add to the sprite
        for garbage in Garbage.garbageList {
            //get the name of the image
            let position = garbage.position
            let imageName = garbage.name
            addNode(imageName: imageName, position: position, categoryBitMask: 1, collisionBitMask: 0, contactTestBitMask: 1, zPosition: 1, scale: 0.23)
        }
    }
    func addTrashcan() {
        Trashcan.load(size: self.size)
        //run all trashcans and create nodes
        for trashcan in Trashcan.trashcanList {
            //get the name of the image
            let position = trashcan.position
            let imageName = trashcan.name
            addNode(imageName: imageName, position: position, categoryBitMask: 0 , collisionBitMask: 1 , contactTestBitMask: 1, zPosition: 2, scale: 0.8)
        }
    }
    func addNode(imageName: String, position: CGPoint, categoryBitMask: UInt32, collisionBitMask: UInt32, contactTestBitMask: UInt32, zPosition: CGFloat, scale: CGFloat) {        
        //define the texture
        let texture = SKTexture(imageNamed: imageName)
        //create the sprite node based on the image
        let sprite = SKSpriteNode(imageNamed: imageName)
        //set the name of the sprite with the same name of the image
        sprite.name = imageName
        //set the "level that it will appear in the screen"
        sprite.zPosition = zPosition
        //reduces the scale to get a good resolution quality of the images are bigger
        sprite.setScale(scale)
        //set the texture
        sprite.physicsBody = SKPhysicsBody(texture: texture, size: sprite.size)
        //set collision detection
        sprite.physicsBody?.usesPreciseCollisionDetection = true
        //set the position
        sprite.position = position
        //set the colision based in the category of the garbage
        sprite.physicsBody?.categoryBitMask =  categoryBitMask
        sprite.physicsBody?.collisionBitMask = collisionBitMask
        sprite.physicsBody?.contactTestBitMask = contactTestBitMask
        background.addChild(sprite)
    }
    
    public func didBegin(_ contact: SKPhysicsContact) {
        
        let nodeAIsTrashcan = contact.bodyA.node?.name?.range(of: "trashcan") != nil
        let nodeBIsTrashcan = contact.bodyB.node?.name?.range(of: "trashcan") != nil
        let nodeAIsGarbage = contact.bodyA.node?.name?.range(of: "garbage") != nil
        let nodeBIsGarbage = contact.bodyB.node?.name?.range(of: "garbage") != nil
        
        if nodeAIsTrashcan && nodeBIsTrashcan { return }
        if nodeAIsGarbage && nodeBIsGarbage { return }
        
        var trashcanNode: SKNode?
        if nodeAIsTrashcan { trashcanNode = contact.bodyA.node }
        if nodeBIsTrashcan { trashcanNode = contact.bodyB.node }
        
        var garbageNode: SKNode?
        if nodeAIsGarbage { garbageNode = contact.bodyA.node }
        if nodeBIsGarbage { garbageNode = contact.bodyB.node }
        
        let garbage = Garbage.garbageList.filter({$0.name == garbageNode?.name})[0]
        let trashcan = Trashcan.trashcanList.filter({$0.name == trashcanNode?.name})[0]
        
        if garbage.trashType == trashcan.trashType {
            
            self.background.childNode(withName: (garbage.name))?.removeAllActions()
            camera?.removeAllActions()
            self.background.removeChildren(in: [garbageNode!])
            camera?.removeAllActions()
            self.background.childNode(withName: trashcan.name)?.removeAllActions()
            deleteHintLabel()
        }
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let position = touch.location(in: self)
            selectAndAnimateNodeTouched(touchLocation: position)
            
            let touchedNode = self.atPoint(position) as! SKSpriteNode
            if let name = touchedNode.name {
                if Garbage.garbageListImages.contains(name) {
                    addHintLabel(position: selectedNode.position, nodeName: touchedNode.name!)
                }
            }
        }
    }
    func selectAndAnimateNodeTouched(touchLocation: CGPoint) {
        let touchedNode = self.atPoint(touchLocation)
        if touchedNode is SKSpriteNode {
            if !selectedNode.isEqual(touchedNode) {
                selectedNode.removeAllActions()
                deleteHintLabel()
                selectedNode.run(SKAction.rotate(toAngle: 0.0, duration: 0.1))
                selectedNode = touchedNode as! SKSpriteNode
                //add shaking effect to the node
                if Garbage.garbageListImages.contains(touchedNode.name!) {
                    selectedNode.run(SKAction.repeatForever(shakeMe()))
                }
            }
        }
    }
    func shakeMe() -> SKAction {
        let movingAction = SKAction.sequence([SKAction.rotate(byAngle: toRadian(degree: -4.0), duration: 0.1),
                                              SKAction.rotate(byAngle: 0.0, duration: 0.1),
                                              SKAction.rotate(byAngle: toRadian(degree: 4.0), duration: 0.1)])
        return movingAction
    }
    
    func toRadian(degree: Double) -> CGFloat {
        return CGFloat(Double(degree) / 180.0 * Double.pi)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let positionInScene = touch.location(in: self)
            let previousPosition = touch.previousLocation(in: self)
            let translation = CGPoint(x: positionInScene.x - previousPosition.x, y: positionInScene.y - previousPosition.y)
            
            if Garbage.garbageListImages.contains(selectedNode.name!) {
                selectedNode.position = CGPoint(x: selectedNode.position.x + translation.x, y: selectedNode.position.y + translation.y)
                moveHintLabel(position: selectedNode.position, nodeName: selectedNode.name!)
            } else {
                var newPositionOfBackground = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
                newPositionOfBackground.x = CGFloat(min(newPositionOfBackground.x, 0))
                newPositionOfBackground.x = CGFloat(max(newPositionOfBackground.x, -(background.size.width) +  self.size.width))
                newPositionOfBackground.y = self.position.y
                background.position = newPositionOfBackground
            }
        }
    }
    func addHintLabel(position: CGPoint, nodeName: String) {
        let imageHomeTrashcan = "homeTrashCan"
        let homeTrashcan = SKSpriteNode(imageNamed: imageHomeTrashcan)
        homeTrashcan.name = imageHomeTrashcan
        homeTrashcan.zPosition = 3
        homeTrashcan.setScale(0.6)
        
        //figure out which type is the node clicked
        let typeTrash = Garbage.garbageList.filter({$0.name == nodeName})[0].trashType
        let trashcan = Trashcan.trashcanList.filter({$0.trashType == typeTrash})[0].name
        
        let trashcanPosition = background.childNode(withName: trashcan)?.position
        background.childNode(withName: "trashcan")?.run(SKAction.repeatForever(shakeMe()))
        homeTrashcan.position = CGPoint(x: (trashcanPosition?.x)! + CGFloat(20), y: (trashcanPosition?.y)! + CGFloat(150))
        background.addChild(homeTrashcan)
        
        if background.childNode(withName: trashcan)?.position == position {return}
        
        let imageTextThinking = "textThinking"
        if background.childNode(withName: imageTextThinking) != nil { return }
        let textThinking = SKSpriteNode(imageNamed: imageTextThinking)
        textThinking.name = imageTextThinking
        textThinking.zPosition = 4
        textThinking.setScale(0.6)
        textThinking.position = CGPoint(x: position.x + CGFloat(20), y: position.y + CGFloat(120))
        background.addChild(textThinking)
        
    }
    func moveHintLabel(position: CGPoint, nodeName: String) {
        
        guard let homeTrashcan = background.childNode(withName: "homeTrashCan") as! SKSpriteNode? else { return }
        //figure out which type is the node clicked
        let typeTrash = Garbage.garbageList.filter({$0.name == nodeName})[0].trashType
        let trashcan = Trashcan.trashcanList.filter({$0.trashType == typeTrash})[0].name

        let trashcanPosition = background.childNode(withName: trashcan)?.position
        homeTrashcan.position = CGPoint(x: (trashcanPosition?.x)! + CGFloat(20), y: (trashcanPosition?.y)! + CGFloat(150))
        
        guard let textThinking =  background.childNode(withName: "textThinking") as! SKSpriteNode? else { return }
        textThinking.position = CGPoint(x: position.x + CGFloat(20), y: position.y + CGFloat(112))
    }
    func deleteHintLabel() {
        guard let homeTrashcan = background.childNode(withName: "homeTrashCan") as! SKSpriteNode? else { return }
        background.removeChildren(in:[homeTrashcan])
        guard let textThinking =  background.childNode(withName: "textThinking") as! SKSpriteNode? else { return }
        background.removeChildren(in:[textThinking])
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        deleteHintLabel()
        for trashcan in Trashcan.trashcanList {
            self.background.childNode(withName: trashcan.name)?.position = trashcan.position
        }
    }
}
//#-end-hidden-code
