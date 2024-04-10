//
//  CloudMessageView.swift
//  NewBear
//
//  Created by He Cho on 2024/4/4.
//

import SwiftUI

struct cloudMessageView: View {
    @EnvironmentObject var paw:pawManager
    @State var toastText = ""
    @State var messages:[NotificationMessage] = []
    @State var imageID:String = ""
    @State var showLoading = false
    @State private var jsonFileUrl:URL?
    @State private var isShareSheetPresented = false
    @State private var deleteMode:Bool = false
    var body: some View {
        List{
            
            HStack{
                Spacer()
                Text(String(format: NSLocalizedString("someMessageCount", comment: "多少条消息"), paw.cloudCount))
                    .font(.system(size: 16))
                    
            }.listRowBackground(Color.clear)
            
            if messages.count == 0 && !showLoading{
                HStack{
                    Spacer()
                    Text(NSLocalizedString("notData",comment: ""))
                    Spacer()
                }.frame(height: 300)
                    .padding()
                    .listRowBackground(Color.clear)
                
            }
            
            ForEach(messages, id: \.id){item in
                MessageItem(message: item)
            }.onDelete(perform: { indexSet in
                Task{
                    await self.deleteMessageOne(indexSet)
                }
            })
        }
    
        .task {
           await self.setMessage()
        }
        .toast(info: $toastText)
        .loading(showLoading)
        .navigationTitle(NSLocalizedString("cloudData",comment: ""))
        .toolbar{
            ToolbarItem {
                if messages.count > 0{
                    Button{
                        self.showLoading = true
                        if messages.count > 0{
                            self.exportJSON()
                            self.isShareSheetPresented = true
                        }else{
                            toolsManager.async_set_localString("notData") { text in
                                self.toastText = text
                            }
                           
                        }
                        self.showLoading = false
                    }label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
               
            }
            ToolbarItem {
                if messages.count > 0{
                    Button{
                        deleteMode = true
                    }label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .actionSheet(isPresented: $deleteMode) {
            ActionSheet(title: Text(NSLocalizedString("deleteTimeMessage",comment: "")),buttons: [
                .destructive(Text(NSLocalizedString("allTime",comment: "")), action: {
                    deleteMessage(.allTime)
                }),
                .destructive(Text(NSLocalizedString("monthAgo",comment: "")), action: {
                    deleteMessage( .lastMonth)
                }),
                .destructive(Text(NSLocalizedString("weekAgo",comment: "")), action: {
                    deleteMessage( .lastWeek)
                }),
                .destructive(Text(NSLocalizedString("dayAgo",comment: "")), action: {
                    deleteMessage( .lastDay)
                }),
                .destructive(Text(NSLocalizedString("hourAgo",comment: "")), action: {
                    deleteMessage( .lastHour)
                }),
                .cancel()
                
            ])
        }
        .sheet(isPresented: $isShareSheetPresented) {
            ShareSheet(activityItems: [self.jsonFileUrl!])
                .presentationDetents([.medium, .large])
        }
    
    }
    
    
    func deleteMessageOne(_ index: IndexSet) async {
        
        for index2 in index{
           
            let itemId  = messages[index2].id
            let res = await  CloudKitManager.shared.deleteMessage(itemId)
            
            toolsManager.async_set_localString( res ? "deleteSuccess" :"deleteFail") { text in
                self.toastText = text
            }
            
            if res{
                messages.remove(atOffsets: index)
            }
        }

    }
    func deleteMessage(_ mode: mesAction){
        self.showLoading = true
        var date:Date = Date()
        
        switch mode {
        case .lastHour:
            date = Date().someHourBefore(1)
        case .lastDay:
            date = Date().someDayBefore(0)
        case .lastWeek:
            date = Date().someDayBefore(7)
        case .lastMonth:
            date = Date().someDayBefore(30)
        default:
            date = Date()
        }
        
        let allDataID = messages.filter({$0.createDate < date}).map({$0.createCKRecord().recordID})
        
        Task{
            let res = await CloudKitManager.shared.deleteRecordsConcurrently(recordIDs: allDataID)
            await self.setMessage()
            paw.dispatch_sync_safely_main_queue {
                self.showLoading = false
               
                self.toastText = res ? NSLocalizedString("deleteSuccess",comment: "") : NSLocalizedString("deleteFail",comment: "")
            }
        }
        
        
    }
    
    func setMessage()async {
        pawManager.shared.dispatch_sync_safely_main_queue {
            self.showLoading = true
           
        }
        do{
            let messages = try await  CloudKitManager.shared.fetchAllMessages()
            pawManager.shared.dispatch_sync_safely_main_queue {
                self.messages = messages
                paw.cloudCount = messages.count
            }
        }
        catch{
#if DEBUG
            print(error)
            
            
            toolsManager.async_set_localString( "getFail") { text in
                self.toastText = text
            }
#endif
           
            
        }
        
        pawManager.shared.dispatch_sync_safely_main_queue {
            self.showLoading = false
        }
        
        
    }
    
    func exportJSON() {
        do {
            let msgs = Array(messages)
            let jsonData = try JSONEncoder().encode(msgs)
            
            guard let jsonString = String(data: jsonData, encoding: .utf8),
                  let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else{
                
                toolsManager.async_set_localString("exportFail") { text in
                    self.toastText = text
                }
               
                return
            }
            
            let fileURL = documentsDirectory.appendingPathComponent("messages.json")
            try jsonString.write(to: fileURL, atomically: false, encoding: .utf8)
            self.jsonFileUrl = fileURL
            
            toolsManager.async_set_localString("exportSuccess") { text in
                self.toastText = text
            }

#if DEBUG
            print("JSON file saved at: \(fileURL.absoluteString)")
#endif
           
        } catch {
            toolsManager.async_set_localString("exportFail") { text in
                self.toastText = text
            }

#if DEBUG
            print("Error encoding JSON: \(error.localizedDescription)")
#endif
           
        }
    }
    
    
}

#Preview {
    NavigationStack{
        cloudMessageView().environmentObject(pawManager.shared)
    }
    
}
