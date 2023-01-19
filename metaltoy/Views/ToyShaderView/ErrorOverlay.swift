//
//  ErrorOverlay.swift
//  metaltoy
//
//  Created by Edison Moreland on 1/11/23.
//

import SwiftUI

struct ErrorOverlay: View {
    var text: String
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "exclamationmark.triangle.fill")
                .imageScale(.large)
                .frame(width:30, height: 30)
                
            Text(text)
        }.padding()
         .background(Color.red.opacity(0.95))
         .foregroundColor(.white)
         .cornerRadius(15)
    }
}

struct ErrorOverlay_Previews: PreviewProvider {
    static var previews: some View {
        ErrorOverlay(text: "error")
    }
}
