//
//  toastView.swift
//  NewBear
//
//  Created by He Cho on 2024/4/4.
//

import Foundation


import SwiftUI

struct toastView: View {
    @Binding var info:String
    @State var duration : Double = 1.0
    
    var isShow: Bool{
        info != ""
    }
    @State private var isShowAnimation: Bool = true
    
    
    var body: some View {
        ZStack {
            Text(info)
                .font(.headline)
                .foregroundColor(.white)
                .frame(minWidth: 80, alignment: Alignment.center)
                .zIndex(1.0)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundStyle(.black)
                        .opacity(0.6)
                )
            
        }
        .onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                isShowAnimation = false
            }
        }
        .padding()
        .opacity(isShowAnimation ? 1 : 0)
        .animation(.easeIn(duration: 0.8), value: isShowAnimation)
        .edgesIgnoringSafeArea(.all)
        .onChange(of: isShowAnimation) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.info = ""
            }
        }
    }
}

