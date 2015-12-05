//
//  AppDelegate.swift
//  HideMacBars
//
//  Created by Joao Fermoselle on 04/12/2015.
//  Copyright © 2015 JRFS. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    // Create new status bar item
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSSquareStatusItemLength)
    
    // Set initial status
    // TODO: Read plist to figure out the status
    var status: Status = .ShowAll


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        if let button = statusItem.button {
            button.image = NSImage(named: "ShowAll")
            button.action = Selector("toggleBars:")
        }
        
    }
    
    func toggleBars(sender: AnyObject) {
        
        let button = sender as! NSStatusBarButton
        
        // Toggle the status and change the icon image
        if status == .ShowAll {
            button.image = NSImage(named: "MenuHidden")
            status = .MenuHidden
        } else {
            button.image = NSImage(named: "ShowAll")
            status = .ShowAll
        }
        
    }

}

// The possible states of the application
enum Status {
    case ShowAll
    case MenuHidden
}

