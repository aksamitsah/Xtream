//
//  UIlabel.swift
//  xtream
//
//  Created by Amit Shah on 20/12/24.
//

import UIKit

class CustomUILabel: UILabel {
    
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
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}
