//
//  PageState.swift
//  NewBear
//
//  Created by He Cho on 2024/4/4.
//

import SwiftUI


class pageState: ObservableObject{
    static let shared = pageState()
    private init() {}
    
    enum pageModal{
        case login
        case servers
        case scan
        case example
        case music
        case appIcon
        case web
        case issues
        case none
    }

    enum tabPage :String{
        case message = "message"
        case setting = "setting"
    }
    
    @Published var page:tabPage = .message
    
    @Published var sheetPage:pageModal = .none
    @Published var fullPage:pageModal = .none
    @Published var webUrl:String = ""
    @Published var scanUrl:String = ""
    
    
    @Published var showServerListView:Bool = false
    
    var fullPageShow:Binding<Bool>{
        Binding {
            self.fullPage != .none
        } set: { value in
            if !value {
                self.fullPage = .none
            }
        }
    }
    
    var sheetPageShow:Binding<Bool>{
        Binding {
            self.sheetPage != .none
        } set: { value in
            if !value {
                self.sheetPage = .none
            }
        }
        
    }
    
}


