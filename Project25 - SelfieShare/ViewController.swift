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
        navigationItem.leftBarButtonItem    = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showConnectionPrompt))
    }


    @objc func importPicture()
    {
        let picker              = UIImagePickerController()
        picker.allowsEditing    = true
        picker.delegate         = self
        present(picker, animated: true)
    }
    
    
    @objc func showConnectionPrompt()
    {
        let ac      = UIAlertController(title: "Connect to others", message: nil, preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Host a session", style: .default, handler: startHosting)
        let action2 = UIAlertAction(title: "Join a session", style: .default, handler: joinSession)
        let action3 = UIAlertAction(title: "Cancel", style: .cancel)
        
        ac.addActions([action1, action2, action3])
        present(ac, animated: true)
    }
    
    
    func startHosting(_ : UIAlertAction)
    {
        
    }
    
    
    func joinSession(_ : UIAlertAction)
    {
        
    }
}


// MARK: COLLECTIONVIEW DELEGATE METHODS
extension ViewController
{
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return images.count }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell            = collectionView.dequeueReusableCell(withReuseIdentifier: ReuseIdentifiers.ImageView, for: indexPath)
        
        if let imageView    = cell.viewWithTag(1000) as? UIImageView { imageView.image = images[indexPath.item] }
        
        return cell
    }
}


// MARK: IMAGE PICKER DELEGATE METHODS
extension ViewController
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        guard let image = info[.editedImage] as? UIImage else { return }
        dismiss(animated: true)
        images.insert(image, at: 0)
        collectionView.reloadData()
    }
}

