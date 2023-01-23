//
//  EditShaderView.swift
//  metaltoy
//
//  Created by Edison Moreland on 1/14/23.
//

import SwiftUI
import CodeEditor

struct EditShaderView: View {
    @Environment(\.openWindow) private var openWindow
    
    @State var previewContent: String = ""
    @State var editorContent: String = ""
    @ObservedObject var shader: ToyShader

    var body: some View {
        HSplitView {
            ToyShaderView(shader: $previewContent)
            VStack(alignment: .leading, spacing: 0) {
                ControlBar(leading: {
                    ControlButton("Submit", icon: "play") { onSubmit() }
                }, trailing: {
                    Text("\(shader.revision)")
                        .help("Revision")
                    ControlButton("Save", icon: "doc") { onSave() }
                    ControlButton("Duplicate", icon: "doc.on.doc") { onDuplicate() }
                    ControlButton("Delete", icon: "trash") { onDelete() }
                })
                CodeEditor(source: $editorContent,
                           language: .cpp,
                           theme: .ocean,
                           indentStyle: .softTab(width: 4))
            }
        }
        .onAppear {
            self.editorContent = shader.source!
            self.previewContent = self.editorContent
        }
    }

    private func onSubmit() {
        guard previewContent != editorContent else {
            return
        }
        
        // Trigger recompilation in the shader view
        previewContent = editorContent
    }
    
    private func onSave() {
        guard shader.source != editorContent else {
            return
        }
        
        // Update source in database
        onSubmit()
        DataStore.shared.updateToyShader(id: shader.objectID, source: editorContent)
    }
    
    private func onDuplicate() {
        let newShader = DataStore.shared.newToyShader(source: shader.source!)
        openWindow(value: newShader.objectID.uriRepresentation())
    }
    
    private func onDelete() {
        DataStore.shared.deleteToyShader(id: shader.objectID)
        // TODO: Close editor window
    }
}

struct EditShaderView_Previews: PreviewProvider {
    static var previews: some View {
        let shader = DataStore.shared.newToyShader()
        
        EditShaderView(shader: shader)
    }
}
