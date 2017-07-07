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
        
        let cardioActivity = OCKCarePlanActivity(identifier: ActivityIdentifier.cardio.rawValue,
                                                 groupIdentifier: nil,
                                                 type: .intervention,
                                                 title: "Cardio",
                                                 text: "60 minutes",
                                                 tintColor: UIColor.darkOrange(),
                                                 instructions: "Jog at a moderate pace for an hour. If there isn't an actual one, imagine a horde of zombies behind you.",
                                                 imageURL: nil,
                                                 schedule: CareData.dailyScheduleRepeating(occurencesPerDay: 2),
                                                 resultResettable: true,
                                                 userInfo: nil)
        
        let limberUpActivity = OCKCarePlanActivity(identifier: ActivityIdentifier.limberUp.rawValue,
                                                   groupIdentifier: nil,
                                                   type: .intervention,
                                                   title: "Limber Up",
                                                   text: "Stretch Regularly",
                                                   tintColor: UIColor.darkOrange(),
                                                   instructions: "Stretch and warm up muscles in your arms, legs and back before any expected burst of activity. This is especially important if, for example, you're heading down a hill to inspect a Hostess truck.",
                                                   imageURL: nil,
                                                   schedule: CareData.dailyScheduleRepeating(occurencesPerDay: 6),
                                                   resultResettable: true,
                                                   userInfo: nil)
        
        let targetPracticeActivity = OCKCarePlanActivity(identifier: ActivityIdentifier.targetPractice.rawValue,
                                                         groupIdentifier: nil,
                                                         type: .intervention,
                                                         title: "Target Practice",
                                                         text: nil,
                                                         tintColor: UIColor.darkOrange(),
                                                         instructions: "Gather some objects that frustrated you before the apocalypse, like printers and construction barriers. Keep your eyes sharp and your arm steady, and blow as many holes as you can in them for at least five minutes.",
                                                         imageURL: nil,
                                                         schedule: CareData.dailyScheduleRepeating(occurencesPerDay: 2),
                                                         resultResettable: true,
                                                         userInfo: nil)
        
        let activities = [cardioActivity,
                          limberUpActivity,
                          targetPracticeActivity]
        
        super.init()
        
        for activity in activities {
            self.add(activity: activity)
        }
    }
    
    func add(activity: OCKCarePlanActivity) {
        
        careStore.activity(forIdentifier: activity.identifier) { [weak self] (success, fetchedActivity, error) in
            
            guard success else { return }
            guard let strongSelf = self else { return }
            
            if let _ = fetchedActivity { return }
            
            strongSelf.careStore.add(activity, completion: { _ in })
        }
    }
    
    class func dailyScheduleRepeating(occurencesPerDay: UInt) -> OCKCareSchedule {
        return OCKCareSchedule.dailySchedule(withStartDate: DateComponents.firstDateOfCurrentWeek, occurrencesPerDay: occurencesPerDay)
    }
}
