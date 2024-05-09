//
//  LoadingView.swift
//  NewBear
//
//  Created by He Cho on 2024/4/4.
//

import SwiftUI


struct LoadingPress: ViewModifier{
    
    var show:Bool = false
    var title:String = ""
    
    func body(content: Content) -> some View {
        
        ZStack {
            content
               
            
            if show{
                VStack{
                    
                    ProgressView()
                        .scaleEffect(3)
                        .padding()
                    
                    Text(title)
                        .font(.caption)
                }
                .background(
                    Rectangle()
                        .fill(Color.black.opacity(0.8))
                        .blur(radius: 10)
                        .frame(width: UIScreen.main.bounds.width,height: UIScreen.main.bounds.height)
                        
                    
                )
                .toolbar(.hidden, for: .tabBar, .navigationBar)
                .navigationBarTitleDisplayMode(.inline)
            }
               
                
        }
    }
}


extension View {
    func loading(_ show:Bool, _ title:String = "")-> some View{
        modifier(LoadingPress(show: show, title: title))
    }
}
