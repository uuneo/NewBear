//
//  CustomHelpView.swift
//  NewBear
//
//  Created by He Cho on 2024/4/4.
//

import SwiftUI
import UIKit

struct CustomHelpView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.scenePhase) var phase
    @EnvironmentObject var paw:pawManager
    @State var username:String = ""
    @State var title:String = ""
    @State  var pickerSeletion:Int = 0
    @State var toastText = ""
    @State private var showAlart = false
    var body: some View {
        NavigationStack{

            List{
                
                HStack{
                    Spacer()
                    Picker(selection: $pickerSeletion, label: Text(NSLocalizedString("changeServer",comment: ""))) {
                        ForEach(paw.servers.indices, id: \.self){index in
                            let server = paw.servers[index]
                            Text(server.name).tag(server.id)
                        }
                    }.pickerStyle(MenuPickerStyle())
                       
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                
                customHelpItemView
               
                
            }.listStyle(GroupedListStyle())
            .navigationTitle(NSLocalizedString("useExample",comment: ""))
                .toolbar{
                    ToolbarItem {
                        NavigationLink{
                            RingtongView()
                           
                        }label: {
                            Image(systemName: "headphones.circle")
                                .foregroundStyle(Color.gray)
                        }
                    }
                    
                    
                    ToolbarItem{
                        Button{
                            dismiss()
                        }label: {
                            Image(systemName: "xmark.seal")
                                .foregroundStyle(Color.gray)
                        }
                    }
                }
                .toast(info: $toastText)
        }
    }
}



#Preview {
    
    CustomHelpView().environmentObject(pawManager.shared)
    
}





extension CustomHelpView{
    private var customHelpItemView:some View{
       
        ForEach(pushExample.datas,id: \.id){ item in
            let resultUrl = paw.servers[pickerSeletion].url + "/" + paw.servers[pickerSeletion].key + "/" + item.params
            Section(
                header:Text(item.header),
                footer: Text(item.footer)
            ) {
                HStack{
                    Text(item.title)
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                    Image(systemName: "doc.on.doc")
                        .padding(.horizontal)
                        .onTapGesture {
                            UIPasteboard.general.string = resultUrl
                            
                          
                            self.toastText = NSLocalizedString("copySuccessText", comment:  "复制成功")
                            
                          
                        }
                    Image(systemName: "safari")
                        .onTapGesture {
                            Task{
                                let ok =  await  paw.health(url: paw.servers[pickerSeletion].url + "/health" )
                                paw.dispatch_sync_safely_main_queue {
                                    if ok{
                                        if let url = URL(string: resultUrl){
                                            
                                            UIApplication.shared.open(url)
                                            self.dismiss()
                                        }
                                    }else{
                    
                                        self.toastText = NSLocalizedString("offline", comment:  "复制成功")
                                        
                                    }
                                }
                            }
                            
                        }
                }
                Text(resultUrl).font(.caption)
            }
        }
       
    }
}
