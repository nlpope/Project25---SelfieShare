//
//  HomeVC.swift
//  Project25 - SelfieShare
//
//  Created by Noah Pope on 12/3/24.
//  MCAdvertiser & Browser help: https://stackoverflow.com/questions/58563621/multipeer-connectivity-not-working-after-xcode-11-update

import UIKit
import MultipeerConnectivity

class HomeVC:   UICollectionViewController,
                UINavigationControllerDelegate,
                UIImagePickerControllerDelegate,
                MCSessionDelegate,
                MCBrowserViewControllerDelegate,
                MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate
{
    var images  = [UIImage]()
    var peerID  = MCPeerID(displayName: UIDevice.current.name)
    var mcSession: MCSession?
//    var mcAdvertiserAssistant: MCNearbyServiceAdvertiser?
    var mcAdvertiserAssistant: MCAdvertiserAssistant?

    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupNavigation()
        setupMultipeerConnectivity()
    }
    
    
    private func setupNavigation()
    {
        title                               = "Selfie Share"
        navigationItem.rightBarButtonItem   = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(importPicture))
        navigationItem.leftBarButtonItem    = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showConnectionPrompt))
    }
    
    
    private func setupMultipeerConnectivity()
    {
        mcSession           = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession?.delegate = self
    }


    @objc
    func importPicture()
    {
        let picker              = UIImagePickerController()
        picker.allowsEditing    = true
        picker.delegate         = self
        present(picker, animated: true)
    }
    
    
    @objc
    func showConnectionPrompt()
    {
        let ac      = UIAlertController(title: "Connect to others", message: nil, preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Host a session", style: .default, handler: startHosting)
        let action2 = UIAlertAction(title: "Join a session", style: .default, handler: joinSession)
        let action3 = UIAlertAction(title: "Cancel", style: .cancel)
        
        ac.addActions([action1, action2, action3])
        present(ac, animated: true)
    }
    
    
    func startHosting(action: UIAlertAction)
    {
        guard let mcSession     = mcSession else { return }
//        mcAdvertiserAssistant   = MCNearbyServiceAdvertiser(peer: peerID,
//                                                            discoveryInfo: nil,
//                                                            serviceType: ServiceTypes.hws)
        mcAdvertiserAssistant   = MCAdvertiserAssistant(serviceType: ServiceTypes.ps, discoveryInfo: nil, session: mcSession)
        mcAdvertiserAssistant?.start()
//        mcAdvertiserAssistant?.delegate = self
//        mcAdvertiserAssistant?.startAdvertisingPeer()
    }
    
    
    func joinSession(action: UIAlertAction)
    {
        guard let mcSession = mcSession else { return }
        let mcBrowser       = MCBrowserViewController(serviceType: ServiceTypes.ps, session: mcSession)
//        let mcBrowser       = MCNearbyServiceBrowser(peer: peerID, serviceType: ServiceTypes.hws)
//        mcBrowser.delegate  = self
//        mcBrowser.startBrowsingForPeers()
        present(mcBrowser, animated: true)
    }
}


// MARK: COLLECTIONVIEW DELEGATE METHODS
extension HomeVC
{
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return images.count }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell            = collectionView.dequeueReusableCell(withReuseIdentifier: ReuseIdentifiers.ImageView, for: indexPath)
        
        if let imageView    = cell.viewWithTag(1000) as? UIImageView { imageView.image = images[indexPath.item] }
        
        return cell
    }
    
    
    // MARK: IMAGE PICKER DELEGATE METHODS

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
        {
            guard let image = info[.editedImage] as? UIImage else { return }
            dismiss(animated: true)
            images.insert(image, at: 0)
            collectionView.reloadData()
            
            guard let mcSession = mcSession else { return }
            if mcSession.connectedPeers.count > 0
            {
                if let imageData    = image.pngData()
                {
                    // triggers MCDelegate's didReceive data, fromPeer method
                    do { try mcSession.send(imageData, toPeers: mcSession.connectedPeers, with: .reliable) }
                    catch { presentSSAlertOnMainThread(alertTitle: "Send error", buttonTitle: "OK", error: error) }
                }
            }
        }
        
        
        func session(_ session: MCSession,
                     didReceive stream: InputStream,
                     withName streamName: String,
                     fromPeer peerID: MCPeerID) { }
        
        
        // triggered by mcSession.send() in ...didFinishPickingMediaWithInfo method
        func session(_ session: MCSession,
                     didReceive data: Data,
                     fromPeer peerID: MCPeerID)
        {
            DispatchQueue.main.async { [weak self] in
                guard let self  = self else { return }
                if let image    = UIImage(data: data) {
                    self.images.insert(image, at: 0)
                    self.collectionView.reloadData()
                }
            }
        }
        
        
        // MARK: MULTICONNECTIVITY DELEGATE METHODS
        
        func session(_ session: MCSession,
                     didStartReceivingResourceWithName resourceName: String,
                     fromPeer peerID: MCPeerID,
                     with progress: Progress) { }
        
        
        func session(_ session: MCSession,
                     didFinishReceivingResourceWithName resourceName: String,
                     fromPeer peerID: MCPeerID,
                     at localURL: URL?, withError error: (any Error)?) { }
        
        
        func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) { dismiss(animated: true) }
        
        
        func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) { dismiss(animated: true) }
        
        
        func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState)
        {
            switch state
            {
            case .connected:
                print("Connected: \(peerID.displayName)")
            case .connecting:
                print("Connecting: \(peerID.displayName)")
            case .notConnected:
                print("Not Connected: \(peerID.displayName)")
            @unknown default:
                print("Unknown state received: \(peerID.displayName)")
            }
        }
        
        
        // MARK: MCBROWSER & MCADVERTISER DELEGATE METHODS
        func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) { }
        
        
        func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) { }
        
        
        func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) { }
}
