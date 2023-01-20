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
    @FetchRequest(fetchRequest: PersistenceController.recentShadersRequest)
    private var recentShaders: FetchedResults<ToyShader>
    
    let cellView: (ToyShader?) -> Cell
    
    // TODO: I think this solution for getting a grid is really gross
    var body: some View {
        Grid {
            GridRow {
                ForEach(upperRow(recentShaders), id: \.self) { shader in
                    cellView(shader)
                }
            }
            GridRow {
                ForEach(lowerRow(recentShaders), id: \.self) { shaderID in
                    cellView(shaderID)
                }
            }
        }
    }
    
    private func upperRow(_ shaders: FetchedResults<ToyShader>) -> [ToyShader?] {
        var newUpperRow: [ToyShader?] = []
        for i in 0..<5 {
            newUpperRow.append(shaders[safe: i])
        }
        return newUpperRow
    }
    
    private func lowerRow(_ shaders: FetchedResults<ToyShader>) -> [ToyShader?] {
        var newLowerRow: [ToyShader?] = []
        for i in 0..<5 {
            newLowerRow.append(shaders[safe: 5+i])
        }
        return newLowerRow
    }
}

struct ShaderPreview: View {
    @ObservedObject var shader: ToyShader
    
    var body: some View {
        ToyShaderView(shader: Binding($shader.source) ?? .constant(""), scale: 0.4)
    }
}

struct StartupView: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.supportsMultipleWindows) private var supportsMultipleWindows
    
    var body: some View {
        VStack {
            Image("MetalToy_Splash")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(Color("AppOrange"))
                .aspectRatio(contentMode: .fit)
                .frame(width:900, height: 250)
            RecentShadersGrid { shader in
                Button(action: { openEditor(shader?.objectID) }) {
                    if let shader {
                        ShaderPreview(shader: shader)
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
            let newShader = PersistenceController.shared.newToyShader()
            openWindow(value: newShader.objectID.uriRepresentation())
            return
        }
        
        openWindow(value: id.uriRepresentation())
    }
}

struct StartupView_Previews: PreviewProvider {
    static var previews: some View {
        StartupView()
            .environment(\.managedObjectContext, PersistenceController.shared.context)
    }
}
