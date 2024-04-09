//
//  PushExample.swift
//  NewBear
//
//  Created by He Cho on 2024/4/4.
//

import Foundation


struct pushExample {
    var id = UUID()
    var header,footer,title,params:String
    static let datas:[pushExample] = [
        
        pushExample(header: NSLocalizedString("pushExampleHeader1",comment: ""), footer: NSLocalizedString("pushExampleFooter1",comment: ""), title: NSLocalizedString("pushExampleTitle1",comment: ""),params: NSLocalizedString("pushExampleParams1",comment: "")),
        
        pushExample(header: NSLocalizedString("pushExampleHeader2",comment: ""), footer: NSLocalizedString("pushExampleFooter2",comment: ""), title: NSLocalizedString("pushExampleTitle2",comment: ""),params: NSLocalizedString("pushExampleParams2",comment: "")),
        
        pushExample(header: NSLocalizedString("pushExampleHeader3",comment: ""), footer: NSLocalizedString("pushExampleFooter3",comment: ""), title: NSLocalizedString("pushExampleTitle3",comment: ""),params: NSLocalizedString("pushExampleParams3",comment: "")),
        
        
        pushExample(header: NSLocalizedString("pushExampleHeader4",comment: ""), footer: NSLocalizedString("pushExampleFooter4",comment: ""), title: NSLocalizedString("pushExampleTitle4",comment: ""),params: NSLocalizedString("pushExampleParams4",comment: "")),
        
        
        pushExample(header: NSLocalizedString("pushExampleHeader5",comment: ""), footer: NSLocalizedString("pushExampleFooter5",comment: ""), title: NSLocalizedString("pushExampleTitle5",comment: ""),params: NSLocalizedString("pushExampleParams5",comment: "")),
        
        pushExample(header: NSLocalizedString("pushExampleHeader6",comment: ""), footer: NSLocalizedString("pushExampleFooter6",comment: ""), title: NSLocalizedString("pushExampleTitle6",comment: ""),params: NSLocalizedString("pushExampleParams6",comment: "")),
        
        pushExample(header: NSLocalizedString("pushExampleHeader7",comment: ""), footer: NSLocalizedString("pushExampleFooter7",comment: ""), title: NSLocalizedString("pushExampleTitle7",comment: ""),params: NSLocalizedString("pushExampleParams7",comment: "") ),
        
        pushExample(header: NSLocalizedString("pushExampleHeader8",comment: ""), footer: NSLocalizedString("pushExampleFooter8",comment: ""), title: NSLocalizedString("pushExampleTitle8",comment: ""),params: NSLocalizedString("pushExampleParams8",comment: "")),
        
    ]
}
