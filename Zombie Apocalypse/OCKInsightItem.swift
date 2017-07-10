//
//  OCKInsightItem.swift
//  Zombie Apocalypse
//
//  Created by Gustavo Serra on 10/07/2017.
//  Copyright © 2017 Gustavo Serra. All rights reserved.
//

import CareKit

extension OCKInsightItem {
    
    static func emptyInsightsMessage() -> OCKInsightItem {
        
        let text = "You haven't entered any data, or reports are in process. (Or you're a zombie?)"
        
        return OCKMessageItem(title: "No Insights",
                              text: text,
                              tintColor: UIColor.darkOrange(),
                              messageType: .tip)
    }
}
