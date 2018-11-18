//
//  ProductInListController.swift
//  MyHomeProject
//
//

import UIKit

class ProductInListController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddProductDelegate, UpdateAmountDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var filterButton: UIButton!
    
    @IBOutlet weak var plusButton: UIButton!
    
    
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    @IBOutlet weak var toastMessage: UILabel!
    
    var shoppingListID: Int!
    var shopingListName: String = String()
    
    var productLists:[ProductInListObject] = [ProductInListObject]()
    var filteredProductList:[ProductInListObject] = [ProductInListObject]()

    var state: ControllerState!
    var addProductController : AddProductViewController!
    
    var productList: [ProductList] = [ProductList]()
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        state = ControllerState.Regular
        loadProductListsFromDB()
        print("shoppingListID = \(shoppingListID)")
        self.navigationItem.title = self.shopingListName
        self.toastMessage.alpha = 0
    }
    
    func loadProductListsFromDB(){
        
        self.tableView.addSubview(refreshControl)
        refreshControl.beginRefreshing()
        if self.shoppingListID != nil {
        getAPIProductLists(listId: shoppingListID) { (res) in
            self.productList = res.rows
            self.fillProductInListObjectList()
        }
            refreshControl.endRefreshing()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.state == ControllerState.isFiltered {
            return self.filteredProductList.count
        }
        return productLists.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! ProductInListCell
        if self.state == ControllerState.isFiltered {
         let product = filteredProductList[indexPath.row]
            cell.product = product
            cell.setProductToCell()
            cell.checkBoxButton.addTarget(self, action: #selector(self.checkBoxButtonTapped(_:)), for: .touchUpInside)
            cell.checkBoxButton.tag = indexPath.row
            cell.valueDelegate = self
        } else {
        let product = productLists[indexPath.row]
            cell.product = product
            cell.setProductToCell()
            cell.checkBoxButton.addTarget(self, action: #selector(self.checkBoxButtonTapped(_:)), for: .touchUpInside)
            cell.checkBoxButton.tag = indexPath.row
            cell.valueDelegate = self
        }
        
        return cell
    }
    
    @objc func checkBoxButtonTapped(_ sender: CheckBox) {
        var product = ProductInListObject()
        if self.state == ControllerState.isFiltered {
             product = self.filteredProductList[sender.tag]
        self.filteredProductList.remove(object: product)
            if let index = self.productLists.index(of: product){
                self.productLists[index].buy = true}
        self.tableView.reloadData()
        } else {
           product = self.productLists[sender.tag]
           self.productLists[sender.tag].buy = sender.isChecked
        }
        
        self.updateProduct(product: product)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let currentWidth = Float(screenWidth)
        let rowHeight = currentWidth/375 * 60
        let roundedHeight = rowHeight.rounded()
        return CGFloat(roundedHeight)
    }
    
    // MARK: Delete rows
    
    func tableView(_ tableView: UITableView, commit editingStyle:UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let product = self.productLists[indexPath.row]
            self.deleteProductFromList(productID: product.productID, listID: product.listID)
            self.productLists.remove(at: indexPath.row)
            ProductInListObjectList.list.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            
        }
        
    }
    
    func deleteProductFromList(productID: Int, listID: Int) {
        deleteProductFromListInServer(productId: productID, listId: listID) { (res) in
            print("res \(res)")
        }
    }
    
    func updateProduct(product: ProductInListObject) {
        let amount = Int(product.amount);
        if(amount == nil) {
            toastErrorMessage(message: "לא מספר");
        }
        else {
            if(amount! < 0) {
                toastErrorMessage(message: "מספר שלילי");
            }
            else {
                updateProductFromListInServer(productId: product.productID, listId: product.listID, amount: product.amount, buy: product.buy) { (res) in
                    print("res \(res)")
                }
            }
        }
    }
    
    
    @IBAction func editAction(_ sender: UIBarButtonItem) {
        
        if state == ControllerState.Regular {
            self.navigationItem.leftBarButtonItem?.isEnabled = false
            self.plusButton.isEnabled = false
            self.filterButton.isEnabled = false
            self.tableView.isEditing = true
            state = ControllerState.IsEditing
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "אשר", style: UIBarButtonItemStyle.plain, target: self, action: #selector(editAction))
        } else {
            
            self.tableView.isEditing = false
            self.filterButton.isEnabled = true
            self.plusButton.isEnabled = true
            self.navigationItem.leftBarButtonItem?.isEnabled = true
            state = ControllerState.Regular
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "מחק", style: UIBarButtonItemStyle.plain, target: self, action: #selector(editAction))
        }
        
        self.tableView.reloadData()
        
    }
    
    @IBAction func addProductToListAction(_ sender: UIButton) {
        self.addProductController = AddProductViewController.init(nibName: "AddProductViewController", bundle: nil)
        addProductController.valueDelegate = self
        self.addProductController.showInView(self.view, animated: true)
        
    }
    
    func productAddingSuccsefull(result: String) {
        let resultStd = result.lowercased()
        var name = String()
        var details = String()
        let splits = resultStd.split(separator: " ", maxSplits: 1)
        if splits.count == 2 {
            name = String(splits[0])
            details = String(splits[1])
            print("details = \(details)")
            if self.checkIsProductInList(name: name, details: details) {return}
        } else {
            name = result
            details = " "
            if self.checkIsProductInList(name: name, details: details) {return}
        }

        let product = ProductInListObject()
        product.name = name
        product.details = details
        product.listID = self.shoppingListID
        addProductLists(name: name, details: details, listID: self.shoppingListID, amount: product.amount, buy: false) { (id) in
            if id == 0 {return}
           product.productID = id
        }
        self.addToArray(product: product)
    }
    
    @IBAction func filteredAction(_ sender: UIButton) {
        
        if state == ControllerState.Regular {
            self.getFilteredArray()
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            self.plusButton.isEnabled = false
            state = ControllerState.isFiltered
            self.filterButton.setTitle("לרשימה מליאה", for: UIControlState.normal)
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            self.plusButton.isEnabled = true
            state = ControllerState.Regular
            self.filterButton.setTitle("רשימת קנייה", for: UIControlState.normal)
            
        }
        
        self.tableView.reloadData()
    }
    
    func getFilteredArray() {
        filteredProductList = [ProductInListObject]()
        for product in self.productLists {
            if product.buy == false {
                self.filteredProductList.append(product)
            }
        }
    }
    
    func fillProductInListObjectList() {
        ProductInListObjectList.list = Array<ProductInListObject>()
        for productsList in self.productList {
            
            getProductForID(productId: productsList.productID) { (res) in
                let product = res.rows[0]
                let productInListObject: ProductInListObject = ProductInListObject()
                productInListObject.name = product.name
                productInListObject.details = product.details
                productInListObject.id = productsList.id
                productInListObject.productID = productsList.productID
                productInListObject.listID = productsList.listID
                productInListObject.amount = productsList.amount
                productInListObject.buy = productsList.buy
                self.addToArray(product: productInListObject)
            }
            
        }
        
        
    }
    
    func addToArray(product: ProductInListObject) {
        ProductInListObjectList.list.append(product)
        self.productLists = ProductInListObjectList.list
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func amountUpdatedSuccsefull(product: ProductInListObject) {
        print("product.amount = \(product.amount)")
        self.updateProduct(product: product)
        if let index = self.productLists.index(of: product){
            self.productLists[index].amount = product.amount}
        if let index = self.filteredProductList.index(of: product){
            self.filteredProductList[index].amount = product.amount}
        if let index = ProductInListObjectList.list.index(of: product){
            ProductInListObjectList.list[index].amount = product.amount}
    }
    
    func checkIsProductInList(name: String, details: String) -> Bool {
        for product in self.productLists {
            if (product.name == name)&&(product.details == details) {
                return true
            }
        }
        return false
    }
    
    func toastErrorMessage(message: String) {
        self.toastMessage.text = message
        
        UIView.animate(withDuration: 3, animations: {
            self.toastMessage.alpha = 1 ;
        }, completion:{(finished : Bool)  in
            if (finished)
            {
                UIView.animate(withDuration: 3, animations: {
                    self.toastMessage.alpha = 0 ;
                }, completion:{(finished : Bool)  in
                    if (finished)
                    {
                        
                    }
                });
            }
        });
    }
}

public var screenWidth: CGFloat {
    return UIScreen.main.bounds.width
}

extension Array where Element: Equatable {
    
    @discardableResult mutating func remove(object: Element) -> Bool {
        if let index = index(of: object) {
            self.remove(at: index)
            return true
        }
        return false
}
    
    @discardableResult mutating func getIndex(object: Element) -> Int {
        if let index = index(of: object) {
            
            return index
        }
        return 0
    }
}
