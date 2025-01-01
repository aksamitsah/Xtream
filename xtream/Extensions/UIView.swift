//
//  UIView + gasture.swift
//  xtream
//
//  Created by Amit Shah on 20/12/24.
//

import UIKit

extension UIView {
    
    func addTapGesture(action: @escaping () -> Void) {
        
        let tap = MyTapGestureRecognizer(target: self, action: #selector(self.handleTaps(_:)))
        tap.action = action
        tap.numberOfTapsRequired = 1
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
        
    }
    
    @objc func handleTaps(_ sender: MyTapGestureRecognizer) {
        sender.action?()
    }
    
}

class MyTapGestureRecognizer: UITapGestureRecognizer {
    var action: (() -> Void)?
}
