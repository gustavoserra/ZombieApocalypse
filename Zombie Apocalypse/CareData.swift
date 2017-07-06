//
//  CareData.swift
//  Zombie Apocalypse
//
//  Created by Gustavo Serra on 06/07/2017.
//  Copyright © 2017 Gustavo Serra. All rights reserved.
//

import CareKit

enum ActivityIdentifier: String {
    
    case cardio
    case limberUp = "Limber Up"
    case targetPractice = "Target Practice"
    case pulse
    case temperature
}

class CareData: NSObject {

    let careStore: OCKCarePlanStore
    
    init(careStore: OCKCarePlanStore) {
        
        self.careStore = careStore
        
        super.init()
    }
    
    class func dailyScheduleRepeating(occurencesPerDay: UInt) -> OCKCareSchedule {
        return OCKCareSchedule.dailySchedule(withStartDate: DateComponents.firstDateOfCurrentWeek, occurrencesPerDay: occurencesPerDay)
    }
}
