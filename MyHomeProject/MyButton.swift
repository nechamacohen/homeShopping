//
//  MyButton.swift
//  MyHomeProject
//
//

import UIKit

@IBDesignable

class MyButton: UIButton {
    
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
    
    @IBInspectable
    var padding: CGFloat = 8{
        didSet{
            let p = padding
            titleEdgeInsets = UIEdgeInsets(top: p, left: p, bottom: p, right: p)
        }
    }
    
    override var intrinsicContentSize: CGSize{
        let sz = super.intrinsicContentSize
        let newSize = CGSize(width: sz.width + padding * 2, height: sz.height + padding * 2)
        return newSize
    }
    
//    override init(frame: CGRect) {
//        // frame: CGRect
//        super.init(frame: frame)
//        castomize()
//        
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        castomize()
//    }
//    
//    func castomize(){
//        setTitle("FaceBook", for: .normal)
//        layer.cornerRadius = 10
//        layer.borderWidth = 2
//        layer.borderColor = UIColor.cyan.cgColor
//        
//        clipsToBounds = true
//    }
    
    
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
