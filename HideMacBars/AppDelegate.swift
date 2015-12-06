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
    
    var status: Status = .ShowAll

    

    // ---------------------
    // MARK: App start
    // ---------------------
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        // Check what the current status is.
        status = currentStatus()
        print(status)
        
        initIcon()
        
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
        
        // Toggle the status and change the icon image
        if status == .ShowAll {
            status = .MenuHidden
            
//            CFPreferencesSetValue("_HIHideMenuBar", true, kCFPreferencesAnyApplication, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost)
            
            // Load .GlobalPreferences.plist to an array
            guard let prefArrayTemp = NSUserDefaults.standardUserDefaults().persistentDomainForName(NSGlobalDomain) else {
                print("Could not read .GlobalPreferences.plist")
                return
            }
            
            var prefArray = prefArrayTemp
            prefArray.updateValue(true, forKey: "_HIHideMenuBar")
            NSUserDefaults.standardUserDefaults().setPersistentDomain(prefArray, forName: NSGlobalDomain)
            NSUserDefaults.standardUserDefaults().synchronize()
            
            dispatch_async(dispatch_get_main_queue()) {
                CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), "AppleInterfaceMenuBarHidingChangedNotification", nil, nil, true)
            }
            
        } else {
            
            status = .ShowAll
            
            // Load .GlobalPreferences.plist to an array
            guard let prefArrayTemp = NSUserDefaults.standardUserDefaults().persistentDomainForName(NSGlobalDomain) else {
                print("Could not read .GlobalPreferences.plist")
                return
            }
            
            var prefArray = prefArrayTemp
            prefArray.updateValue(false, forKey: "_HIHideMenuBar")
            NSUserDefaults.standardUserDefaults().setPersistentDomain(prefArray, forName: NSGlobalDomain)
            NSUserDefaults.standardUserDefaults().synchronize()
            
            dispatch_async(dispatch_get_main_queue()) {
                CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), "AppleInterfaceMenuBarHidingChangedNotification", nil, nil, true)
            }
            
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

