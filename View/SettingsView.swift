//
//  SettingsView.swift
//  NewBear
//
//  Created by He Cho on 2024/4/4.
//

import SwiftUI
import RealmSwift
import CloudKit


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

    
    @AppStorage("setting_active_app_icon") var setting_active_app_icon:appIcon = .def
    
    var timerz = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    var body: some View {
        
        VStack{
            List{
                if !paw.isNetworkAvailable{
                    Section(header:Text(
                        NSLocalizedString("settingNetWorkHeader",comment: "")
                    )) {
                        Button{
                            paw.openSetting()
                        }label: {
                            HStack{
                                Text(NSLocalizedString("settingNetWorkTitle",comment: ""))
                                    .foregroundStyle(Color("textBlack"))
                                Spacer()
                                Text(NSLocalizedString("openSetting",comment: ""))
                            }
                        }
                    }
                }
                
                if paw.notificationPermissionStatus.rawValue < 2 {
                    Section(header:Text(NSLocalizedString("notificationHeader",comment: ""))) {
                        Button{
                            if paw.notificationPermissionStatus.rawValue == 0{
                                paw.registerForRemoteNotifications()
                            }else{
                                paw.openSetting()
                            }
                        }label: {
                            HStack{
                                Text(NSLocalizedString("notificationTitle",comment: ""))
                                    .foregroundStyle(Color("textBlack"))
                                Spacer()
                                Text(paw.notificationPermissionStatus.rawValue == 0 ? NSLocalizedString("openNotification",comment: "") : NSLocalizedString("openSetting",comment: ""))
                            }
                        }
                    }
                }
                
                Section(header:Text(NSLocalizedString("serverConfig", comment: "配置/修改服务器")))  {
                    
                    Button {
                        pageView.showServerListView.toggle()
                    } label: {
                        HStack(alignment:.center){
                            Label {
                                Text(NSLocalizedString("serverList", comment: "服务器列表"))
                            } icon: {
                                Image(systemName: "server.rack")
                                    .scaleEffect(0.9)
                                    .foregroundStyle(serverColor)
                                    
                            }
                            Spacer()
                            Text("\(paw.servers.count)")
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.gray)
                        }
                    }

                }
                
                
                Section(header: Text("iCloud"),footer: Text(NSLocalizedString("icloudHeader",comment: ""))) {
                    NavigationLink(destination: {
                        cloudMessageView()
                    }, label: {
                        HStack{
                            Label {
                                Text(NSLocalizedString("icloudBody",comment: ""))
                                    
                            } icon: {
                                Image(systemName: "externaldrive")
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
                                self.toastText = NSLocalizedString("controlSuccess",comment: "")
                                // TODO: 这个位置有警告，暂时不清楚什么原因，不影响使用
                                self.exportJSON()
                                isShareSheetPresented = true
                            }else{
                                self.toastText = NSLocalizedString("nothingMessage",comment: "")
                            }
                            
                            
                        } label: {
                            Label(NSLocalizedString("exportTitle",comment: ""), systemImage: "square.and.arrow.down")
                        }
                        
                        Spacer()
                        Text(String(format: NSLocalizedString("someMessageCount",comment: ""), messages.count) )
                    }
                    
                }
             
                
                Section(footer:Text(NSLocalizedString("deviceTokenHeader",comment: ""))) {
                    Button{
                        if paw.deviceToken != ""{
                            paw.copy(text: paw.deviceToken)
                            self.toastText = NSLocalizedString("copySuccessText",comment: "")
                        }else{
                            self.toastText =  NSLocalizedString("needRegister",comment: "")
                        }
                    }label: {
                        HStack{
                            Label {
                                Text("DeviceToken")
                                    .font(.system(size: 15))
                                    .foregroundStyle(Color("textBlack"))
                            } icon: {
                                Image(systemName: "key.radiowaves.forward")
                            }

                           
                            Spacer()
                            Text(maskString(paw.deviceToken))
                                .foregroundStyle(.gray)
                            Image(systemName: "doc.on.doc")
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
                                if let index = appIcon.arr.firstIndex(where: {$0 == setting_active_app_icon}){
                                    Image(logoImage.arr[index].rawValue)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 25)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }else{
                                    Image("logo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 25)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
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

                    
                    
                    NavigationLink(destination:  emailPageView()) {
                        
                        Label {
                            Text(NSLocalizedString("mailTitle", comment: "自动化配置"))
                        } icon: {
                            Image(systemName: "paperclip")
                        }
                    }
                    
                    
                    NavigationLink(destination: CryptoConfigView()) {
                        
                        
                        Label {
                            Text(NSLocalizedString("cryptoConfigNavTitle", comment: "算法配置") )
                        } icon: {
                            Image(systemName: "bolt.shield")
                        }
                    }
                    
                    NavigationLink{
                        RingtongView()
                    }label: {
                        
                        Label {
                            Text(NSLocalizedString("musicConfigList", comment: "铃声列表") )
                        } icon: {
                            Image(systemName: "headphones.circle")
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
        .toast(info: $toastText)
        .background(hexColor("#f5f5f5"))
        .toolbar {
            
            ToolbarItem {
                Button {
                    pageView.fullPage = .scan
                } label: {
                    Image(systemName: "qrcode.viewfinder")
                }

            }
        
            
        }

        .sheet(isPresented: $isShareSheetPresented) {
            ShareSheet(activityItems: [self.jsonFileUrl!])
                .presentationDetents([.medium, .large])
        }
        .onReceive(self.timerz) { _ in
            Task{
                let color = await paw.healthAllColor()
                paw.dispatch_sync_safely_main_queue {
                    self.serverColor = color
                }
            }
        }

        .navigationDestination(isPresented: $pageView.showServerListView) {
            ServerListView()
        }
        .task {
            let color = await paw.healthAllColor()
            paw.dispatch_sync_safely_main_queue {
                self.serverColor = color
            }
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
                self.toastText = NSLocalizedString("exportFail",comment: "")
                return
            }
            
            let fileURL = documentsDirectory.appendingPathComponent("messages.json")
            try jsonString.write(to: fileURL, atomically: false, encoding: .utf8)
            self.jsonFileUrl = fileURL
            self.toastText = NSLocalizedString("exportSuccess",comment: "")
#if DEBUG
            print("JSON file saved at: \(fileURL.absoluteString)")
#endif
           
        } catch {
            self.toastText = NSLocalizedString("exportFail",comment: "")
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
    }
}

