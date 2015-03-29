//
//  Inventory.swift
//  Archive
//
//  Created by Michael Stromer on 3/29/15.
//  Copyright (c) 2015 Michael Stromer. All rights reserved.
//

import UIKit

class Inventory: NSObject, NSCoding {
    
    var itemArray: [Item]
    
    var lastViewedIndex: Int? //last viewed item
    
    let kItemArrayKey = "itemArray"
    let kLastViewedIndex = "lastViewedIndex"
    
    override init() {
        itemArray = [Item]()
        lastViewedIndex = nil
        
        super.init()
        
    }
    override var description: String {
        return "items: \(itemArray), lastViewedIndex: \(lastViewedIndex)"
    }
    required init(coder decoder: NSCoder) {
        itemArray = decoder.decodeObjectForKey(kItemArrayKey) as [Item]
        lastViewedIndex = decoder.decodeObjectForKey(kLastViewedIndex) as Int?
        super.init()
    }
    func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(itemArray, forKey: kItemArrayKey)
    aCoder.encodeObject(lastViewedIndex, forKey: kLastViewedIndex)
    }
}
