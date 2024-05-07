//
//  AngularButton.swift
//  NewBear
//
//  Created by He Cho on 2024/4/4.
//


import SwiftUI

struct angularButton: View {
    var title:String
    var disable:Bool = false
    var onTap:()->Void
    @GestureState var isDetectingLongPress = false
    @State var completedLongPress = false
    var body: some View {
        Text(completedLongPress ? "Loading..." : title)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, maxHeight: 50)
            .background(
                ZStack {
                    
                    if !disable{
                        angularGradient
                    }
                    LinearGradient(gradient: Gradient(colors: [Color(.systemBackground).opacity(1), Color(.systemBackground).opacity(0.6)]), startPoint: .top, endPoint: .bottom)
                        .cornerRadius(20)
                        .blendMode(.softLight)
                }
            )
            .frame(height: 50)
            .foregroundStyle(disable ? .gray : .primary)
            .background( angularGradient)
            .scaleEffect((isDetectingLongPress && !disable) ? 0.9 : 1)
            .gesture(
                LongPressGesture(minimumDuration: 0.5)
                    .updating($isDetectingLongPress, body: { currentState, gestureState, transaction in
                        gestureState = currentState
                        transaction.animation = .spring(response: 0.3, dampingFraction: 0.3)
                    })
                    .onEnded({ finished in
                        if !disable{
                            completedLongPress = finished
                        }
                       
                    })
            )
            .simultaneousGesture(
               
                TapGesture().onEnded({ value in
                    if !disable{
                        onTap()
                    }
                   
                })
            )
    }
    
    var angularGradient: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.clear)
            .overlay(AngularGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(#colorLiteral(red: 0, green: 0.5199999809265137, blue: 1, alpha: 1)), location: 0.0),
                    .init(color: Color(#colorLiteral(red: 0.2156862745, green: 1, blue: 0.8588235294, alpha: 1)), location: 0.4),
                    .init(color: Color(#colorLiteral(red: 1, green: 0.4196078431, blue: 0.4196078431, alpha: 1)), location: 0.5),
                    .init(color: Color(#colorLiteral(red: 1, green: 0.1843137255, blue: 0.6745098039, alpha: 1)), location: 0.8)]),
                center: .center
            ))
            .padding(6)
            .blur(radius: 20)
    }

}


struct CloseButton: View {
    var body: some View {
        Image(systemName: "xmark")
            .font(.system(size: 17, weight: .bold))
            .foregroundColor(.secondary)
            .padding(8)
            .background(.ultraThinMaterial, in: Circle())
            .backgroundStyle(cornerRadius: 18)
    }
}



#Preview {
    VStack{
        CloseButton()
        angularButton(title: "获取验证码",disable: true){
#if DEBUG
            print("获取验证码")
#endif
            
        }
    }
}

