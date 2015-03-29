//
//  Item.swift
//  Archive
//
//  Created by Michael Stromer on 3/29/15.
//  Copyright (c) 2015 Michael Stromer. All rights reserved.
//

import UIKit

class Item: NSObject, NSCoding {
    
    //Properties
    var name: String
    var cost: Double
    var imageName: String
    
    var image: UIImage?
    
    let kName = "name"
    let kCost = "cost"
    let kImageName = "imageName"
    
    //Initializers
    
    init(name: String, cost: Double, imageName: String) {
        self.name = name
        self.cost = cost
        self.imageName = imageName
        self.image = nil
        //required to init super class
        super.init()
    }
    override var description: String {
        return "\(name), \(cost), imageName: \(imageName)"
    }
    
    required init(coder aDecoder: NSCoder) { //words + description
        self.name = aDecoder.decodeObjectForKey(kName) as String
        self.cost = aDecoder.decodeDoubleForKey(kCost) as Double
        self.imageName = aDecoder.decodeObjectForKey(kImageName) as String
        
        self.image = nil
        super.init() //subclass of another coder
        
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: kName)
        aCoder.encodeDouble(cost, forKey: kCost)
        aCoder.encodeObject(imageName, forKey: kImageName)
    }

}
