//
//  RegisterController.swift
//  MyHomeProject
//
//

import UIKit



class RegisterController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var registerButton: UIButton!
    
    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    var users:[User] = []
    
    @IBOutlet weak var succsefullLabel: UILabel!
    
    
    
    var isDialogOpen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerButton.layer.cornerRadius = 12
        registerButton.clipsToBounds = true
        userNameTextField.leftView = UIImageView(image:#imageLiteral(resourceName: "icons8-user_filled"))
        userNameTextField.leftViewMode = .always
        passwordTextField.leftView = UIImageView(image:#imageLiteral(resourceName: "icons8-password"))
        passwordTextField.leftViewMode = .always
        registerButton.isUserInteractionEnabled = false
        userNameTextField.delegate = self
        passwordTextField.delegate = self
        
        self.succsefullLabel.alpha = 0
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        
        dismiss(animated: true, completion: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (!(userNameTextField.text?.isEmpty)!)&&((passwordTextField.text?.count)! > 2){
         registerButton.isUserInteractionEnabled = true
        }
        return true
    }
    
    
    @IBAction func register(_ sender: UIButton) {
        
        
 //שמירת משתמש מקומית

        //animateRegister()
        
        //שמירת משתמש לדטה בייס
        let email = userNameTextField.text ?? ""
        let pass = passwordTextField.text ?? ""
        addUsers(password: pass, name: email) { (id) in
            if id != 0 {
                self.saveUserInDisck(password: pass, name: email, id: id)} else {
               self.animateTryAgain()
            }
            //לבדוק את המשתמש הזה כדי שיציג את הרשימה הרלוונטית לרשימה הספציפית
        }
    
        
        
    }

    func saveUserInDisck(password: String, name: String, id: Int) {
        if !(userNameTextField.text?.isEmpty)! {
            self.saveVariableForKey(mvar: userNameTextField.text!, mkey: "user")}
        if !(passwordTextField.text?.isEmpty)! {
            self.saveVariableForKey(mvar: passwordTextField.text!, mkey: "pass")}
        self.saveVariableForKey(mvar: String(id), mkey: "idFromDb")
        self.animateRegister()
    }
    
    
     func saveVariableForKey(mvar: String, mkey: String) {
        
        let defaults = UserDefaults.standard
        defaults.set(mvar, forKey: mkey)
        defaults.synchronize()
        
    }
    
    func animateRegister(){
        self.succsefullLabel.text = "משתמש נרשם בהצלחה"
        UIView.animate(withDuration: 2, animations: {
            self.succsefullLabel.alpha = 1 ;
        }, completion:{(finished : Bool)  in
            if (finished)
            {
            self.performSegue(withIdentifier: "registerSegue", sender: nil)
            }
        });
        
        
    }
    
    func animateTryAgain(){
        self.succsefullLabel.text = "משתמש קיים. נסה שנית."
        UIView.animate(withDuration: 3, animations: {
            self.succsefullLabel.alpha = 1 ;
        }, completion:{(finished : Bool)  in
            if (finished)
            {
                UIView.animate(withDuration: 3, animations: {
                    self.succsefullLabel.alpha = 0 ;
                }, completion:{(finished : Bool)  in
                    if (finished)
                    {
                        
                    }
                });
            }
        });
        
        
    }
    

}
