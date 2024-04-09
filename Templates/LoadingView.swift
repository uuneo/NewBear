//
//  LoadingView.swift
//  NewBear
//
//  Created by He Cho on 2024/4/4.
//

import SwiftUI

struct LoadingView: View {
    @State var show:Bool
    @State var text:String
    
    
    var body: some View {
        ZStack(alignment: .center) {
            VStack{
                ProgressView()
                    .scaleEffect(3)
                    .padding()
                Text(text)
                    .font(.caption)
            }
            
        }
        .padding()
        .opacity(show ? 1 : 0)
        .animation(.easeIn(duration: 0.8), value: show)
        .edgesIgnoringSafeArea(.all)
    }
}

extension View {
    func loading(_ show:Bool,_ text:String = "") -> some View {
        ZStack {
            self
                .blur(radius: show ? 3.0 : 0)
            if show {
                LoadingView(show: show,text: text)
            }
        }
    }
}
