//
//  ViewController.swift
//  Volleyball Scorecard Remote
//
//  Created by Eric McGaughey on 12/2/15.
//  Copyright © 2015 Eric McGaughey. All rights reserved.
//



/* This is the remote for the volleyball scorecard iPad app. It uses MPC to connect to the device and send score changes that will be updated on the iPad. */

import UIKit
import MultipeerConnectivity
import QuartzCore


class ViewController: UIViewController {
    
    @IBOutlet weak var teamOneName: UIView!
    @IBOutlet weak var teamTwoName: UILabel!
    @IBOutlet weak var teamTwoMinus: UIButton!
    @IBOutlet weak var teamOneMinus: UIButton!
    @IBOutlet weak var switchSides: UIButton!
    @IBOutlet weak var oopsBtn: UIButton!
    @IBOutlet weak var setNumber: UILabel!
    @IBOutlet weak var teamOneAdd: UIButton!
    @IBOutlet weak var teamTwoAdd: UIButton!
    
    var mpcManager: MPCManager?
    private var hiddenSwitch = true
    
    private var teamOneTapCount = 0
    private var teamTwoTapCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Style the minus buttons
        teamOneMinus.layer.cornerRadius = 10
        teamTwoMinus.layer.cornerRadius = 10
        
        // Style the add buttons
        teamOneAdd.layer.cornerRadius = 25
        teamTwoAdd.layer.cornerRadius = 25
        
        // Start the MPCManager
        mpcManager = MPCManager()
        mpcManager?.delegate = self
        
        // Hide the buttons to animate when Oops! is clicked
        hidetheButtons()
    }
    
    // TODO: Set the scores so that they cannot be negative.

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func teamOneScore(sender: UIButton) {
        
        // TODO: Send INT to receiver instead of a stupid string
        
        if teamOneTapCount >= 0 {
            
            mpcManager?.sendData("TeamOnePlus".dataUsingEncoding(NSUTF8StringEncoding)!)
            teamOneTapCount += 1
            print("\(teamOneTapCount)")
        }
        
        
    }
    
    @IBAction func teamTwoScore(sender: UIButton) {
        
        mpcManager?.sendData("TeamTwoPlus".dataUsingEncoding(NSUTF8StringEncoding)!)
        
    }

    @IBAction func teamOneMinus(sender: UIButton) {
        
        if teamOneTapCount > 0 {
            
            mpcManager?.sendData("TeamOneMinus".dataUsingEncoding(NSUTF8StringEncoding)!)
            teamOneTapCount -= 1
            print("\(teamOneTapCount)")
        }
        
        
    }
    
    @IBAction func teamTwoMinus(sender: UIButton) {
        
        mpcManager?.sendData("TeamTwoMinus".dataUsingEncoding(NSUTF8StringEncoding)!)

    }
  
    @IBAction func oopsButton(sender: UIButton) {
        hidetheButtons()
        
    }
    
    @IBAction func switchSidesAction(sender: UIButton) {
        
        // TODO: Send a flag to tell the receiver to switch sides.
        mpcManager?.sendData("Sides".dataUsingEncoding(NSUTF8StringEncoding)!)
        // TODO: Also need to swap the buttons around on this end.
        
    }
    
    
    func hidetheButtons() {
        
        switch hiddenSwitch {
        case true:
            // Spring the buttons to death
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: UIViewAnimationOptions.AllowAnimatedContent, animations: { () -> Void in
                
                // Hide the switchSides
                self.switchSides.transform = CGAffineTransformMakeScale(0.1, 0.1)
                self.switchSides.alpha = 0.0
                self.switchSides.enabled = false
                
                // Hide the TeamOneMinus
                self.teamOneMinus.transform = CGAffineTransformMakeScale(0.1, 0.1)
                self.teamOneMinus.alpha = 0.0
                self.teamOneMinus.enabled = false
                
                // Hide the TeamTwoMinus
                self.teamTwoMinus.transform = CGAffineTransformMakeScale(0.1, 0.1)
                self.teamTwoMinus.alpha = 0.0
                self.teamTwoMinus.enabled = false
                
                }, completion: nil)
            hiddenSwitch = false
            
        case false:
            // Spring the buttons to life
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 5, options: UIViewAnimationOptions.AllowAnimatedContent, animations: { () -> Void in
                
                // Show Switchsides
                self.switchSides.transform = CGAffineTransformMakeScale(1.0, 1.0)
                self.switchSides.alpha = 1.0
                self.switchSides.enabled = true
                
                // Show TeamOneMinus
                self.teamOneMinus.transform = CGAffineTransformMakeScale(1.0, 1.0)
                self.teamOneMinus.alpha = 1.0
                self.teamOneMinus.enabled = true
                
                // Show TeamTwoMinus
                self.teamTwoMinus.transform = CGAffineTransformMakeScale(1.0, 1.0)
                self.teamTwoMinus.alpha = 1.0
                self.teamTwoMinus.enabled = true
                
                }, completion: nil)
            hiddenSwitch = true
        }
    }
    
    func connectionAlert() {
        let alert = UIAlertController(title: "Scoreboard Found", message: "Would you like to connect as a remote device for the Volleyball scoreboard?", preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            self.mpcManager?.invitationHandler(true, self.mpcManager!.session)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            self.mpcManager?.invitationHandler(false, self.mpcManager!.session)
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func didReceiveData() {
        
    }
    
    func displayConnectionAlert() {
        let alert = UIAlertController(title: "Connected", message: "Game on!", preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}

extension ViewController: MPCManagerDelegate {
    
    func foundPeer() {}
    func lostPeer() {}
    
    func connectedDevices(manager: MPCManager, connectedDevices: [String]) {
        print("Connected with \(connectedDevices)")
        if !connectedDevices.isEmpty {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.displayConnectionAlert()
            })
        }
    }
    
    
    func infoChange(manager: MPCManager, score: String) {
        
        switch(score) {
            case "SetChange":
                // TODO: Change the set label
                break
            case "TeamOneName":
                // TODO: Change the team one name
                break
            case "TeamTwoName":
                // TODO: Change the team two name
                break
        default:
            break
        }
    }
    
    
    func invitationWasReceived(fromPeer: String) {
        connectionAlert()
    }
    
    
    
    
    
    
    
    
    
    
    
    
}
