//
//  User.swift
//  MyHomeProject
//
//

import Foundation

struct UserApi: Codable {
    var rows:[User]
    //var fields:[User]
}


//tell swift that this struct should be codable
/* set custom names*/
struct User: Codable {
    var email: String
    var password: String
    var id: Int  // id: must have the id
    
    
    enum CodingKeys: String, CodingKey{
        case email = "email"
        case password = "password"
        case id = "id"
        
    }
}
