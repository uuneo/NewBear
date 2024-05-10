//
//  StartPageView.swift
//  NewBear
//
//  Created by He Cho on 2024/4/9.
//

import SwiftUI

struct StartPageView: View {
    @AppStorage(settings.firstStartApp) var firstart:Bool = true
    @EnvironmentObject var paw: pawManager
    @State  var rotationAngle:Bool = false
    @State var animate2:Bool = false
    
    @State private var errorAnimate1:Bool = false
    @State private var errorAnimate2:Bool = false
    @State private var errorAnimate3:Bool = false

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
                            .frame(width: animate2 ? 80 : 100)
                            .offset(x: rotationAngle ? -30 : 0)
                            .offset(y: animate2 ? 60 : 0)
                            
                        Text("New Bear")
                            .font(Font.custom("Zapfino", size: 30))
                            .offset(x: animate2 ? 60 : 0,y: -70)
                           
                    }
                    Spacer()
                    Spacer()
                }
               
              
                

                Spacer()
                
               
                Spacer()
                Spacer()
                HStack{
                    
                    Button {
                        if paw.notificationPermissionStatus.rawValue == 0{
                            paw.registerForRemoteNotifications()
                        }else{
                            paw.openSetting()
                        }
                    } label: {
                        LabeledContent {
                            Group{
                                if !paw.isNetworkAvailable && paw.notificationPermissionStatus.rawValue >= 2{
                                    Text(NSLocalizedString("openSetting", comment: "打开设置"))
                                }else if paw.notificationPermissionStatus.rawValue < 2 && paw.isNetworkAvailable {
                                    
                                    Text(NSLocalizedString("openNotification", comment: "打开权限"))
                                }else if paw.notificationPermissionStatus.rawValue < 2 && !paw.isNetworkAvailable {
                                    
                                    Text(NSLocalizedString("notificationAndNetwork", comment: "通知/ 设置"))
                                    
                                }else{
                                    Button{
                                        self.firstart.toggle()
                                    }label: {
                                        Label( NSLocalizedString("startUse", comment: "点击进入") , systemImage: "building.columns")
                                            .offset(x: rotationAngle ? 0 : -1000)
                                            .opacity(animate2 ? 1 : 0.5)
                                            .scaleEffect(animate2 ? 1.2 : 1)
                                        
                                        
                                    }
                                        .onAppear{
                                        
                                            self.firstart.toggle()
                                        }
                                }
                            }
                        } label: {
                            Group{
                                if !paw.isNetworkAvailable && paw.notificationPermissionStatus.rawValue >= 2{
                                    Image(systemName: "wifi.exclamationmark")
                                        .foregroundStyle(.yellow)
                                        .opacity(errorAnimate1 ? 1 : 0.1)
                                        .onAppear{
                                            withAnimation(Animation.bouncy(duration: 0.5).repeatForever()) {
                                                self.errorAnimate1 = true
                                            }
                                        }
                                        .onDisappear{
                                            self.errorAnimate1 = false
                                        }
                                }else if paw.notificationPermissionStatus.rawValue < 2 && paw.isNetworkAvailable {
                                    
                                    Image(systemName: "bell.slash")
                                        .foregroundStyle(.red)
                                        .opacity(errorAnimate2 ? 0.1 : 1)
                                        .onAppear{
                                            withAnimation(Animation.bouncy(duration: 0.5).repeatForever()) {
                                                self.errorAnimate2 = true
                                            }
                                        }
                                        .onDisappear{
                                            self.errorAnimate2 = false
                                        }
                                    
                                }else if paw.notificationPermissionStatus.rawValue < 2 && !paw.isNetworkAvailable {
                                    
                                    ZStack{
                                        
                                        Image(systemName: "bell.slash")
                                            .foregroundStyle(.red)
                                            .opacity(errorAnimate3 ? 0.1 : 1)
                                        
                                        Image(systemName: "wifi.exclamationmark")
                                            .foregroundStyle(.yellow)
                                            .opacity(errorAnimate3 ? 1 : 0.1)
                                           
                                    }
                                    .onAppear{
                                        withAnimation(Animation.bouncy(duration: 0.5).repeatForever()) {
                                            self.errorAnimate3 = true
                                        }
                                    }
                                    .onDisappear{
                                        self.errorAnimate3 = false
                                    }
                                    
                                }
                            }
                        }
                    }.frame(width: 120)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())

                   
                    
                    
                   

                    
                    
                }
                Spacer()
            }
        }
        .onAppear {
            
            withAnimation( .spring) {
                self.rotationAngle.toggle()
            }
            
            withAnimation( .easeIn.delay(1)) {
                self.animate2.toggle()
            }
        }
        
        
    }
}

#Preview {
    StartPageView()
        .environmentObject(pawManager.shared)
}
