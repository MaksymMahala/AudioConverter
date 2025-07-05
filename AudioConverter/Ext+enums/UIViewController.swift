//
//  UIViewController.swift
//  AudioConverter
//
//  Created by Max on 05.07.2025.
//

import UIKit

extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController()
        } else if let nav = self as? UINavigationController {
            return nav.visibleViewController?.topMostViewController() ?? nav
        } else if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        } else {
            return self
        }
    }
}
