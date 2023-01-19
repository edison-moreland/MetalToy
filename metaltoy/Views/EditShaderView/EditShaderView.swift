//
//  EditShaderView.swift
//  metaltoy
//
//  Created by Edison Moreland on 1/14/23.
//

import SwiftUI
import CodeEditor

struct EditShaderView: View {
    @Environment(\.managedObjectContext) var viewContext
    
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
                let newShader = PersistenceController.newToyShader(viewContext)
                
                self.shaderID = newShader.objectID
                self.editorContent = newShader.source!
                self.previewContent = self.editorContent
                return
            }
           
            let shader = PersistenceController.getToyShader(viewContext, id: shaderID)!
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
        PersistenceController.updateToyShader(viewContext, id: shaderID, source: editorContent)
    }
}

struct EditShaderView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let shader = PersistenceController.newToyShader(context)
        let shaderID = PersistenceController.getID(context, for: shader.objectID.uriRepresentation())
        
        EditShaderView(shaderID: shaderID)
            .environment(\.managedObjectContext, context)
    }
}
