//
//  UITextField + CustomTextFiled.swift
//  xtream
//
//  Created by Amit Shah on 20/12/24.
//

import UIKit

@IBDesignable
class CustomTextField: UITextField {

    // Placeholder text color
    @IBInspectable var hintTextColor: UIColor? {
        didSet {
            guard let placeholder = placeholder else { return }
            attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [NSAttributedString.Key.foregroundColor: hintTextColor ?? .lightGray]
            )
        }
    }

    // Corner radius for rounded corners
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }

    // Border color for the text field
    @IBInspectable var borderColor: UIColor? {
        get {
            guard let cgColor = layer.borderColor else { return nil }
            return UIColor(cgColor: cgColor)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }

    // Border width for the text field
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
}
