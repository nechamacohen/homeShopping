//
//  ProductInListObject.swift
//  MyHomeProject
//
//

import UIKit

class ProductInListObject: NSObject {
    
    var name: String
    var details: String
    var id: Int
    var productID: Int
    var listID: Int
    var amount: String
    var buy: Bool
    
    required override init() {
        
        name = String()
        details = String()
        id = 0
        productID = 0
        listID = 0
        amount = "1"
        buy = false
        
        super.init()
        
    }
    
    

}

struct ProductInListObjectList {
    
    static var list = Array<ProductInListObject>()
    
}
