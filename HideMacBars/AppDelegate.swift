//
//  AppDelegate.swift
//  HideMacBars
//
//  Created by Joao Fermoselle on 04/12/2015.
//  Copyright © 2015 JRFS. All rights reserved.
//

import AppKit
import Cocoa
import CoreFoundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    
    // ---------------------
    // MARK: Properties
    // ---------------------
    
    @IBOutlet weak var window: NSWindow!
    
    // Create new status bar item
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSSquareStatusItemLength)
    
    // Create a menu for the app
    let menu = NSMenu()
    
    var status: Status = .ShowAll

    

    // ---------------------
    // MARK: App start
    // ---------------------
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        // Check what the current status is and update the variable.
        status = currentStatus()
        
        // Initialise the menu bar button with the correct icon.
        initIcon()
        
        // Add items to menu
        menu.addItem(NSMenuItem(title: "About", action: Selector("aboutButton:"), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Quit", action: Selector("terminate:"), keyEquivalent: "q"))
        
    }
    
    
    
    // ---------------------
    // MARK: Methods
    // ---------------------
    
    /**
        Checks the value of the key `_HIHideMenuBar` in .GlobalPreferences,
        located at ~/Library/Preferences/.
    
        - Returns: Current status of the visibility of the system menu bar.
    */
    func currentStatus() -> Status {
        if NSUserDefaults.standardUserDefaults().boolForKey("_HIHideMenuBar") {
            return .MenuHidden
        } else {
            return .ShowAll
        }
    }
    
    
    /**
        Initialises the menu bar icon with the action that should be performed
        upon a click and updates the icon image.
    */
    func initIcon() {
        statusItem.button!.action = Selector("toggleBars:")
        statusItem.button!.sendActionOn(Int(NSEventMask.LeftMouseUpMask.rawValue)|Int(NSEventMask.RightMouseUpMask.rawValue))
        updateIcon()
    }
    
    
    /**
        Updates the icon image according to the value of the variable `status`.
    */
    func updateIcon() {
        statusItem.button!.image = NSImage(named: status.rawValue)
        statusItem.button!.image?.template = true
    }
    
    
    /**
        Toggle the visibility of the system's menu bar.
        Currently called toggleBars as we may implement the hiding of other bars
        in the future.
    */
    func toggleBars(sender: AnyObject) {
        
        let event = NSApplication.sharedApplication().currentEvent!
        
        let isRightClick = event.type == NSEventType.RightMouseUp
        let isControlClick = Int(event.modifierFlags.rawValue) & Int(NSEventModifierFlags.ControlKeyMask.rawValue) != 0
        
        // If right-click or Ctrl+click
        if (isRightClick || isControlClick) {
            statusItem.popUpStatusItemMenu(menu)
            return
        }
        
        if status == .ShowAll {
            status = .MenuHidden
            
            // Set value of key `_HIHideMenuBar` in .GlobalPreferences to true.
            guard setMenuHidingKey(true) else {
                print("Could not set the menu hiding key.")
                return
            }
            
        } else {
            
            status = .ShowAll
            
            // Set value of key `_HIHideMenuBar` in .GlobalPreferences to false.
            guard setMenuHidingKey(false) else {
                print("Could not set the menu hiding key.")
                return
            }
            
        }
        
        // Send notification for the OS to listen, check .GlobalPreferences, and update
        // the menu bar visibility accordingly.
        dispatch_async(dispatch_get_main_queue()) {
            CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), "AppleInterfaceMenuBarHidingChangedNotification", nil, nil, true)
        }
        
        updateIcon()
        
    }
    
    
    /**
        Sets the value of the key `_HIHideMenuBar` in .GlobalPreferences,
        located at ~/Library/Preferences/ to the value of `bool`.
    
        - Parameter bool: Value to which `_HIHideMenuBar` should be set.
    
        - Returns: True if the operation succeeded, false if it did not.
    */
    func setMenuHidingKey(bool: Bool) -> Bool {
        
        // Load .GlobalPreferences.plist to an array
        guard let prefArrayTemp = NSUserDefaults.standardUserDefaults().persistentDomainForName(NSGlobalDomain) else {
            print("Could not read .GlobalPreferences.plist")
            return false
        }
        
        var prefArray = prefArrayTemp
        prefArray.updateValue(bool, forKey: "_HIHideMenuBar")
        NSUserDefaults.standardUserDefaults().setPersistentDomain(prefArray, forName: NSGlobalDomain)
        
        return true
        
    }
    
    
    func aboutButton(sender:AnyObject) {
        NSApplication.sharedApplication().activateIgnoringOtherApps(true)
        NSApplication.sharedApplication().orderFrontStandardAboutPanel(sender)
    }

}

// The possible states of the application
// Made as enum because I want to allow for the Dock to be hidden in the future
enum Status: String {
    case ShowAll = "ShowAll"
    case MenuHidden = "MenuHidden"
}

