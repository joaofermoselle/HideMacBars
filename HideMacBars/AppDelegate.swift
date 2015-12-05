//
//  AppDelegate.swift
//  HideMacBars
//
//  Created by Joao Fermoselle on 04/12/2015.
//  Copyright © 2015 JRFS. All rights reserved.
//

import Cocoa
import CoreFoundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    
    // ---------------------
    // MARK: Properties
    // ---------------------
    
    @IBOutlet weak var window: NSWindow!
    
    let preferencesPath = "/Users/Joao/Library/Preferences/.GlobalPreferences.plist"
    
    // Create new status bar item
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSSquareStatusItemLength)
    
    // Set initial status
    // TODO: Read plist to figure out the status
    var status: Status = .ShowAll

    

    // ---------------------
    // MARK: App start
    // ---------------------
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        // Check what the current status is.
        status = currentStatus()
        print(status)
        
        initIcon()
        
        guard let dict = NSDictionary(contentsOfFile: preferencesPath) else {
            print("Couldn't open plist")
            return
        }
        
        print("Could open plist!")
        //print(dict)
        
    }
    
    
    
    // ---------------------
    // MARK: Methods
    // ---------------------
    
    func currentStatus() -> Status {
        if NSUserDefaults.standardUserDefaults().boolForKey("_HIHideMenuBar") {
            return .MenuHidden
        } else {
            return .ShowAll
        }
    }
    
    
    func initIcon() {
        statusItem.button!.action = Selector("toggleBars:")
        updateIcon()
    }
    
    func updateIcon() {
        statusItem.button!.image = NSImage(named: status.rawValue)
    }
    
    
    func toggleBars(sender: AnyObject) {
        
        let button = sender as! NSStatusBarButton
        
        // Toggle the status and change the icon image
        if status == .ShowAll {
            status = .MenuHidden
            
            // Hide menu
        } else {
            status = .ShowAll
            
            // Show menu
        }
        
        updateIcon()
        
    }

}

// The possible states of the application
// Made as enum because I want to allow for the Dock to be hidden in the future
enum Status: String {
    case ShowAll = "ShowAll"
    case MenuHidden = "MenuHidden"
}

