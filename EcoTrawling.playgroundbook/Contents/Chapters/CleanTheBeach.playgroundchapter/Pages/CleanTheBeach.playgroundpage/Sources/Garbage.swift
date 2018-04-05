//
//  Garbage.swift
//  EcoTrawling
//
//  Created by Geomar Bastiani on 31/03/2018.
//  Copyright © 2018 Geomar Bastiani. All rights reserved.
//

import UIKit
import SpriteKit


public class Garbage {
    public static let garbageListImages: [String] = [
        "garbageGlassBottle",
        "garbageOrganicChickenLeg",
        "garbageGlassBottleSoda",
        "garbageOrganicBitApple",
        "garbageOrganicCigaretteSmashed1",
        "garbageOrganicCigaretteSmashed2",
        "garbageOrganicCoconut",
        "garbagePaperFoodWrapHamburguer",
        "garbagePaperFoodWrapHamburguerOpen",
        "garbagePlasticBootleCapMetal",
        "garbagePlasticBottleSmashed",
        "garbagePlasticCup",
        "garbagePlasticBagBlue",
        "garbagePlasticCup2"
    ]
    
    public let name: String
    public var trashType: TrashType
    public let position: CGPoint
    public static var garbageList: [Garbage] = []
    
    public init(name: String, trashType: TrashType, position: CGPoint) {
        self.name = name
        self.trashType = trashType
        self.position = position
    }
    
    public static func load(size: CGSize){
        var index = 0
        for garbage in Garbage.garbageListImages {
            //check in the name the class of the trashcan
            var trashType: TrashType = .glass
            if garbage.range(of:"Organic") != nil {
                trashType = .organic
            } else if garbage.range(of:"Glass") != nil {
                trashType = .glass
            } else if garbage.range(of:"Paper") != nil {
                trashType = .paper
            } else if garbage.range(of:"Plastic") != nil {
                trashType = .plastic
            }
            //this if creates lines of images to spread the garbages by the beach
            var randomHeight: CGFloat = CGFloat(0.0)
            
            if index % 2 == 0 {
                randomHeight = -CGFloat(150.0)
            } else if index % 3 == 0 {
                randomHeight = CGFloat(10.0)
            }
            if index % 4 == 0 {
                randomHeight = -CGFloat(180.0)
            }
            
            //get fraction based on the quantity of the images to set its position
            let x = (CGFloat(index) + 1.0) / (CGFloat(Garbage.garbageListImages.count) + 1.0) * size.width
            let y = (size.height / 2) + randomHeight
            let position = CGPoint(x: x, y: y)
            let gabageClass = Garbage(name: garbage, trashType: trashType, position: position)
            garbageList.append(gabageClass)
            index += 1
        }
    }
}
