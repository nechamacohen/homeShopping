//
//  Product.swift
//  MyHomeProject
//
//

import UIKit


struct ProductApi: Codable {
    var rows:[Product]
}



struct Product: Codable {
    var name: String
    var details: String
    var id: Int  // id: must have the id
    
    
    enum CodingKeys: String, CodingKey{
        case name = "name"
        case details = "details"
        case id = "id"
        
    }
}




//var products:[Product] = [
//    Product(productId: "1", name: "milk", category: "super",amount: "3", details: "tnuva"),
////    Product(productId: "1", name: "bamba", category: "super",amount: "2", details: "osem"),
////    Product(productId: "1", name: "bisli", category: "super",amount: "8", details: "osem")
//]

