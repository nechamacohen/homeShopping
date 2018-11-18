//
//  ProductInListCell.swift
//  MyHomeProject
//
//

import UIKit

class ProductInListCell: UITableViewCell, UITextFieldDelegate {


    @IBOutlet weak var nameProductLabel: UILabel!
    
    @IBOutlet weak var amountTextField: UITextField!
    
    @IBOutlet weak var checkBoxButton: CheckBox!
    
    var checkBox = UIControlState.normal
    
    var product: ProductInListObject = ProductInListObject()
    
    var valueDelegate: UpdateAmountDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUIDimensionsForScreenWidth()
        self.setDoneCancelBar()
        self.amountTextField.delegate = self
    }

    func setUIDimensionsForScreenWidth() {
        let currentWidth = Float(screenWidth)
        let k = currentWidth/375
        let fontHeight = k * 17
        let roundedFontHeight = fontHeight.rounded()
        let fontHeightL = k * 20
        let roundedFontHeightL = fontHeightL.rounded()
        self.nameProductLabel.frame = CGRect(x: Double(k * 78), y: Double(k * 15), width: Double(k * 218), height: Double(k * 30))
        self.amountTextField.frame = CGRect(x: Double(k * 8), y: Double(15 * k), width: Double(62 * k), height: Double(30 * k))
        self.checkBoxButton.frame = CGRect(x: Double(k * 320), y: Double(k * 4), width: Double(k * 40), height: Double(k * 40))
        self.nameProductLabel.font = self.nameProductLabel.font.withSize(CGFloat(roundedFontHeight))
        self.amountTextField.font = self.amountTextField.font?.withSize(CGFloat(roundedFontHeightL))
    }
    
    func setProductToCell() {
        self.nameProductLabel.text = "\(self.product.name) \(self.product.details)"
        self.amountTextField.text = self.product.amount
        self.checkBoxButton.isChecked = self.product.buy
    }
    
    func setDoneCancelBar() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(doneClicked))
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(cancelClicked))
        toolBar.setItems([cancelButton, flexibleSpace, doneButton], animated: false)
        
        self.amountTextField.inputAccessoryView = toolBar
        
    }
    
    @objc func doneClicked() {
        self.contentView.endEditing(true)
        if (self.amountTextField.text?.isEmpty)! {
            self.amountTextField.text = self.product.amount
        }
        else {
            self.product.amount = self.amountTextField.text!
            valueDelegate!.amountUpdatedSuccsefull(product: self.product)
            let amount = Int(product.amount);
            if(amount == nil || amount! < 0) {
                self.amountTextField.text = "0";
            }
        }
    }
    
    @objc func cancelClicked() {
        self.contentView.endEditing(true)
        self.amountTextField.text = self.product.amount
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        textField.text = ""
        self.amountTextField = textField
    
    }
   

}










class CheckBox: UIButton {
    // Images
    let checked = UIImage(named: "checkmarkon.png")! as UIImage
    let unchecked = UIImage(named: "checkmarkoff.png")! as UIImage
    
    // Bool property
    var isChecked: Bool = false {
        didSet{
            if isChecked == true {
                self.setBackgroundImage(checked, for: UIControlState.normal)
                //self.setImage(checked, for: UIControlState.normal)
            } else {
                self.setBackgroundImage(unchecked, for: UIControlState.normal)
            }
        }
    }
    
    override func awakeFromNib() {
        self.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.isChecked = false
    }
    
    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
        }
    }
    
    
    
   
    
}

protocol UpdateAmountDelegate : NSObjectProtocol {
    
    func amountUpdatedSuccsefull(product: ProductInListObject)
    
}

