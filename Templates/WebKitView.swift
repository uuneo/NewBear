//
//  WebKitView.swift
//  NewBear
//
//  Created by He Cho on 2024/4/4.
//

import SwiftUI
import WebKit

// 这里我理解是把 WebKit 里面的 WkWebView 转成了 SwiftUI可以使用的View类型
struct WebKitViewTable:UIViewRepresentable{
    
    let webview:WKWebView;
    
    // 当然也可以直接在这个方法里面初始化 WKWebView，但是这样的话就拿不到操作句柄了
    // 不方便后续操作
    func makeUIView(context: Context) -> WKWebView {
        return webview;
    }
    // 这两个方法都是 UIViewRepresentable 里面规定的
    func updateUIView(_ uiView: WKWebView, context: Context) {
        
    }
}



// 显示webview的页面
struct WebKitView:View{
    // 数据模型使用
    @State var url:String = otherUrl.helpWebUrl
    
    
    var webview:WKWebView{
        get{
            let web = WKWebView(frame: .zero)
            web.load(URLRequest(url: URL(string: url)!))
            return web
        }
    }
    
    
    var body: some View{
        VStack{
            WebKitViewTable(webview: webview)
        }.ignoresSafeArea()
        .navigationBarBackButtonHidden()
    }
}

