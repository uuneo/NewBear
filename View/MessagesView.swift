//
//  MessagesView.swift
//  NewBear
//
//  Created by He Cho on 2024/4/4.
//

import SwiftUI
import RealmSwift
import Combine




struct MessageView: View {
    @EnvironmentObject var paw:pawManager
    @ObservedResults(NotificationMessage.self,
                     sortDescriptor: SortDescriptor(keyPath: "createDate",
                                                    ascending: false)) var messagesRaw
    @State private var showAction = false
    @State private var toastText = ""
    @State private var helpviewSize:CGSize = .zero
    @State private var showItems:Bool = false
    @State private var selectGroup:String = ""
    @State private var searchText:String = ""
    
    var messages:Results<NotificationMessage>{
        return createDatas(messagesRaw)
    }
    
    
    var body: some View {
        List {
        
            ForEach(messages,id: \.id){ message in
                Button {
                    withAnimation {
                        self.selectGroup = getGroup(message.group)
                        self.showItems.toggle()
                    }
                    RealmManager.shared.readMessage(messagesRaw.where({$0.group == message.group}))
                } label: {
                    LabeledContent {
                        VStack{
                            HStack{
                                
                                Text( getGroup(message.group) )
                                    .font(.title3.weight(.bold))
                                    .foregroundStyle(Color("textBlack"))
                                Spacer()
                                Text(message.createDate.agoFormatString())
                                    .font(.caption2)
                                Image(systemName: "chevron.forward")
                                    .font(.caption2)
                            }
                            
                            HStack{
                                Group {
                                    if let title = message.title{
                                        Text( "【\(title)】\(message.body ?? "")")
                                    }else{
                                        Text(message.body ?? "")
                                        
                                    }
                                }
                                .font(.footnote)
                                .lineLimit(2)
                                .foregroundStyle(.gray)
                                
                                Spacer()
                            }
                            
                            
                            
                            
                        }
                    } label: {
                        HStack{
                            HStack{
                                
                                if messagesRaw.where({!$0.isRead && $0.group == message.group}).count > 0{
                                    Circle()
                                        .fill(.blue)
                                        .frame(width: 10,height: 10)
                                }
                            }.frame(width: 10)
                            
                            VStack( spacing:10){
                                
                                Group{
                                    if let icon = message.icon,
                                       toolsManager.startsWithHttpOrHttps(icon){
                                        
                                        AsyncImageView(imageUrl: icon )
                                        
                                    }else{
                                        Image("logo")
                                            .resizable()
                                    }
                                }
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 45, height: 45, alignment: .center)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                                
                            }
                        }
                        .frame(minWidth: 60)
                    }
                    
                }
                .swipeActions(edge: .leading) {
                    Button {
                        let realm = RealmManager.shared
                        let alldata = realm.getObject()?.where({$0.group == message.group})
                        if let alldata = alldata{
                            let _ = realm.updateObjects(alldata) { data in
                                data?.isRead = true
                            }
                        }
                    } label: {
                        Label(NSLocalizedString("groupMarkRead",comment: ""), systemImage: "envelope")
                    }.tint(.blue)
                }
                
            }.onDelete(perform: { indexSet in
                for index in indexSet{
                    RealmManager.shared.delByGroup(getGroup(messages[index].group))
                }
            })
        }
        
        .listStyle(.plain)
        .navigationDestination(isPresented: $showItems) {
            MessageDetailView(groupName: self.selectGroup)
//                .navigationBarBackButtonHidden(true)
        }
       
        .toolbar{
            ToolbarItem {
                
                Button{
                    pageState.shared.fullPage = .example
                }label:{
                    Image(systemName: "questionmark.circle")
                    
                } .foregroundStyle(Color("textBlack"))
                    .accessibilityIdentifier("HelpButton")
            }
            
            ToolbarItem{
                Button{
                    self.showAction = true
                }label: {
                    Image("baseline_delete_outline_black_24pt")
                    
                }  .foregroundStyle(Color("textBlack"))
                
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic)){
            
            if let filterMessages = filterMessage(messagesRaw, searchText){
                Text( String(format: NSLocalizedString("findMessageCount" ,comment: "找到\(filterMessages.count)条数据"), filterMessages.count))
                    .foregroundStyle(.gray)
                ForEach(filterMessages,id: \.id){message in
                    MessageItem(message: message,searchText: searchText)
                }
            }else{
                Text( String(format: NSLocalizedString("findMessageCount" ,comment: "找到 0 条数据"), 0))
                    .foregroundStyle(.gray)
            }
        }
        .actionSheet(isPresented: $showAction) {
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
                .default(Text(NSLocalizedString("allMarkRead",comment: "")), action: {
                    deleteMessage( .markRead)
                }),
                .cancel()
                
            ])
        }
        .toast(info: $toastText)
    }
    
    
    
}




extension MessageView{
    
    func filterMessage(_ datas: Results<NotificationMessage>, _ searchText:String)-> Results<NotificationMessage>?{
        
        // 如果搜索文本为空，则返回原始数据
           guard !searchText.isEmpty else {
               return nil
           }

        return datas.filter("body CONTAINS[c] %@ OR title CONTAINS[c] %@ OR group CONTAINS[c] %@", searchText, searchText, searchText)
    }
    
    
    func deleteMessage(_ mode: mesAction){
        
        let realm = RealmManager.shared
        
        if realm.getObject()?.count == 0{
            self.toastText = NSLocalizedString("nothingMessage",comment: "")
            return
        }
        
        var date = Date()
        
        switch mode {
        case .allTime:
            let alldata = realm.getObject()
            let _ =  realm.deleteObjects(alldata)
            self.toastText =  NSLocalizedString("deleteAllMessage",comment: "")
            return
        case .markRead:
            
            let allData = realm.getObject()?.where({!$0.isRead})
            let _ = realm.updateObjects(allData) { data in
                data?.isRead = true
            }
            self.toastText =  NSLocalizedString("allMarkRead",comment: "")
            return
        case .lastHour:
            date = Date().someHourBefore(1)
        case .lastDay:
            date = Date().someDayBefore(0)
            
        case .lastWeek:
            date = Date().someDayBefore(7)
        case .lastMonth:
            date = Date().someDayBefore(30)
            
            
        }
        
        let alldata = realm.getObject()?.where({$0.createDate < date})
        
        let _ = realm.deleteObjects(alldata)
        
        self.toastText = NSLocalizedString("deleteSuccess",comment: "")
        
    }
    
    func createDatas(_ messages: Results<NotificationMessage>)-> Results<NotificationMessage> {
        var msgMap:[String:Bool] = [:]
        var ids:[String] = []
        for  message in messages{
            if let group = message.group{
                if msgMap[group] == nil{
                    if  let result = messages.where({$0.group == group}).sorted(by: [
                        SortDescriptor(keyPath: "createDate", ascending: false)
                    ]).first{
                        ids.append(result.id)
                    }
                    msgMap[group] = true
                }
            }
           
            
        }
        let results = messages.filter("id IN %@", ids)
        
        return results
    }
    
    
}







#Preview {
    NavigationStack{
        MessageView()
    }
    
}
