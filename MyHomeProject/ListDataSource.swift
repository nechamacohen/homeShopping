//
//  ListDataSource.swift
//  MyHomeProject
//
//

import UIKit

//let apiAddress = "http://localhost:3000"
let apiAddress = "https://nechama.herokuapp.com"
let session = URLSession.shared
typealias Json = Dictionary<String, Any>


// 1. get List of Lists names for userId


//הצגת הרשימות במסך הראשון

func getAPILists(callback: @escaping (ListsApi) -> Void){
    //https://nechama.herokuapp.com/lists/listbyuser?userId=99
    guard let userId = UserDefaults.standard.string(forKey: "idFromDb") else{
        print("Error")
        return
    }
    print(userId)
    let url = URL(string: "\(apiAddress)/lists/listbyuser?userId=\(userId)")!
    session.dataTask(with: url) { (data, res, err) in
        guard let data = data
            else{
            return
        }
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(ListsApi.self, from: data)
            DispatchQueue.main.async {
                callback(result)
            }
            
        } catch {
            print("json error: \(error.localizedDescription)")
        }
        
        
        }.resume()
}

// 2. Save new List on server:

//מוסיף את הרשימות למסך הראשי של הרשימות
func addLists(userID:String, name: String, callback: @escaping (Int)->Void){
    //    guard let userId = UserDefaults.standard.string(forKey: "userID") else {
    //        print("Error")
    //        return
    //    }
    let urlString = "\(apiAddress)/lists/add?name=\(name)&userID=\(userID)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    let url = URL(string: urlString!)!
    //let url = URL(string: "\(apiAddress)/lists/add?name=\(name)&userID=\(userID)")!
    
    let task = session.dataTask(with: url) { (data, res, err) in
        if let err = err{
            print(err)
        } else{
            //else use the data binary = DATA
            guard let data  = data else {return}
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! Json
                let rows  = json["rows"] as? [Json]
                let row = rows![0]
                let id = row["max"] as! Int
                DispatchQueue.main.async {
                    callback(id)
                }
                
            } catch {
                print("json error: \(error.localizedDescription)")
            }
            
        }
    }
    task.resume() //task start their life in a suspended state
}

// 3. Save new product in list on server:


func addProductLists(name:String, details:String, listID: Int, amount: String, buy:Bool, callback: @escaping (Int)->Void){
    
    //https://nechama.herokuapp.com/listproducts/addu?name=milk1&details=tnuva&listID=34&amount=7&buy=false
    
    //    let url = URL(string: "\(apiAddress)/listproducts/addu?name=\(name)&details=\(details)&listID=\(listID)&amount=\(amount)&buy=\(buy)")!
    //    print(url.absoluteURL)
    
    let urlString = "\(apiAddress)/listproducts/addu?name=\(name)&details=\(details)&listID=\(listID)&amount=\(amount)&buy=\(buy)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    let url = URL(string: urlString!)!
    
    let task = session.dataTask(with: url) { (data, res, err) in
        if let err = err{
            print(err)
        } else{
            //else use the data binary = DATA
            guard let data  = data else {return}
            do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? Json
                let rows  = json!["rows"] as? [Json]
                let row = rows![0]
                let id = row["max_id"] as! Int
            DispatchQueue.main.async {
                callback(id)
            }
            } catch {
                print("json error: \(error.localizedDescription)")
            }
            //מחזיר את הקוד של המשתמש שנרשם אחרון ואיתו אני בודקת בתנאי
        }
    }
    task.resume() //task start their life in a suspended state
}

// 4. Get products in list for list id:


//הצגת המוצרים בטבלת מוצרים ברשימה


func getAPIProductLists(listId:Int,  callback: @escaping (ProductListApi) -> Void){
    
    //https://nechama.herokuapp.com/listproducts/list?listId=11
    
    let url = URL(string: "\(apiAddress)/listproducts/list?listId=\(listId)")!
    session.dataTask(with: url) { (data, res, err) in
        guard let data = data else{return}
        do {
        let decoder = JSONDecoder()
        let result = try decoder.decode(ProductListApi.self, from: data)
        DispatchQueue.main.async {
            callback(result)
        }
        } catch {
            print("json error: \(error.localizedDescription)")
        }
        }.resume()
}

// 4.1 get product for productId

//https://nechama.herokuapp.com/products/productbyid?id=4

