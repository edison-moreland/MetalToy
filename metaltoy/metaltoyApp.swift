//
//  metaltoyApp.swift
//  metaltoy
//
//  Created by Edison Moreland on 1/5/23.
//

import SwiftUI

extension Scene {
    func windowResizabilityContentSize() -> some Scene {
        if #available(macOS 13.0, *) {
            return windowResizability(.contentSize)
        } else {
            return self
        }
    }
}

@main
struct metaltoyApp: App {
    // Disable automatic tabbing
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    class AppDelegate: NSObject, NSApplicationDelegate {
        func applicationDidFinishLaunching(_ notification: Notification) {
            NSWindow.allowsAutomaticWindowTabbing = false
        }
    }
   
    #if DEBUG
    let persistenceController = PersistenceController.preview
    #else
    let persistenceController = PersistenceController.shared
    #endif
    
    var body: some Scene {
        WindowGroup {
            StartupView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .windowResizabilityContentSize()
        .commands {
            // Stop multiple windows from being opened
            CommandGroup(replacing: .newItem, addition: { })
        }

        WindowGroup("Editor", for: URL.self) { $shaderID in
            let id = shaderID.map {
                PersistenceController.getID(persistenceController.container.viewContext, for: $0)
            } ?? nil
            
            EditShaderView(shaderID: id)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
