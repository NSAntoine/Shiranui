//
//  Extensions.swift
//  Shiranui
//
//  Created by Serena on 01/12/2023.
//  

import UIKit

extension UIViewController {
    func animateViewsFading(views: [UIView], duration: TimeInterval = 0.25, hide: Bool, completion: (() -> Void)?) {
        UIView.animate(withDuration: duration) {
            let alpha: CGFloat = hide ? 0 : 1
            for view in views {
                view.alpha = alpha
            }
        } completion: { _ in
            for view in views {
                view.isHidden = hide
            }
            
            completion?()
        }
    }
}

extension NSNotification.Name {
    static let userScannedAlbumsDidChange = NSNotification.Name("userScannedAlbumsDidChange")
}
