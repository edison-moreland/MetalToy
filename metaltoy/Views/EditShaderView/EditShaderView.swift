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
    @ObservedObject var shader: ToyShader

    var body: some View {
        HSplitView {
            ToyShaderView(shader: $previewContent)
            VStack(alignment: .leading, spacing: 0) {
                ControlBar(leading: {
                    ControlButton(icon: "play") { onSubmit() }
                    ControlButton(icon: "doc") { onSave() }
                    Text("\(shader.revision)")
                }, trailing: {
                    ControlButton(icon: "trash") {onDelete()}
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
        PersistenceController.shared.updateToyShader(id: shader.objectID, source: editorContent)
    }
    
    private func onDelete() {
        PersistenceController.shared.deleteToyShader(id: shader.objectID)
        // TODO: Close editor window
    }
}

struct EditShaderView_Previews: PreviewProvider {
    static var previews: some View {
        let shader = PersistenceController.shared.newToyShader()
        
        EditShaderView(shader: shader)
    }
}
