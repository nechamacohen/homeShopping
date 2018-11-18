//
//  List.swift
//  MyHomeProject
//
//

import Foundation

struct ListsApi: Codable {
    var rows:[List]
}


//tell swift that this struct should be codable
/* set custom names*/
struct List: Codable {
    var name: String
    var userID: Int
    var id: Int  // id: must have the id
    
    
    enum CodingKeys: String, CodingKey{
        case name = "name"
        case userID = "userid"
        case id = "id"
        
    }
}
