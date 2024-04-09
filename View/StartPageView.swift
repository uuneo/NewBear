//
//  StartPageView.swift
//  NewBear
//
//  Created by He Cho on 2024/4/9.
//

import SwiftUI

struct StartPageView: View {
    @AppStorage(settings.firstStartApp) var firstart:Bool = true
    @State  var rotationAngle:Double = 0
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
                            .font(.largeTitle)
                            .offset(x: 5,y: -35)
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
//                            .scaleEffect(rotationAngle)
                            .offset(x: rotationAngle)
                    }
                    .onAppear {
                        withAnimation(Animation.easeOut(duration: 0.8).repeatForever()) {
                            self.rotationAngle = 30
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
