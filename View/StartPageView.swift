//
//  StartPageView.swift
//  NewBear
//
//  Created by He Cho on 2024/4/9.
//

import SwiftUI

struct StartPageView: View {
    @AppStorage(settings.firstStartApp) var firstart:Bool = true
    @State  var rotationAngle:Bool = false
    @State var animate2:Bool = false
    var body: some View {
        ZStack{
            Color.clear.ignoresSafeArea()
            VStack{
                Spacer()
                HStack{
                    Spacer()
                    VStack(alignment: .leading){
                        Image("bearhead")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100,height: 100)
                        Text("New Bear")
                            .font(Font.custom("Zapfino", size: 30))
                            .offset(x: 5,y: -80)
                    }
                    Spacer()
                    Spacer()
                }
                Spacer()
                Spacer()
                Spacer()
                HStack{
                    Spacer()
                    Spacer()
                    Spacer()
                    Button{
                        self.firstart.toggle()
                    }label: {
                        Label( NSLocalizedString("startUse", comment: "点击进入") , systemImage: "building.columns")
                            .offset(x: rotationAngle ? 0 : -1000)
                            .opacity(animate2 ? 1 : 0.5)
                            .scaleEffect(animate2 ? 1.2 : 1)
                        
                        
                    }
                    .onAppear {
                        
                        withAnimation( .spring) {
                            self.rotationAngle.toggle()
                        }
                        
                        withAnimation( .easeIn.delay(1)) {
                            self.animate2.toggle()
                        }
                    }
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

#Preview {
    StartPageView()
}
