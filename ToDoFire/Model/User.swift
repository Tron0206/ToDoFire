//
//  User.swift
//  ToDoFire
//
//  Created by Zhasur Sidamatov on 03/05/2022.
//

import Foundation
import Firebase
import FirebaseAuth


struct Client {
    let uid: String
    let email: String?
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
    }
}
