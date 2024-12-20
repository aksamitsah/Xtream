//
//  UIView.swift
//  xtream
//
//  Created by Amit Shah on 20/12/24.
//

import UIKit.UIView


class CustomUIView: UIView {
    
    // Round corner radius
    @IBInspectable var cornerRadiusRound: Bool {
        get {
            return layer.cornerRadius > 0
        }
        set {
            if newValue {
                layer.cornerRadius = min(bounds.width, bounds.height) / 2.0
            } else {
                layer.cornerRadius = 0
            }
            layer.masksToBounds = newValue
        }
    }
    
    // Corner radius
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    // Border width
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    // Border color
    @IBInspectable var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}
