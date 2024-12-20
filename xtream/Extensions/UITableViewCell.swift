//
//  UITableViewCell.swift
//  xtream
//
//  Created by Amit Shah on 20/12/24.
//

import UIKit.UITableViewCell

extension UITableViewCell {
    
    static var reuseIdentifier: String {
        String(describing: self)
    }
    
}
