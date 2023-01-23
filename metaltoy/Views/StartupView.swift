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
    @FetchRequest(fetchRequest: DataStore.recentShadersRequest)
    private var recentShaders: FetchedResults<ToyShader>
    
    let cellView: (ToyShader?) -> Cell
    
    var body: some View {
        Grid {
            GridRow {
                ForEach(0..<5, id: \.self) { i in
                    cellView(recentShaders[safe: i])
                }
            }
            GridRow {
                ForEach(5..<10, id: \.self) { i in
                    cellView(recentShaders[safe: i])
                }
            }
        }
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
                Button(action: { openEditor(shader) }) {
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
    
    private func openEditor(_ shader: ToyShader?) {
        guard supportsMultipleWindows else {
            return
        }
        
        guard let id = shader?.objectID else {
            let newShader = DataStore.shared.newToyShader()
            openWindow(value: newShader.objectID.uriRepresentation())
            return
        }
        
        openWindow(value: id.uriRepresentation())
    }
}

struct StartupView_Previews: PreviewProvider {
    static var previews: some View {
        StartupView()
            .environment(\.managedObjectContext, DataStore.shared.context)
    }
}
