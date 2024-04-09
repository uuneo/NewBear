//
//  addServerView.swift
//  NewBear
//
//  Created by He Cho on 2024/4/4.
//

import SwiftUI

struct addServerView: View {
    @EnvironmentObject var paw:pawManager
    @Environment(\.dismiss) var dismiss
    @FocusState var editServer:Bool
    @State var serverName:String = ""
    @State private var pickerSelect:requestHeader = .https
    @State private var toastText:String = ""
    var body: some View {
        VStack{
           
            LabeledContent {
                TextField(NSLocalizedString("inputServerAddress",comment: ""), text: $serverName)
                    .focused($editServer)
               
            } label: {
                Picker(selection: $pickerSelect) {
                    Text(requestHeader.http.rawValue).tag(requestHeader.http)
                    Text(requestHeader.https.rawValue).tag(requestHeader.https)
                }label: {
                    Text("")
                }
                
                .pickerStyle(.menu)
               
            }.padding(.vertical)
            Divider()
            Spacer()
            HStack{
                Button{
                    pageState.shared.webUrl = otherUrl.delpoydoc
                    pageState.shared.fullPage = .web
                }label: {
                    Text(NSLocalizedString("checkServerDeploy",comment: ""))
                        .font(.caption2)
                }
                
                Spacer()
                Button{
                    if self.addServer(url: serverInfo.serverDefault.url){
                        self.dismiss()
                    }
                }label: {
                    Text(NSLocalizedString("recoverDefaultServer",comment: ""))
                        .font(.caption2)
                }
            }
            

        }.padding()
            .toast(info: $toastText)
            .navigationTitle(NSLocalizedString("addNewServerListAddress",comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                
                ToolbarItem(placement: .topBarLeading) {
                    Button{
                        self.dismiss()
                    }label: {
                        Image(systemName: "xmark.circle")
                    }.tint(Color("textBlack"))
                }
                
                ToolbarItem {
                    Button{
                        if self.addServer(url:pickerSelect.rawValue + serverName){
                            self.dismiss()
                        }
                    }label: {
                        Image(systemName: "checkmark.circle")
                    }
                    .tint(Color("textBlack"))
                }
            }
          
    }
    func addServer(url: String)-> Bool{
       
        if !toolsManager.startsWithHttpOrHttps(url){
            self.toastText = NSLocalizedString("verifyFail",comment: "")
            return false
        }
        
        let count = paw.servers.filter({$0.url == url}).count
        
        if count == 0{
            if serverInfo.serverDefault.url == url {
                paw.servers.insert(serverInfo(url: url, key: ""), at: 0)
            }else{
                paw.servers.append(serverInfo(url: url, key: ""))
            }
            self.toastText = NSLocalizedString("addSuccess",comment: "")
        }else{
            self.toastText =  NSLocalizedString("serverExist",comment: "")
            return false
        }
        
        Task(priority: .userInitiated) {
            await paw.registerAll()
        }
        
        return true
    }
}

enum requestHeader :String {
    case https = "https://"
    case http = "http://"
}


#Preview {
    NavigationStack{
        addServerView().environmentObject(pawManager.shared)
    }
  
}
