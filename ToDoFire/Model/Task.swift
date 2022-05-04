//
//  Task.swift
//  ToDoFire
//
//  Created by Zhasur Sidamatov on 03/05/2022.
//

import Foundation
import Firebase


struct Task {
    let title: String
    let userId: String
    let ref: DatabaseReference?
    var completed: Bool = false
    
    init(title: String, userId: String) {
        self.title = title
        self.userId = userId
        self.ref = nil
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String : AnyObject]
        title = snapshotValue["title"] as! String
        userId = snapshotValue["userId"] as! String
        completed = snapshotValue["competed"] as! Bool
        ref = snapshot.ref
    }
}
