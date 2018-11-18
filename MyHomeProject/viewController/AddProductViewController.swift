//
//  AddProductViewController.swift
//  My Budget
//
//  
//

import UIKit

class AddProductViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var valueDelegate:AddProductDelegate? = nil
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var okButton: UIButton!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    var backView:UIView!
    
    var products: [Product] = [Product]()
    
    var productsString: [String] = [String]()
    var filteredProductsString: [String] = [String]()
    
    var state: ControllerState = ControllerState.Regular
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layer.cornerRadius = 20
        self.view.clipsToBounds = true
        
        self.cancelButton.clipsToBounds = true
        
        self.okButton.clipsToBounds = true
        
        self.getProductsFromDB()
        
        self.searchBar.delegate = self
        self.searchBar.returnKeyType = UIReturnKeyType.done
        
    }
    
    func showInView(_ aView: UIView!, animated: Bool)
    {
        backView = UIView(frame: aView.frame)
        backView!.backgroundColor = UIColor.black
        backView!.alpha = 0.3
        self.backView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AddProductViewController.cancelAction(_:)))
        self.backView.addGestureRecognizer(tapGesture)
        aView.addSubview(backView!)
        
        aView.addSubview(self.view)
        
        if animated
        {
            self.showAnimate()
        }
    }
    
    func showAnimate()
    {
        self.view.frame = CGRect(x: -300, y: 80, width: 300, height: 460)
        
        UIView.animate(withDuration: 0.8, delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations:{
            self.view.frame = CGRect(x: (self.backView.frame.width - 300)/2, y: 80, width: 300, height: 460)
        });
        
        
    }
    
    func removeAnimate()
    {
        
        self.dismiss(animated: true, completion: nil)
        UIView.animate(withDuration: 0.3, animations: {
            self.view.frame = CGRect(x: 320, y: self.view.frame.origin.y, width: 320, height: self.view.frame.height);
        }, completion:{(finished : Bool)  in
            if (finished)
            {
                self.backView!.removeFromSuperview()
                self.view.removeFromSuperview()
                
            }
        });
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.state == .isFiltered) {
            return self.filteredProductsString.count
        }
        return self.productsString.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init()
        if (self.state == .isFiltered) {
            cell.textLabel?.text = self.filteredProductsString[indexPath.row]
        } else {
            cell.textLabel?.text = self.productsString[indexPath.row]
            
        }
        
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            self.state = .Regular
            view.endEditing(true)
        } else {
            
            self.state = .isFiltered
            
            self.filteredProductsString = self.productsString.filter({ $0.starts(with: searchText.lowercased())})
        }
        
        self.productsString = sortList(list: self.productsString)
        tableView.reloadData()
    }
    
    func sortList(list: [String]) -> [String]{
        return list.sorted {
            let name1 = $0
            let name2 = $1
    
            return name1 < name2;
        }
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.state = .Regular
        self.searchBar.endEditing(true)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.state = .Regular
        self.searchBar.endEditing(true)
    }
    
    
    @IBAction func cancelAction(_ sender: UIButton) {
        self.removeAnimate()
    }
    
    @IBAction func addNewProductAction(_ sender: UIButton) {
        addNewProduct { (productName: String) in
       
            if(!productName.isEmpty) {
                self.valueDelegate!.productAddingSuccsefull(result: productName)
                self.removeAnimate()
            }

        }
    }
    
    func addNewProduct(completion: @escaping (_ productName: String) -> Void) {
        let alert = UIAlertController(title: "הוספת מוצר חדש", message: "הוסף את המוצר הנדרש" , preferredStyle: .alert)
        
        alert.addTextField { (tf) in
            tf.placeholder = "המוצר..."
        }
        
        let ok = UIAlertAction(title: "הוסף", style: .default) { (action) in
            
            //להוסיף קוד שמוסיף את המוצר לדטה בייס של המוצרים וכן של המוצרים ברשימה
            //let userId = self.defaults.string(forKey: "idFromDb")!
            let name = alert.textFields![0].text ?? ""
            
            completion(name)
        }
        
        let back = UIAlertAction(title: "חזרה", style: .default) { (action) in
            alert.removeFromParentViewController()
        }
        
        alert.addAction(ok)
        alert.addAction(back)
        present(alert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if let result = cell.textLabel?.text {
            valueDelegate!.productAddingSuccsefull(result: result)
            }
        }
        
        self.removeAnimate()
    }
    
    func getProductsFromDB(){
        
        let refreshControl = UIRefreshControl()
        self.tableView.addSubview(refreshControl)
        refreshControl.beginRefreshing()
        
        getProducts { (res) in
            self.products = res.rows
            self.fillStringsArray()
            refreshControl.endRefreshing()
        }
    }
    
    func fillStringsArray() {
        for product in self.products {
            let string = "\(product.name) \(product.details)"
            self.productsString.append(string)
        }
        
        self.productsString = sortList(list: self.productsString)
        
        self.tableView.reloadData()
    }
    
}

protocol AddProductDelegate : NSObjectProtocol {
    
    func productAddingSuccsefull(result: String)
    
}

