//
//  EditShaderView.swift
//  metaltoy
//
//  Created by Edison Moreland on 1/14/23.
//

import SwiftUI
import CodeEditor

struct EditShaderView: View {
    @State var previewContent: String = ""
    @State var editorContent: String = ""
    @State var shaderID: NSManagedObjectID?

    var body: some View {
        HSplitView {
            ToyShaderView(shader: $previewContent)
            VStack(alignment: .leading, spacing: 0) {
                ControlBar() {
                    ControlButton(icon: "play") { onSubmit() }
                    ControlButton(icon: "doc") { onSave() }
                }
                CodeEditor(source: $editorContent,
                           language: .cpp,
                           theme: .ocean,
                           indentStyle: .softTab(width: 4))
            }
        }
        .onAppear {
            guard let shaderID else {
                let newShader = PersistenceController.shared.newToyShader()
                
                self.shaderID = newShader.objectID
                self.editorContent = newShader.source!
                self.previewContent = self.editorContent
                return
            }
           
            let shader = PersistenceController.shared.getToyShader(id: shaderID)!
            self.shaderID = shaderID
            self.editorContent = shader.source!
            self.previewContent = self.editorContent
        }
    }

    private func onSubmit() {
        // Trigger recompilation in the shader view
        previewContent = editorContent
    }
    
    private func onSave() {
        guard let shaderID else {
            return
        }
        
        // Update source in database
        onSubmit()
        PersistenceController.shared.updateToyShader(id: shaderID, source: editorContent)
    }
}

struct EditShaderView_Previews: PreviewProvider {
    static var previews: some View {
        let shader = PersistenceController.shared.newToyShader()
        let shaderID = PersistenceController.shared.getID(for: shader.objectID.uriRepresentation())
        
        EditShaderView(shaderID: shaderID)
    }
}
