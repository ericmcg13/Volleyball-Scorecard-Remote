//
//  MPCManager.swift
//  Volleyball Scorecard Remote
//
//  Created by Eric McGaughey on 12/2/15.
//  Copyright © 2015 Eric McGaughey. All rights reserved.
//

import Foundation
import MultipeerConnectivity


protocol MPCManagerDelegate {
    func connectedDevices(manager: MPCManager, connectedDevices: [String])
    func invitationWasReceived(fromPeer: String)
    func infoChange(manager: MPCManager, score: String)
    func lostPeer()
    func foundPeer()
}




class MPCManager: NSObject {
    
    let serviceType = "Volleyball-Scor"
    let myPeerID = MCPeerID(displayName: UIDevice.currentDevice().name)
    let serviceAdvertiser: MCNearbyServiceAdvertiser
    let serviceBrowser: MCNearbyServiceBrowser
    
    var invitationHandler: ((Bool, MCSession)->Void)!
    var delegate: MPCManagerDelegate?
    var foundPeers = [MCPeerID]()
    
    override init() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        
        super.init()
        
        self.serviceAdvertiser.delegate = self
        self.serviceBrowser.delegate = self
        
        self.serviceAdvertiser.startAdvertisingPeer()
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    lazy var session: MCSession = {
        let session = MCSession(peer: self.myPeerID, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.Required)
        session.delegate = self
        
        return session
    }()
    
    // Function to send data
    func sendData(data: NSData) -> Bool {
        if session.connectedPeers.count > 0 {
            do {
                try self.session.sendData(data, toPeers: session.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
                print(data)
            }catch let error as NSError {
                print(error)
                return false
            }
        }
        return true
    }
    
}

extension MPCManager: MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        print("didNotStartAdvertising")
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        print("didReceiveInvitation")
        
        self.invitationHandler = invitationHandler
        
        delegate?.invitationWasReceived(peerID.displayName)
    }
    
}

extension MPCManager: MCNearbyServiceBrowserDelegate {
    
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        print("didNotStartBrowsing")
    }
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("lostPeer")
        
        for (index, aPeer) in (foundPeers.enumerate()) {
            if aPeer == peerID {
                foundPeers.removeAtIndex(index)
                break
            }
        }
        delegate?.lostPeer()
    }
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("Found Peer: \(peerID.displayName)")
        foundPeers.append(peerID)
        
        browser.invitePeer(peerID, toSession: self.session, withContext: nil, timeout: 30)
        
        delegate?.foundPeer()
    }
    
    
    
}

extension MCSessionState {
    func stringValue() -> String {
        switch (self) {
        case .Connecting:
            return "Connecting"
        case .Connected:
            return "Connected"
        case .NotConnected:
            return "Not Connected"
        }
    }
}

extension MPCManager: MCSessionDelegate {
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {}
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {}
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        print("Peer \(peerID.displayName) didChangeState: \(state.stringValue())")
        
        self.delegate?.connectedDevices(self, connectedDevices: session.connectedPeers.map({$0.displayName}))
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        print("didReceiveData: \(data.length) bytes")
        
        if let sessionString = NSString(data: data, encoding: NSUTF8StringEncoding) as? String {
            self.delegate?.infoChange(self, score: sessionString)
        }
        
    }
}














