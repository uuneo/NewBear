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
    @State var showAction:Bool = false
    @State var toastText:String = ""
    @State var addMode:Bool = false
    var showClose:Bool = false
    var body: some View {
        NavigationStack{
            serverList
                .toolbar{
                    ToolbarItem {
                        Button{
                            self.addMode.toggle()
                        }label:{
                            Image(systemName: "plus")
                                .tint(Color("textBlack"))
                        }
                        .padding(.horizontal)
                        
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
                .sheet(isPresented: $addMode, content: {
                    NavigationStack{
                        addServerView()
                    } .presentationDetents([.medium, .large])
                })
                .navigationTitle(NSLocalizedString("serverList",comment: ""))
            
        }
    }
    
}

extension ServerListView{
    private var serverList:some View{
        VStack{
           
            List{
                    
                ForEach(paw.servers,id: \.id){item in
                    Section {
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
                                    Spacer()
                                }
                                
                                HStack(alignment: .bottom){
                                    Text("KEY:")
                                        .frame(width:40)
                                    Text(item.key)
                                    Spacer()
                                } .font(.system(size: 10))
                                
                            }
                            Spacer()
                            Image(systemName: "doc.on.doc")
                                .onTapGesture{
                                    toolsManager.async_set_localString( "copySuccessText") { text in
                                        self.toastText = text
                                    }
                                    paw.copy(text: item.url + "/" + item.key)
                                }
                            
                        }
                        .padding(.vertical,5)
                        
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button{
                                Task{
                                    await paw.register(server: item)
                                }
                                toolsManager.async_set_localString("controlSuccess") { text in
                                    self.toastText = text
                                }
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
                                
                                toolsManager.async_set_localString("controlSuccess") { text in
                                    self.toastText = text
                                }
                                
                            }label: {
                                Text(NSLocalizedString("resetKey",comment: "重置Key"))
                            }.tint(.red)
                        }
                    } header: {
                        HStack{
                            Text(item.status ? NSLocalizedString("online",comment: "") : NSLocalizedString("offline",comment: ""))
                            Spacer()
//                            Text(NSLocalizedString("serverOnlineFooter",comment: ""))
                        }
                       
                    }
                    
                }
                .onDelete(perform: { indexSet in
                    if paw.servers.count > 1{
                        paw.servers.remove(atOffsets: indexSet)
                    }else{
               
                        toolsManager.async_set_localString("needOneServer") { text in
                            self.toastText = text
                        }
                    }
                    
                })

                
            }
            .refreshable {
                await paw.registerAll()
            }
            
        }.toast(info: $toastText)
    }
}



#Preview {
    NavigationStack{
        ServerListView().environmentObject(pawManager.shared)
    }
}
