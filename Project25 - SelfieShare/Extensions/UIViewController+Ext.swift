//
//  UIViewController+Ext.swift
//  Project25 - SelfieShare
//
//  Created by Noah Pope on 12/7/24.
//

import UIKit

extension UICollectionViewController
{
    func presentSSAlertOnMainThread(alertTitle: String, buttonTitle: String, error: Error?)
    {
        let ac = UIAlertController(title: alertTitle, message: error?.localizedDescription ?? "An unknown error occurred", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: buttonTitle, style: .default))
        self.present(ac, animated: true)
    }
}
