//
//  SplashScreen.swift
//  metaltoy
//
//  Created by Edison Moreland on 1/14/23.
//

import SwiftUI
import ViewExtractor

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

struct RecentShadersGrid<Cell: View>: View {
    @Environment(\.controlActiveState) var controlActiveState
    @Environment(\.managedObjectContext) var viewContext
    
    @State var upperRow: [NSManagedObjectID?] = []
    @State var lowerRow: [NSManagedObjectID?] = []
    let cellView: (NSManagedObjectID?) -> Cell
    
    var body: some View {
        Grid {
            GridRow {
                ForEach(upperRow, id: \.self) { shaderID in
                    cellView(shaderID)
                }
            }
            GridRow {
                ForEach(lowerRow, id: \.self) { shaderID in
                    cellView(shaderID)
                }
            }
        }
        .onChange(of: controlActiveState) { activeState in
            if activeState == .key {
                updateRows()
            }
        }
        .onAppear {
            updateRows()
        }
    }
    
    private func updateRows() {
        let recentShaders = PersistenceController.getRecentShaders(context: viewContext)
        
        var newUpperRow: [NSManagedObjectID?] = []
        for i in 0..<5 {
            newUpperRow.append(recentShaders[safe: i]?.objectID)
        }
        self.upperRow = newUpperRow
        
        var newLowerRow: [NSManagedObjectID?] = []
        for i in 0..<5 {
            newLowerRow.append(recentShaders[safe: 5+i]?.objectID)
        }
        self.lowerRow = newLowerRow
    }
    
}

struct ShaderPreview: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.controlActiveState) var controlActiveState
    
    @State var shaderSource: String = ""
    let shaderID: NSManagedObjectID

    var body: some View {
        ToyShaderView(shader: $shaderSource, scale: 0.4)
        .onChange(of: controlActiveState) { activeState in
            if activeState == .key {
                updateSource()
            }
        }
        .onAppear {
            updateSource()
        }
    }
    
    private func updateSource() {
        shaderSource = PersistenceController.getToyShader(viewContext, id: shaderID).map { shader in shader.source! } ?? ""
    }
}

struct StartupView: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.supportsMultipleWindows) private var supportsMultipleWindows
    @Environment(\.managedObjectContext) var viewContext
    
    var body: some View {
        VStack {
            Image("MetalToy_Splash")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(Color("AppOrange"))
                .aspectRatio(contentMode: .fit)
                .frame(width:900, height: 250)
            RecentShadersGrid { shaderID in
                Button(action: { openEditor(shaderID) }) {
                    if let shaderID {
                        ShaderPreview(shaderID: shaderID)
                    } else {
                        Image(systemName: "plus")
                            .foregroundColor(Color("AppOrange"))
                            .imageScale(.large)
                            .scaledToFill()
                    }
                }
                .frame(width: 100, height: 100)
                .buttonStyle(.borderless)
                .border(Color("AppOrange"))
                .background(Color("AppOrange").opacity(0.1))
                .cornerRadius(10)
            }
        }
        .padding(50)
        .background(Color("AppWhite"))

    }
    
    private func openEditor(_ id: NSManagedObjectID?) {
        guard supportsMultipleWindows else {
            return
        }
        
        guard let id else {
            let newShader = PersistenceController.newToyShader(viewContext)
            openWindow(value: newShader.objectID.uriRepresentation())
            return
        }
        
        openWindow(value: id.uriRepresentation())
    }
}

struct StartupView_Previews: PreviewProvider {
    static var previews: some View {
        StartupView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