func getProductForID(productId: Int,  callback: @escaping (ProductApi) -> Void) {
    
    let url = URL(string: "\(apiAddress)/products/productbyid?id=\(productId)")!
    
    session.dataTask(with: url) { (data, res, err) in
        guard let data = data else{return}
        do {
        let decoder = JSONDecoder()
        let result = try decoder.decode(ProductApi.self, from: data)
        DispatchQueue.main.async {
            callback(result)
        }
        } catch {
            print("json error: \(error.localizedDescription)")
        }
        }.resume()
    
}

//5. Delete list on server:

func deleteListFromDB(listId:Int,  callback: @escaping (String) -> Void){
    
    // https://nechama.herokuapp.com/lists/delete?id=41
    
    let url = URL(string: "\(apiAddress)/lists/delete?id=\(listId)")!
    session.dataTask(with: url) { (data, res, err) in
        if data == nil {return}
        DispatchQueue.main.async {
            callback("ok")
        }
        }.resume()
}

// 6. Delete product from list on server:

func deleteProductFromListInServer(productId: Int, listId:Int,  callback: @escaping (String) -> Void){
    
    // https://nechama.herokuapp.com/listproducts/delete?productID=3&listID=6
    
    let url = URL(string: "\(apiAddress)/listproducts/delete?productID=\(productId)&listID=\(listId)")!
    session.dataTask(with: url) { (data, res, err) in
        if data == nil {return}
        DispatchQueue.main.async {
            callback("ok")
        }
        }.resume()
}

// 7. Update product from list on server: update amount, update buy

func updateProductFromListInServer(productId: Int, listId:Int, amount: String, buy: Bool,  callback: @escaping (String) -> Void){
    
    // https://nechama.herokuapp.com/listproducts/update?productID=3&listID=6&amount=4&buy=true
    
    let url = URL(string: "\(apiAddress)/listproducts/update?productID=\(productId)&listID=\(listId)&amount=\(amount)&buy=\(buy)")!
    
    session.dataTask(with: url) { (data, res, err) in
        if data == nil {return}
        DispatchQueue.main.async {
            callback("ok")
        }
        }.resume()
}


// 8. Get list of existing products from server:

func getProducts( callback: @escaping (ProductApi) -> Void) {
    
    // https://nechama.herokuapp.com/products/list
    //let url = URL(string: "\(apiAddress)/products/list")!
    let url = URL(string: "https://nechama.herokuapp.com/products/list")!
    session.dataTask(with: url) { (data, res, err) in
        guard let data = data else{return}
        
        do {
        let decoder = JSONDecoder()
        let result = try decoder.decode(ProductApi.self, from: data)
        DispatchQueue.main.async {
            callback(result)
        }
        } catch {
            print("json error: \(error.localizedDescription)")
        }
        }.resume()
    
}





















// function to project continue...

func getLists(){
    //1) URLSession -> VS URLConnection  -> Auto Cache
    
    //Data: Binary Data -> 0101
    //URLResponce: status code
    //error
    //  UserDefaults.standard.set(id, forKey: "idFromDb") (got id from db in remote server after registration)
    
    guard let userId = UserDefaults.standard.string(forKey: "idFromDb") else{
        print("Error")
        return
    }
    let url = URL(string: "\(apiAddress)/lists/listbyuser?userId=\(userId)")!
    let task = session.dataTask(with: url) { (data, res, err) in
        //var students = [Student]()
        //check if we have an err?
        if let err = err{
            print(err)
        } else{
            //else use the data
            guard let data  = data else {return}
            let lists = deserializeJson(data: data)
            print(lists)
            
        }
        
    }
    task.resume() //task start their life in a suspended state
}


func deserializeJson(data: Data)->[List]{
    var lists = [List]()
    do{
        let json = try JSONSerialization.jsonObject(with: data, options: []) as! Json
        let rows = json["rows"]! as! [Json]
        for row in rows{
            let name = row["name"] as? String ?? ""
            let userID = row["userID"] as! Int
            let id = row["id"] as! Int
            lists.append(List(name: name, userID: userID, id: id))
            
        }
    }
    catch let err{
        print(err)  //TODO Error Callback
    }
    return lists
}









func getProductLists(){
    
    let url = URL(string: "\(apiAddress)/listproducts/list")!
    let task = session.dataTask(with: url) { (data, res, err) in
        
        if let err = err{
            print(err)
        } else{
            //else use the data
            guard let data  = data else {return}
            let productLists = deserializeJsonProductList(data: data)
            print(productLists)
            
        }
        
    }
    task.resume() //task start their life in a suspended state
}


