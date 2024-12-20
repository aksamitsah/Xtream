//
//  UITableView.swift
//  xtream
//
//  Created by Amit Shah on 20/12/24.
//

import UIKit.UITableView

extension UITableView {
    
    func registerFromXib(name: String) {
        register(UINib(nibName: name, bundle: nil), forCellReuseIdentifier: name)
    }
    
}
