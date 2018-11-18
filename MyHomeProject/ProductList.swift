//
//  ProductList.swift
//  MyHomeProject
//
//

import Foundation

struct ProductListApi: Codable {
    var rows:[ProductList]
}


struct ProductList: Codable {
    var productID: Int
    var listID: Int
    var amount: String
    var buy: Bool
    var id: Int 
    
    
    enum CodingKeys: String, CodingKey{
        case productID = "productid"
        case listID = "listid"
        case amount = "amount"
        case buy = "buy"
        case id = "id"
        
    }
}


