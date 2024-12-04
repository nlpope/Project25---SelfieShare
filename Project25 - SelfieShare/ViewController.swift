//
//  ViewController.swift
//  Project25 - SelfieShare
//
//  Created by Noah Pope on 12/3/24.
//

import UIKit

class ViewController: UICollectionViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate
{
    
    var images  = [UIImage]()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupNavigation()
    }
    
    
    private func setupNavigation()
    {
        title                               = "Selfie Share"
        navigationItem.rightBarButtonItem   = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(importPicture))
    }


    @objc func importPicture()
    {
        
    }
}

