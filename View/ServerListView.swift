//
//  ServerListView.swift
//  NewBear
//
//  Created by He Cho on 2024/4/4.
//

import SwiftUI

struct ServerListView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var paw:pawManager
    @EnvironmentObject var pageView:pageState
    @State private var showAction:Bool = false
    @State private var isEditing:EditMode = .inactive
    @State private var toastText:String = ""
    @State private var serverText:String = ""
    @State private var serverName:String = ""
    @State private var pickerSelect:requestHeader = .https
    var showClose:Bool = false
    
    var body: some View {
        NavigationStack{
            VStack{
               
                List{
                    
                    
                    
                    if isEditing == .active{
                        Section {
                            TextField(NSLocalizedString("inputServerAddress",comment: ""), text: $serverName)
                                .textContentType(.flightNumber)
                                .keyboardType(.URL)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .padding(.leading, 100)
                                .overlay{
                                    HStack{
                                        Picker(selection: $pickerSelect) {
                                            Text(requestHeader.http.rawValue).tag(requestHeader.http)
                                            Text(requestHeader.https.rawValue).tag(requestHeader.https)
                                        }label: {
                                           Text("")
                                        } .pickerStyle(.automatic)
                                            .frame(maxWidth: 100)
                                            .offset(x:-30)
                                        Spacer()
                                    }
                                }

                        }header: {
                            Text(NSLocalizedString("addNewServerListAddress",comment: ""))
                        }footer: {
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
                                    
                                    
                                    let (success,_) = pawManager.shared.addServer(url: serverInfo.serverDefault.url)
                                    if success{
                                        self.dismiss()
                                    }
                                }label: {
                                    Text(NSLocalizedString("recoverDefaultServer",comment: ""))
                                        .font(.caption2)
                                }
                            }.padding(.vertical)
                        }
                        
                       
                    }else{
                        Button {
                            pageView.fullPage = .login
                        } label: {
                            HStack{
                                Spacer()
                                Label(NSLocalizedString("replaceKeyWithMail", comment: " 替换key为邮件"), systemImage: "pencil")
                                Spacer()
                            }
                        }
                    }
                    
                   
                    ForEach(paw.servers,id: \.id){item in
                        HStack(alignment: .center){
                            Image(item.status ? "online": "offline")
                                .padding(.horizontal,5)
                            VStack{
                                HStack(alignment: .bottom){
                                    Text(NSLocalizedString("serverName",comment: "") + ":")
                                        .font(.system(size: 10))
                                        .frame(width: 40)
                                    Text(item.name)
                                        .font(.headline)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                    Spacer()
                                }
                                
                                HStack(alignment: .bottom){
                                    Text("KEY:")
                                        .frame(width:40)
                                    Text(item.key)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                    Spacer()
                                } .font(.system(size: 10))
                                
                            }
                            Spacer()
                            Image(systemName: "doc.on.doc")
                                .onTapGesture{
                                    self.toastText = NSLocalizedString("copySuccessText", comment: "")
                                    paw.copy(text: item.url + "/" + item.key)
                                }
                            
                        }
                        .padding(.vertical,5)
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button{
                                Task{
                                    await paw.register(server: item)
                                }
                                self.toastText = NSLocalizedString("controlSuccess", comment: "")
                            }label: {
                                Text(NSLocalizedString("registerAndCheck",comment: ""))
                            }.tint(.blue)
                        }
                        .swipeActions(edge: .leading) {
                            Button{
                                
                                if let index = paw.servers.firstIndex(where: {$0.id == item.id}){
                                    paw.servers[index].key = ""
                                }
                                
                                Task{
                                    await paw.register(server: item)
                                }
                                self.toastText = NSLocalizedString("controlSuccess", comment: "")
                                
                            }label: {
                                Text(NSLocalizedString("resetKey",comment: "重置Key"))
                            }.tint(.red)
                        }
                    }
                    .onDelete(perform: { indexSet in
                        if isEditing == .active{
                            if paw.servers.count > 1{
                                paw.servers.remove(atOffsets: indexSet)
                            }else{
                                self.toastText =  NSLocalizedString("needOneServer", comment: "")
                            }
                        }else{
                            self.toastText = NSLocalizedString("editingtips", comment: "编辑状态")
                        }
                    })
                    .onMove(perform: { indices, newOffset in
                        paw.servers.move(fromOffsets: indices, toOffset: newOffset)
                    })

                    
                }
                .refreshable {
                    await paw.registerAll()
                }
                
            }
            .listRowSpacing(20)
            .toast(info: $toastText)
            
                .toolbar{
                    
                    ToolbarItem {
                        Button {
                            pageView.fullPage = .scan
                        } label: {
                            Image(systemName: "qrcode.viewfinder")
                        }

                    }
                
                    ToolbarItem {
                        EditButton()
                    }
                   
                    
                    if showClose {
                       
                        ToolbarItem{
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "xmark.seal")
                            }

                        }
                    }
                }
                .environment(\.editMode, $isEditing)
                .navigationTitle(NSLocalizedString("serverList",comment: ""))
            
                .onChange(of: isEditing) { value in
                    
                    if value == .inactive && serverName.count > 0{
                        let (_, toast) =  pawManager.shared.addServer(pickerSelect.rawValue, url: serverName)
                        self.toastText = toast
                        self.serverName = ""
                    }
                   
                }
            
        }
    }

    
}



#Preview {
    NavigationStack{
        ServerListView().environmentObject(pawManager.shared)
            .environmentObject(pageState.shared)
    }
}
