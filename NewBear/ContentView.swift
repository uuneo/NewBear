//
//  ContentView.swift
//  NewBear
//
//  Created by He Cho on 2024/4/9.
//

import SwiftUI
import RealmSwift

struct ContentView: View {
    
    @EnvironmentObject var paw: pawManager
    @EnvironmentObject var pageView:pageState
    @ObservedResults(NotificationMessage.self) var messages
    
    var readCount:Int{
        messages.where({!$0.isRead}).count
    }
    
    @State private var hiddenBar:Bool = false
    
    @State var toastText:String = ""
    var body: some View {
        
            
            
            TabView(selection: $pageView.page) {
               
                // MARK: 信息页面
                NavigationStack{
                    MessageView()
                        
                        .navigationTitle(NSLocalizedString("bottomBarMsg",comment: ""))
                }
                
                .tag(pageState.tabPage.message)
                .badge(readCount)
                .tabItem {
                    Label(NSLocalizedString("bottomBarMsg",comment: ""), systemImage: "ellipsis.message")
                }
                // MARK: 设置页面
                NavigationStack{
                    SettingView()
                        
                        .navigationTitle(NSLocalizedString("bottomBarSettings",comment: ""))
                }
               
                .tabItem {
                    Label(NSLocalizedString("bottomBarSettings",comment: ""), systemImage: "gearshape")
                }
                .tag(pageState.tabPage.setting)
               
               
                
            
        }
            
            .toast(info: $toastText)
            // MARK: sheet
            .sheet(isPresented: pageState.shared.sheetPageShow){
                switch pageState.shared.sheetPage {
                case .servers:
                    ServerListView(showClose: true)
                case .appIcon:
                    NavigationStack{
                        pawAppIconView()
                    }.presentationDetents([.medium])
                    
                case .web:
                    SFSafariViewWrapper(url: pageState.shared.webUrl)
                        .ignoresSafeArea()
                default:
                    EmptyView()
                }
            }
            // MARK: full
            .fullScreenCover(isPresented: pageState.shared.fullPageShow){
                switch pageState.shared.fullPage {
                case .login:
                    LoginView(registerUrl: pageState.shared.scanUrl)
                case .servers:
                    ServerListView(showClose: true)
                case .example:
                    CustomHelpView()
                case .music:
                    RingtongView()
                case .scan:
                    ScanView { code, mode in
                        if mode == 0 {
                            let (mode1,msg) = paw.addServer(url: code)
                            self.toastText = msg
                            if mode1{
                                //                            pageView.sheetPage = .servers
                                pageView.fullPage = .none
                                pageView.sheetPage = .none
                                pageView.page = .setting
                                pageView.showServerListView = true
                            }
                        }else if mode == 1{
                            pageView.scanUrl = code
                            pageView.fullPage = .login
                        }
                    }
                case .web:
                    SFSafariViewWrapper(url: pageState.shared.webUrl)
                        .ignoresSafeArea()
                case .issues:
                    SFSafariViewWrapper(url: pageState.shared.webUrl)
                        .ignoresSafeArea()
                default:
                    EmptyView()
                }
            }
            
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                
                let messageNotCloud = messages.where({!$0.cloud})
                
                if messageNotCloud.count > 0 || true {
                    Task{
                        let result = await CloudKitManager.shared.uploadCloud(Array(messageNotCloud))
                        do{
                            let realm = try await Realm()
                            try realm.write{
                                for message in result{
                                    if let thawedObject = message.thaw(){
                                        thawedObject.cloud = true
                                    }
                                    
                                }
                            }
                        }catch{
#if DEBUG
                            print(error)
#endif
                            
                        }
                    }
                }
                else{
#if DEBUG
                    print("没有数据")
#endif
                }
                
                
            }
       
    }
    
    
    
}

#Preview {
    ContentView().environmentObject(pawManager.shared)
}
