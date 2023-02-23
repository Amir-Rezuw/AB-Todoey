//
//  Category.swift
//  Todoey
//
//  Created by AmirReza Jamali on 12/29/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var categoryName: String = ""
    @objc dynamic var cellColor:String = ""
    let items = List<Item>()
    let test = []
    
}
