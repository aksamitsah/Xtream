//
//  UICollectionView.swift
//  xtream
//
//  Created by Amit Shah on 19/12/24.
//

import UIKit.UICollectionView

extension ReusableView {
    
    static var defaultReuseIdentifier: String {
        return String(describing: self)
    }
    
}

extension UICollectionView {
    
    func registerFromXib(name: String) {
        register(UINib(nibName: name, bundle: nil), forCellWithReuseIdentifier: name)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T where T: ReusableView {
        
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
        }
        return cell
        
    }
    
}
