//
//  ButtonPress.swift
//  NewBear
//
//  Created by He Cho on 2024/5/8.
//

import Foundation
import SwiftUI

struct ButtonPress: ViewModifier{
    
    var onPress:()->Void
    var onRelease:()->Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ _ in
                        onPress()
                    })
                    .onEnded({ _ in
                        onRelease()
                    })
            )
    }
}


extension View{
    func pressEvents(onPress: @escaping(()->Void), onRelease: @escaping(()->Void))-> some View{
        modifier(ButtonPress(onPress: { onPress() }, onRelease: { onRelease() }))
    }
}
