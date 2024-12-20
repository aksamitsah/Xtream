//
//  UICollectionViewCell.swift
//  xtream
//
//  Created by Amit Shah on 19/12/24.
//

import UIKit.UICollectionViewCell

extension UICollectionViewCell {
    static var reuseIdentifier: String {
        String(describing: self)
    }
}