func deserializeJsonProductList(data: Data)->[ProductList]{
    var productLists = [ProductList]()
    do{
        let json = try JSONSerialization.jsonObject(with: data, options: []) as! Json
        let rows = json["rows"]! as! [Json]
        for row in rows{
            let productID = row["productID"] as! Int
            let listID = row["listID"] as! Int
            let amount = row["amount"] as? String ?? ""
            let buy = row["buy"] as? Bool ?? false
            let id = row["id"] as! Int
            productLists.append(ProductList(productID: productID, listID: listID, amount: amount, buy: buy, id: id))
            
            
        }
    }
    catch let err{
        print(err)
    }
    return productLists
}


//מוסיף מוצרים לרשימה ספציפית
func addProductLists(productID:Int, listID: Int, amount: String, buy:Bool, callback: @escaping (Int)->Void){
//    let urlString = "\(apiAddress)/listproducts/add?productID=\(productID)&listID=\(listID)&amount=\(amount)&buy=\(buy)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
//    let url = URL(string: urlString!)!
    let url = URL(string: "\(apiAddress)/listproducts/add?productID=\(productID)&listID=\(listID)&amount=\(amount)&buy=\(buy)")!
    print(url.absoluteURL)

    let task = session.dataTask(with: url) { (data, res, err) in
        if let err = err{
            print(err)
        } else{
            //else use the data binary = DATA
            guard let data  = data else {return}
            let json = try! JSONSerialization.jsonObject(with: data, options: []) as! Json
            let rows  = json["rows"] as! [Json]
            let row = rows[0]
            let id = row["max"] as! Int
            DispatchQueue.main.async {
                callback(id)
            }
            //מחזיר את הקוד של המשתמש שנרשם אחרון ואיתו אני בודקת בתנאי
        }
    }
    task.resume() //task start their life in a suspended state
}


func deserializeJsonUsers(data: Data)->[User]{
    var users = [User]()
    do{
        let json = try JSONSerialization.jsonObject(with: data, options: []) as! Json
        let rows = json["rows"]! as! [Json]
        for row in rows{
            let email = row["email"] as? String ?? ""
            let password = row["password"] as? String ?? ""
            let id = row["id"] as! Int
            print(rows)
            users.append(User(email: email, password: password, id: id))
        }
    }
    catch let err{
        print(err)
    }
    return users
}


func addUsers(password:String, name: String, callback: @escaping (Int)->Void){
    // https://nechama.herokuapp.com/users/add?email=eli@gmail.com&password=eli1
    
    let url = URL(string: "\(apiAddress)/users/add?email=\(name)&password=\(password)")!
    print(url.absoluteURL)
    
    let task = session.dataTask(with: url) { (data, res, err) in
        if let err = err{
            print(err)
        } else{
            //else use the data binary = DATA
            guard let data  = data else {return}
            //   let s = String(data: data, encoding: String.Encoding.ascii)
            //convert binary to Dict<String, Any>
            do {
            var id = 0
            let json = try JSONSerialization.jsonObject(with: data, options: []) as! Json
            
                if let rows  = json["rows"] as? [Json] {
                    if rows.count > 0 {
                        let row = rows[0]
                        id = row["max"] as! Int
                    }
                }
            
                DispatchQueue.main.async {
                callback(id)
            }
            } catch {
            print("json error: \(error.localizedDescription)")
            }
            //מחזיר את הקוד של המשתמש שנרשם אחרון ואיתו אני בודקת בתנאי
            
        }
    }
    task.resume() //task start their life in a suspended state
}


func checkUsers(password:String, name: String, callback: @escaping (Int)->Void){
   // https://nechama.herokuapp.com/users/getuserid?email=eli@gmail.com&password=eli1
    
    let url = URL(string: "\(apiAddress)/users/getuserid?email=\(name)&password=\(password)")!
    print(url.absoluteURL)
    
    let task = session.dataTask(with: url) { (data, res, err) in
        if let err = err{
            print(err)
        } else{
            //else use the data binary = DATA
            guard let data  = data else {return}
            //   let s = String(data: data, encoding: String.Encoding.ascii)
            
            //convert binary to Dict<String, Any>
            do {
            var id = 0
            let json = try JSONSerialization.jsonObject(with: data, options: []) as! Json
            
                if let rows  = json["rows"] as? [Json] {
                    if rows.count > 0 {
                        let row = rows[0]
                        id = row["id"] as! Int
                    }
                }
            
           
            
                DispatchQueue.main.async {
                    callback(id)
                }
            } catch {
                print("json error: \(error.localizedDescription)")
            }
            //מחזיר את הקוד של המשתמש שנרשם אחרון ואיתו אני בודקת בתנאי
            
        }
    }
    task.resume() //task start their life in a suspended state
}




