//
//  News.swift
//  Group7-project
//
//  Created by tommylung on 14/11/2019.
//  Copyright © 2019 ee4304-gp7-project. All rights reserved.
//

import Foundation
import Firebase
struct news {
    let key: String
    var title: String
    var source: String
    var imageurl: String
    var savenews: String
    
    init(title: String, source: String, imageurl: String, savenews: String,key: String = "" ) {
        self.key = key
        self.title = title
        self.source = source
        self.imageurl = imageurl
        self.savenews = savenews

    
    }
    init(snapshot: DataSnapshot) {
            key = snapshot.key
              let snapshotValue = snapshot.value as! [String: AnyObject]
              source = snapshotValue["source"] as! String
              imageurl = snapshotValue["imageurl"] as! String
              savenews = snapshotValue["savenews"] as! String
              title = snapshotValue["title"] as! String

              
//              ref = snapshot.ref
    }
    func toAnyObject() -> Any {
        return [
            "title": title,
            "source": source,
            "imageurl": imageurl,
            "savenews": savenews,
            ]
    }
}
