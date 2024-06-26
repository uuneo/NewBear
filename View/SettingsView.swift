//
//  SettingsView.swift
//  NewBear
//
//  Created by He Cho on 2024/4/4.
//

import SwiftUI
import RealmSwift
import CloudKit
import Combine


struct SettingView: View {
    @ObservedResults(NotificationMessage.self) var messages
    @EnvironmentObject var paw:pawManager
    @EnvironmentObject var pageView:pageState
    @State private var isArchive:Bool = false
    @State private var webShow:Bool = false
    @State private var webUrl:String = otherUrl.helpWebUrl
    @State private var progressValue: Double = 0.0
    @State private var toastText = ""
    @State private var isShareSheetPresented = false
    @State private var jsonFileUrl:URL?
    @State private var cloudStatus = NSLocalizedString("checkimge",comment: "")
    @State private var serverSize:CGSize = .zero
    @State private var serverColor:Color = .red
    @State private var errorAnimate1:Bool = false
    @State private var errorAnimate2:Bool = false
    @State private var errorAnimate3:Bool = false
    @State private var showLoading:Bool = false
    
    @AppStorage("setting_active_app_icon") var setting_active_app_icon:appIcon = .def
    
    @State private var timerz: AnyCancellable?
    
    var body: some View {
        
        VStack{
            List{
        
                Section(header: Text("iCloud"),footer: Text(NSLocalizedString("icloudHeader",comment: ""))) {
                    NavigationLink(destination: {
                        cloudMessageView()
                            .toolbar(.hidden, for: .tabBar)
                    }, label: {
                        HStack{
                           
                            Label {
                                Text(NSLocalizedString("icloudBody",comment: ""))
                                    
                            } icon: {
                                Image(systemName: "arrow.triangle.2.circlepath.icloud")
                                    .scaleEffect(0.9)
                            }
                        

                            Spacer()
                            Text(cloudStatus)
                        }
                    })

                    .task{
                        let status = await CloudKitManager.shared.getCloudStatus()
                        paw.dispatch_sync_safely_main_queue {
                            self.cloudStatus = status
                        }
                    }
                }
                
                Section(footer:Text(NSLocalizedString("exportHeader",comment: ""))) {
                    HStack{
                        Button {
                            
                            if RealmManager.shared.getObject()?.count ?? 0 > 0{
                                
                                self.showLoading = true
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
                                    self.exportJSON()
                                    self.showLoading = false
                                    self.isShareSheetPresented.toggle()
                                }
                               
                               
                            }else{
                                self.toastText = NSLocalizedString("nothingMessage", comment: "")
                                self.showLoading = false
                            }
                            
                            
                        } label: {
                            
                            Label {
                                Text(NSLocalizedString("exportTitle",comment: ""))
                            } icon: {
                                Image(systemName: "square.and.arrow.down")
                                    .scaleEffect(0.9)
                            }
                            
                            
                            
                            
                            

                        }
                        
                        Spacer()
                        Text(String(format: NSLocalizedString("someMessageCount",comment: ""), messages.count) )
                    }
                    
                }
             
                
                Section(footer:Text(NSLocalizedString("deviceTokenHeader",comment: ""))) {
                    Button{
                        if paw.deviceToken != ""{
                            paw.copy(text: paw.deviceToken)
                            
                            self.toastText = NSLocalizedString("copySuccessText", comment: "")
                         
                        }else{
                            self.toastText = NSLocalizedString("needRegister", comment: "")
                        }
                    }label: {
                        HStack{
                            
                            Label {
                                Text("DeviceToken")
                                    .font(.system(size: 15))
                                    .foregroundStyle(Color("textBlack"))
                            } icon: {
                                Image(systemName: "key.radiowaves.forward")
                                    .scaleEffect(0.9)
                            }


                           
                            Spacer()
                            Text(maskString(paw.deviceToken))
                                .foregroundStyle(.gray)
                            Image(systemName: "doc.on.doc")
                                .scaleEffect(0.9)
                        }
                    }
                }
                
                
                Section(header:Text(NSLocalizedString("configTitle", comment: "配置"))) {
                    Button{
                        pageView.sheetPage = .appIcon
                    }label: {
                        

                        HStack(alignment:.center){
                            Label {
                                Text(NSLocalizedString("AppIconTitle",comment: "程序图标"))
                                    .foregroundStyle(Color("textBlack"))
                            } icon: {
                                Image(setting_active_app_icon.toLogoImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .scaleEffect(0.9)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.gray)
                        }
                        
                    }
                

                    Picker(selection: paw.$badgeMode) {
                        Text(NSLocalizedString("badgeAuto",comment: "自动")).tag(badgeAutoMode.auto)
                        Text(NSLocalizedString("badgeCustom",comment: "自定义")).tag(badgeAutoMode.custom)
                    } label: {
                        Label {
                            Text(NSLocalizedString("badgeModeTitle",comment: "角标模式"))
                        } icon: {
                            Image(systemName: "app.badge")
                                .scaleEffect(0.9)
                        }
                    }
                    .onChange(of: paw.badgeMode) {value in
                        if value == .auto{
                            if let badge = RealmManager.shared.getUnreadCount(){
                                paw.changeBadge(badge:badge )
                            }
                        }else{
                            paw.changeBadge(badge: -1)
                        }
                    }

                    
                    
                    NavigationLink(destination:
                                    emailPageView() .toolbar(.hidden, for: .tabBar)
                    ) {
                        
                        Label {
                            Text(NSLocalizedString("mailTitle", comment: "自动化配置"))
                        } icon: {
                            Image(systemName: "paperclip")
                                .scaleEffect(0.9)
                        }
                    }
                    
                    
                    NavigationLink(destination: 
                                    CryptoConfigView()
                                        .toolbar(.hidden, for: .tabBar)
                    ) {
                        
                        
                        Label {
                            Text(NSLocalizedString("cryptoConfigNavTitle", comment: "算法配置") )
                        } icon: {
                            Image(systemName: "bolt.shield")
                                .scaleEffect(0.9)
                        }
                    }
                    
                    NavigationLink{
                        RingtongView()
                    }label: {
                        
                        Label {
                            Text(NSLocalizedString("musicConfigList", comment: "铃声列表") )
                        } icon: {
                            Image(systemName: "headphones.circle")
                                .scaleEffect(0.9)
                        }
                    }
                    
                    
                }
            

                Section(header:Text(NSLocalizedString("otherHeader",comment: ""))) {
                    
                   
                    Button{
                        paw.openSetting()
                    }label: {
                        HStack(alignment:.center){
                            
                            Label {
                                Text(NSLocalizedString("openSetting",comment: ""))
                                    .foregroundStyle(Color("textBlack"))
                            } icon: {
                                Image(systemName: "gearshape")
                                    .scaleEffect(0.9)
                                
                            }

                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.gray)
                        }
                        
                    }
                    
                    Button{
                        pageView.fullPage = .web
                        pageView.webUrl = otherUrl.problemWebUrl
                    }label: {
                        HStack(alignment:.center){
                            Label {
                                Text(NSLocalizedString("commonProblem",comment: ""))
                                    .foregroundStyle(Color("textBlack"))
                            } icon: {
                                Image(systemName: "questionmark.circle")
                                    .scaleEffect(0.9)
                            }

                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.gray)
                        }
                        
                    }
                    
                    Button{
                        pageView.webUrl = otherUrl.helpWebUrl
                        pageView.fullPage = .web
                        
                    }label: {
                        HStack(alignment:.center){
                            Label {
                                Text(NSLocalizedString("useHelpTitle",comment: ""))
                                    .foregroundStyle(Color("textBlack"))
                            } icon: {
                                Image(systemName: "person.crop.circle.badge.questionmark")
                                    .scaleEffect(0.9)
                            }

                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.gray)
                        }
                        
                        
                    }
                    
                    Button{
                        pageView.webUrl = otherUrl.issues
                        pageView.fullPage = .web
                        
                    }label: {
                        HStack(alignment:.center){
                            Label {
                                Text(NSLocalizedString("contactMe",comment: ""))
                                    .foregroundStyle(Color("textBlack"))
                            } icon: {
                                Image(systemName: "questionmark.circle")
                                    .scaleEffect(0.9)
                            }

                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.gray)
                        }
                        
                       

                    }
                   
                }
                
                // MARK: GITHUB
                if let infoDict = Bundle.main.infoDictionary,
                   let runId = infoDict["GitHub Run Id"] as? String
                {
                    Section(footer:Text(NSLocalizedString("buildDesc",comment: ""))){
                        Button{
                            if let infoDict = Bundle.main.infoDictionary,
                               let runId = infoDict["GitHub Run Id"] as? String{
                                pageView.webUrl = otherUrl.actinsRunUrl + runId
                                pageView.fullPage = .web
                            }
                            
                        }label:{
                            HStack{
                                Label {
                                    Text("Github Run Id")
                                } icon: {
                                    
                                    Image("github")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30)
                                        .scaleEffect(0.9)
                                }
                              
                                Spacer()
                                Text(runId)
                                    .foregroundStyle(.gray)
                                Image(systemName: "chevron.right")
                            }.foregroundStyle(Color("textBlack"))
                        }
                    }
                }
                
                
                
            }.listStyle(.insetGrouped)
                
            
        }
        .loading(showLoading)
        .toast(info: $toastText)
        .background(hexColor("#f5f5f5"))
        .toolbar {
            
            Group{
                if !paw.isNetworkAvailable && paw.notificationPermissionStatus.rawValue >= 2{
                    ToolbarItem (placement: .topBarLeading){
                        Button {
                            paw.openSetting()
                        } label: {
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
                              
                        }

                    }
                }
                
                if paw.notificationPermissionStatus.rawValue < 2 && paw.isNetworkAvailable {
                    
                    ToolbarItem (placement: .topBarLeading){
                        Button {
                            if paw.notificationPermissionStatus.rawValue == 0{
                                paw.registerForRemoteNotifications()
                            }else{
                                paw.openSetting()
                            }
                        } label: {
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
                            
                        }

                    }
                    
                    
                }
                
                if paw.notificationPermissionStatus.rawValue < 2 && !paw.isNetworkAvailable {
                    
                    ToolbarItem (placement: .topBarLeading){
                        Button {
                            if paw.notificationPermissionStatus.rawValue == 0{
                                paw.registerForRemoteNotifications()
                            }
                            paw.openSetting()
                        } label: {
                            
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
            }
            
           
            ToolbarItem {
     
                Button {
                    pageView.showServerListView.toggle()
                } label: {
                    Image(systemName: "externaldrive.badge.wifi")
                        .foregroundStyle(serverColor)
                }

            }
        
            
        }

        .sheet(isPresented: $isShareSheetPresented) {
            ShareSheet(activityItems: [self.jsonFileUrl!])
                .presentationDetents([.medium, .large])
        }
        .onAppear {
            DispatchQueue.global().async {
                Task{
                    let color = await paw.healthAllColor()
                    paw.dispatch_sync_safely_main_queue {
                        self.serverColor = color
                    }
                }
            }
        }
        .navigationDestination(isPresented: $pageView.showServerListView) {
            ServerListView()
                .toolbar(.hidden, for: .tabBar)
        }
       
        
        
    }
    func maskString(_ str: String) -> String {
        guard str.count > 6 else {
            return str
        }
        
        let start = str.prefix(3)
        let end = str.suffix(4)
        let masked = String(repeating: "*", count: 5) // 固定为5个星号
        
        return start + masked + end
    }
}

extension SettingView{
    
    
    func exportJSON() {
        do {
            let msgs = Array(messages)
            let jsonData = try JSONEncoder().encode(msgs)
            
            guard let jsonString = String(data: jsonData, encoding: .utf8),
                  let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else{
                
                self.toastText = NSLocalizedString("exportFail", comment: "")
               
                return
            }
            
            let fileURL = documentsDirectory.appendingPathComponent("messages.json")
            try jsonString.write(to: fileURL, atomically: false, encoding: .utf8)
            self.jsonFileUrl = fileURL
            self.toastText = NSLocalizedString("exportSuccess", comment: "")

#if DEBUG
            print("JSON file saved at: \(fileURL.absoluteString)")
#endif
            
            
           
           
        } catch {
            
            self.toastText = NSLocalizedString("exportFail", comment: "")
           
#if DEBUG
            print("Error encoding JSON: \(error.localizedDescription)")
#endif
           
        }
    }
    
    func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}


#Preview {
    NavigationStack{
        SettingView()
            .environmentObject(pawManager.shared)
            .environmentObject(pageState.shared)
            
    }
}

