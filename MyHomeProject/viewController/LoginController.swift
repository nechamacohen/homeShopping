//
//  LoginController.swift
//  MyHomeProject
//
//

import UIKit

class LoginController: UIViewController {

    @IBOutlet weak var userNameTextField: MyTextField!
    @IBOutlet weak var passwordTextField: MyTextField!
    @IBOutlet weak var login: MyButton!
    var users:[User] = []
    
    
    @IBOutlet weak var faulLabel: UILabel!
    
    
    
    @IBAction func btnLogin(_ sender: MyButton) {
        
        if (!(userNameTextField.text?.isEmpty)!)&&(!(passwordTextField.text?.isEmpty)!) {
            self.checkUser(username: userNameTextField.text!, password: passwordTextField.text!)
        }
        
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        login.layer.cornerRadius = 12
        login.clipsToBounds = true
        userNameTextField.leftView = UIImageView(image:#imageLiteral(resourceName: "icons8-user_filled"))
        userNameTextField.leftViewMode = .always
        passwordTextField.leftView = UIImageView(image:#imageLiteral(resourceName: "icons8-password"))
        passwordTextField.leftViewMode = .always
        self.faulLabel.alpha = 0
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        
        dismiss(animated: true, completion: nil)
    }
    
    func saveUserInDisck(password: String, name: String, userId: String) {
        
            self.saveVariableForKey(mvar: name, mkey: "user")
            self.saveVariableForKey(mvar: password, mkey: "pass")
            self.saveVariableForKey(mvar: userId, mkey: "idFromDb")
    }
    
    
    func saveVariableForKey(mvar: String, mkey: String) {
        
        let defaults = UserDefaults.standard
        defaults.set(mvar, forKey: mkey)
        defaults.synchronize()
        
    }
    
    func checkUser(username: String, password: String){
        
            checkUsers(password: password, name: username) { (id) in
                print("id =\(id)")
                if id == 0 {
                    self.animateFaul()
                    return
                }
                
                self.saveUserInDisck(password: password, name: username, userId: String(id))
                self.performSegue(withIdentifier: "StartSegue", sender: nil)
            }
        }
    
    func animateFaul(){
        
        UIView.animate(withDuration: 3, animations: {
            self.faulLabel.alpha = 1 ;
        }, completion:{(finished : Bool)  in
            if (finished)
            {
                UIView.animate(withDuration: 3, animations: {
                    self.faulLabel.alpha = 0 ;
                }, completion:{(finished : Bool)  in
                    if (finished)
                    {
                        
                    }
                });
            }
        });
        
        
    }
    

}
