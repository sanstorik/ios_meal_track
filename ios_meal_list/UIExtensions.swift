import UIKit


extension UITextField {
    func defaultInitilization(hint: String, color: UIColor = UIColor.black, bgColor: UIColor? = nil) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.textColor = color
        let placeholder = NSAttributedString(string: hint,
                                             attributes: [NSAttributedStringKey.foregroundColor : color])
        
        self.attributedPlaceholder = placeholder
        self.textAlignment = .center
        self.backgroundColor = bgColor
    }
    
    
    func scaleFont(scale: CGFloat = 0.035, view: UIView) {
        font = font?.withSize(scale * view.frame.height)
    }
}


extension UILabel {
    func scaleFont(scale: CGFloat = 0.035, view: UIView) {
        font = font?.withSize(scale * view.frame.height)
    }
}


extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
}
