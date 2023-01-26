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
    
    var body: some Scene {
        Window("MetalToy", id: "main") {
            StartupView()
                .environment(\.managedObjectContext, DataStore.shared.context)
        }
        .windowResizabilityContentSize()

        WindowGroup("Editor", for: URL.self) { $shaderID in
            EditShaderView(shader: DataStore.shared.getToyShader(url: shaderID!)!)
                .environment(\.managedObjectContext, DataStore.shared.context)
        }
    }
}
