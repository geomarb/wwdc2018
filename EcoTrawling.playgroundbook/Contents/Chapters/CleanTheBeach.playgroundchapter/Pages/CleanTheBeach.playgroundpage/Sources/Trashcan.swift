//
//  Trashcan.swift
//  EcoTrawling
//
//  Created by Geomar Bastiani on 31/03/2018.
//  Copyright © 2018 Geomar Bastiani. All rights reserved.
//

import UIKit
import SpriteKit

public enum TrashType {
    case organic
    case glass
    case plastic
    case paper
}
public class Trashcan {
    public static let trashCanListImages: [String] = [
        "trashcanGlassBlue",
        "trashcanOrganicGreen",
        "trashcanPaperYellow",
        "trashcanPlasticRed"
    ]
    
    public let name: String
    public let trashType: TrashType
    public let position: CGPoint
    public static var trashcanList: [Trashcan] = []
    
    private init(name: String, trashType: TrashType, position: CGPoint) {
        self.name = name
        self.trashType = trashType
        self.position = position
    }
    
    public static func load(size: CGSize) {
        var index = 0
        for trashcan in Trashcan.trashCanListImages {
            //check in the name the class of the trashcan
            var trashType: TrashType = .glass
            if trashcan.range(of:"Organic") != nil {
                trashType = .organic
            } else if trashcan.range(of:"Glass") != nil {
                trashType = .glass
            } else if trashcan.range(of:"Paper") != nil {
                trashType = .paper
            } else if trashcan.range(of:"Plastic") != nil {
                trashType = .plastic
            }
            
            //get fraction based on the quantity of the images to set its position
            let x = (CGFloat(index) + 1.0) / (CGFloat(Trashcan.trashCanListImages.count) + 1.0) * size.width
            let y = (size.height / 2) + 110
            let position = CGPoint(x: x, y: y )
            let trashcanClass = Trashcan(name: trashcan, trashType: trashType, position: position)
            trashcanList.append(trashcanClass)
            index += 1
        }
    }
}
