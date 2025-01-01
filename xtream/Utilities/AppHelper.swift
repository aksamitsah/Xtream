//
//  AppHelper.swift
//  xtream
//
//  Created by Amit Shah on 20/12/24.
//

import UIKit

final class AppHelper {
    
    private init() { }
    static let shared = AppHelper()
    
    func showProgressIndicator(view views: UIView?) {
        guard let view = views else { return }
        DispatchQueue.main.async {
            let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
            let backView: UIView = UIView()
            backView.frame = view.bounds
            backView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.25)
            backView.tag = 700
            actInd.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
            actInd.backgroundColor = .systemBackground
            actInd.color = .accent
            actInd.layer.cornerRadius = 16
            actInd.center = backView.center
            
            actInd.hidesWhenStopped = true
            actInd.style = .large
            backView.addSubview(actInd)
            view.addSubview(backView)
            actInd.startAnimating()
        }
    }
    
    func hideProgressIndicator(view views: UIView?) {
        guard let view = views else { return }
        DispatchQueue.main.async {
            for subviews in view.subviews where subviews.tag == 700 {
                if let indicatorView = subviews.subviews.first as? UIActivityIndicatorView {
                    indicatorView.stopAnimating()
                }
                subviews.removeFromSuperview()
            }
        }
    }
    
    func showAlert(title alertTitle: String, message: String, viewController: UIViewController?) {
        
        _ = NSAttributedString(string: alertTitle, attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18),
            NSAttributedString.Key.foregroundColor: UIColor.black
        ])
        
        _ = NSAttributedString(string: message, attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
            NSAttributedString.Key.foregroundColor: UIColor.black
        ])
        
        let alertView = UIAlertController(title: alertTitle, message: message, preferredStyle: .actionSheet)
        alertView.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        // Handle iPad-specific configuration for .actionSheet
        if let popoverController = alertView.popoverPresentationController {
            popoverController.sourceView = viewController?.view // Anchor to the main view
            popoverController.sourceRect = CGRect(x: (viewController?.view.bounds.midX ?? 0),
                                                  y: (viewController?.view.bounds.midY ?? 0),
                                                  width: 1,
                                                  height: 1) // Centered on the screen
            popoverController.permittedArrowDirections = [] // No arrow
        }
        
        viewController?.present(alertView, animated: true)
    }
}
