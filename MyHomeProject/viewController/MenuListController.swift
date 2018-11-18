//
//  MenuListControllerViewController.swift
//  MyHomeProject
//
//

import UIKit
import Onboard

class MenuListController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var state: ControllerState!
    
    var lists:[List] = [List]()
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var plusButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let u = defaults.string(forKey: "user") else{
            performSegue(withIdentifier: "loginSegue", sender: nil)
            return
        }
        
        defaults.register(defaults: ["should_show_intro" : true])
        
        userNameLabel.text = "שלום \(u)"
        self.loadListsFromDB()
        
        if(defaults.bool(forKey: "should_show_intro")) {
            showIntro()
            defaults.set(false, forKey: "should_show_intro")
        }
    }
    
    @IBAction func addList(_ sender: MyButton) {
        
        
        let alert = UIAlertController(title: "הוספת רשימה", message: "הוסף את הרשימה הנדרשת" , preferredStyle: .alert)
        
        alert.addTextField { (tf) in
            tf.placeholder = "הרשימה..."
        }
        
        let ok = UIAlertAction(title: "הוסף", style: .default) { (action) in
            
            //להוסיף קוד שמוסיף את המוצר לדטה בייס של המוצרים וכן של המוצרים ברשימה
            //let userId = self.defaults.string(forKey: "idFromDb")!
            let name = alert.textFields![0].text ?? ""
            guard let userId = UserDefaults.standard.string(forKey: "idFromDb") else {
                print("Error No Id...")
                return}
            
            if(name.isEmpty) {
                return;
            }
            
                addLists(userID: userId, name: name) { (id) in
                      guard  let uid = Int(userId) else {return}
                //print(id)  //קוד הרשימה
                    if id == 0 {return}
                    let list = List(name: name, userID: uid, id: id)
                    //print("list.id = \(list.id)")
                //tell the table view to reload the data
                
                
                    self.lists.append(list)
                    self.tableView.reloadData()
    
            }
        }
        
        let back = UIAlertAction(title: "חזרה", style: .default) { (action) in
            alert.removeFromParentViewController()
        }
        
        alert.addAction(ok)
        alert.addAction(back)
        present(alert, animated: true, completion: nil)
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return lists.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! ListsCell
        
        let list = lists[indexPath.row]
        cell.listLabel.text = list.name
        
        let image = UIImage(named: "disclosure.png")
        let disclosure  = UIImageView(frame:CGRect(x:0, y:0, width:(image?.size.width)!, height:(image?.size.height)!));
        disclosure.image = image
        cell.accessoryView = disclosure
        
        return cell
    }
    
    // MARK: Delete rows
    
     func tableView(_ tableView: UITableView, commit editingStyle:UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let list = self.lists[indexPath.row]
            self.deleteList(listID: list.id)
            self.lists.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            
        }
        
    }
    
    @IBAction func editAction(_ sender: UIBarButtonItem) {
        
        if state == ControllerState.Regular {
            self.navigationItem.leftBarButtonItem?.isEnabled = false
            self.plusButton.isEnabled = false
            self.tableView.isEditing = true
            state = ControllerState.IsEditing
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "אשר", style: UIBarButtonItemStyle.plain, target: self, action: #selector(editAction))
        } else {
            
            self.tableView.isEditing = false
            self.plusButton.isEnabled = true
            self.navigationItem.leftBarButtonItem?.isEnabled = true
            state = ControllerState.Regular
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "מחק", style: UIBarButtonItemStyle.plain, target: self, action: #selector(editAction))
        }
        
        self.tableView.reloadData()
        
    }
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        
        
    defaults.set(nil, forKey: "user")
        
      performSegue(withIdentifier: "loginSegue", sender: nil)
         
    }
    
    func loadListsFromDB(){
        
        let refreshControl = UIRefreshControl()
        self.tableView.addSubview(refreshControl)
        refreshControl.beginRefreshing()
        
        getAPILists { (res) in
            self.lists = res.rows
            self.tableView.reloadData()
        }
        
        refreshControl.endRefreshing()
        
    }
    
    func deleteList(listID: Int) {
            deleteListFromDB(listId: listID) { (res) in
                print("res \(res)")
            }
    }
    
    @IBOutlet weak var userNameLabel: UILabel!

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let cell: ListsCell = sender as? ListsCell {
            let indexPath = self.tableView.indexPath(for: cell)
            if let index = indexPath?.row {
                let list = lists[index]
                let productsController: ProductInListController = segue.destination as! ProductInListController
                productsController.shoppingListID = list.id
                productsController.shopingListName = list.name
                
            }
        }
        
    }
 
    func showIntro() {
        let body = "האפליקציה מאפשרת יצירת מס׳ רב של רשימות למשתמש לצורך ייעול ההתארגנות של הקניות בבית."
        
        let firstPage = OnboardingContentViewController(title: "MyHomeProject", body: body, image: UIImage(named: "firstpage"), buttonText: "") { () -> Void in
        }
        
        let body2 = "כדי להוסיף רשימה חדשה – יש לבחור בלחצן + ואז להקליד את שם הרשימה המבוקשת.\nכדי למחוק רשימה מתוך הרשימות הקיימות – יש לבחור בלחצן מחק (צד ימין למעלה) ולמחוק את הרשימה ע״י בחירה באפשרות delete"
        let secondPage = OnboardingContentViewController(title: nil, body: body2, image: UIImage(named: "homepage"), buttonText: "") { () -> Void in
        }
        
        let body3 = "כדי להוסיף מוצר נוסף לרשימה – יש לבחור בלחצן + ואז להקליד את שם המוצר המבוקש – במידה והמוצר קיים במאגר ניתן לבחור אותו מתוך הרשימה.\nניצן לסמן בכל מוצר אם נרכש או לא."

        let thirdPage = OnboardingContentViewController(title: nil, body: body3, image: UIImage(named: "thirdpage"), buttonText: "Done") { () -> Void in
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                
                topController.dismiss(animated: true, completion: nil)
            }
        }
        
        let onboardingVC = OnboardingViewController(backgroundImage: nil, contents: [firstPage, secondPage, thirdPage])
        onboardingVC?.view.backgroundColor = UIColor.white
        self.present(onboardingVC!, animated: true, completion: nil)
    }
    @IBAction func onIntroButtonClicked(_ sender: Any) {
        showIntro()
    }
}

enum ControllerState {
    case IsEditing
    case Regular
    case Deleted
    case Added
    case isFiltered
}
