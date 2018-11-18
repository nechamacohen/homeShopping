//
//  MyTextField.swift
//  MyHomeProject
//
//

import UIKit

@IBDesignable

class MyTextField: UITextField {

    
    @IBInspectable
    var cornerRadius: CGFloat = 10{
        didSet{
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable
    var bg: UIColor = UIColor.blue{
        didSet{
            backgroundColor = bg
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat = 10{
        didSet{
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable
    var borderColor: UIColor = UIColor.cyan{
        didSet{
            layer.borderColor = borderColor.cgColor  //convert from UIcolor => cgColor
        }
    }
    
//    @IBInspectable
//    var padding: CGFloat = 8{
//        didSet{
//            let p = padding
//            titleEdgeInsets = UIEdgeInsets(top: p, left: p, bottom: p, right: p)
//        }
//    }
    
//    override var intrinsicContentSize: CGSize{
//        let sz = super.intrinsicContentSize
//        let newSize = CGSize(width: sz.width + padding * 2, height: sz.height + padding * 2)
//        return newSize
//    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
