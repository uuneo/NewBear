//
//  MessageItem.swift
//  NewBear
//
//  Created by He Cho on 2024/4/4.
//

import SwiftUI
import RealmSwift
import UIKit
import MarkdownUI
import Combine




struct MessageItem: View {
    @ObservedRealmObject var message:NotificationMessage
    @EnvironmentObject var paw:pawManager
  
    @State private var toastText:String = ""
    @State private var showMark:Bool = false
    @State private var textHeight: CGFloat = .zero
    var searchText:String = ""
    var body: some View {
        
        Section {
            Grid{
                if showMark{
                    GridRow(alignment: .center) {
                        logoView
                            .transition(.scale)
                            
                    }
                    .gridCellColumns(2)
                }
               
                
                
                GridRow {
                    if !showMark{
                        logoView
                            .transition(.scale)
                            
                    }
                    
                    ZStack(alignment: .topLeading){
                        VStack{
                            HStack{
                                Spacer()
                                Image(systemName: "bolt.horizontal.icloud.fill")
                                    .foregroundStyle(message.cloud ? .green : .pink)
                                    .font(.caption)
                                
                                
                            }
                            Spacer()
                        }
                        
                        VStack(alignment: .leading, spacing:5){
                            
               
                            if let title = message.title{
                                highlightedText(searchText: searchText, text: title)
                                    .font(.system(.headline))
                                    
                                Divider()
                            }
                    
                            if let body = message.body{
                                highlightedText(searchText: searchText, text: body)
                                    .font(.subheadline)
                            }
               
                            Spacer()
                            
                            if let markdownText = message.markdown{
                                VStack{
                                    
                                    HStack(alignment: .center){
                                        Spacer()
                                        Image(systemName: showMark ? "m.circle.fill" : "m.circle")
                                            .foregroundStyle(.primary)
                                            .onTapGesture {
                                                withAnimation(Animation.bouncy){
                                                    self.showMark.toggle()
                                                }
                   
                                            }
                                        
                                    }
                                    
                                    
                                    VStack{
                                        Divider()
                                            .scaleEffect(showMark ? 1 : 0)
                                            
                                        ScrollView {
                                            
                                            HStack{
                                                Markdown(markdownText)
                                                    .opacity(showMark ? 1 : 0)
                                                    .scaleEffect(showMark ? 1 : 0)
                                                    
                                                
                                                Spacer()
                                            }
                                            
                                        }
                                        
                                        
                                    }
                                    .frame(height: showMark ? min(calculateTextHeight(text: markdownText) + 10, 300) : 0)
                                    
                                    
                                }
                                
                            }
                        }
                            .padding(.leading)
  
                        
                    }
                }
                .gridCellColumns(showMark ? 2 : 1)
                
                
            }
            .toast(info: $toastText)
            .padding(.horizontal, 10)
            .padding(.top, 10)
        }header: {
            HStack{
                Spacer()
                Text(message.createDate.agoFormatString())
                    .font(.caption2)
                    
                
            }
            
        }
        
        
        
    }
    
    private func calculateTextHeight(text: String) -> CGFloat {
        let font = UIFont.preferredFont(forTextStyle: .body)
        let boundingSize = CGSize(width: UIScreen.main.bounds.size.width - 32, height: .greatestFiniteMagnitude)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes = [NSAttributedString.Key.font: font]
        let boundingRect = NSString(string: text).boundingRect(with: boundingSize, options: options, attributes: attributes, context: nil)
        
        return boundingRect.height
    }
}

extension MessageItem{
    var logoView: some View{
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
            .frame(width: 35, height: 35, alignment: .center)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(alignment: .topTrailing) {
                if let _ =  message.url {
                    Image(systemName: "link")
                        .foregroundStyle(.green)
                        .offset(x:5 , y: -5)
                }
            }
            
            highlightedText(searchText: searchText, text: limitTextToLines(message.group ?? "", charactersPerLine: 10) )
                .font(.system(size:10))
                .foregroundStyle(message.isRead ? .gray : .red)

               
            
        }.onTapGesture {
            if let url =  message.url{
                let _ = RealmManager.shared.updateObject(message) { item2 in
                    item2.isRead = true
                }
                paw.openUrl(url: url)
            }
            
        }
    }
    
    func highlightedText(searchText:String, text:String) -> some View {
        guard let range = text.range(of: searchText) else {
            return Text(text)
        }
        
        let startIndex = text.distance(from: text.startIndex, to: range.lowerBound)
        let endIndex = text.distance(from: text.startIndex, to: range.upperBound)
        let prefix = Text(text.prefix(startIndex))
        let highlighted = Text(text[text.index(text.startIndex, offsetBy: startIndex)..<text.index(text.startIndex, offsetBy: endIndex)]).bold().foregroundColor(.red)
        let suffix = Text(text.suffix(text.count - endIndex))
        
        return prefix + highlighted + suffix
    }
}

extension MessageItem{
    func limitTextToLines(_ text: String, charactersPerLine: Int) -> String {
        var result = ""
        var currentLineCount = 0
        
        for char in text {
            result.append(char)
            if char.isNewline || currentLineCount == charactersPerLine {
                result.append("\n")
                currentLineCount = 0
            } else {
                currentLineCount += 1
            }
        }
        
        return result
    }
}



#Preview {
    List {
        MessageItem(message: NotificationMessage(value: [ "id":"123","title":"123","isRead":true,"icon":"error","group":"123","image":"https://day.app/assets/images/avatar.jpg","body":"123","cloud":true]))
            .frame(width: 300)
            .environmentObject(pawManager.shared)
    }.listStyle(GroupedListStyle())
}

