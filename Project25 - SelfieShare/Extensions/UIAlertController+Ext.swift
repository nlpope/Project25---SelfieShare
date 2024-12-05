//
//  AlertController+Ext.swift
//  Project25 - SelfieShare
//
//  Created by Noah Pope on 12/5/24.
//

import UIKit

extension UIAlertController
{
    func addActions(_ actions:[UIAlertAction]) { for action in actions { self.addAction(action) } }
}
