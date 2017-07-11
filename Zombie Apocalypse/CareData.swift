//
//  CareData.swift
//  Zombie Apocalypse
//
//  Created by Gustavo Serra on 06/07/2017.
//  Copyright © 2017 Gustavo Serra. All rights reserved.
//

import CareKit
import ResearchKit

enum ActivityIdentifier: String {
    
    case cardio
    case limberUp = "Limber Up"
    case targetPractice = "Target Practice"
    case pulse
    case temperature
}

class CareData: NSObject {

    let careStore: OCKCarePlanStore
    
    let contacts =
        [OCKContact(contactType: .personal,
                    name: "Shaun Riley",
                    relation: "Friend",
                    contactInfoItems: [OCKContactInfo(type: .phone,
                                                      display: "888-555-5512",
                                                      actionURL: nil),
                                       OCKContactInfo(type: .message,
                                                      display: "888-555-5512",
                                                      actionURL: nil),
                                       OCKContactInfo(type: .email,
                                                      display: "shaunofthedead@example.com",
                                                      actionURL: nil)],
                    tintColor: nil,
                    monogram: "SR",
                    image: UIImage(named: "shaun-avatar")),
         OCKContact(contactType: .careTeam,
                    name: "Columbus Ohio",
                    relation: "Therapist",
                    contactInfoItems: [OCKContactInfo(type: .phone,
                                                      display: "888-555-5235",
                                                      actionURL: nil),
                                       OCKContactInfo(type: .message,
                                                      display: "888-555-5235",
                                                      actionURL: nil),
                                       OCKContactInfo(type: .email,
                                                      display: "columbus@example.com",
                                                      actionURL: nil)],
                    tintColor: nil,
                    monogram: "CO",
                    image: UIImage(named: "columbus-avatar")),
         OCKContact(contactType: .careTeam,
                    name: "Dr Hershel Greene",
                    relation: "Veterinarian",
                    contactInfoItems: [OCKContactInfo(type: .phone,
                                                      display: "888-555-2351",
                                                      actionURL: nil),
                                       OCKContactInfo(type: .message,
                                                      display: "888-555-2351",
                                                      actionURL: nil),
                                       OCKContactInfo(type: .email,
                                                      display: "dr.hershel@example.com",
                                                      actionURL: nil)],
                    tintColor: nil,
                    monogram: "HG",
                    image: UIImage(named: "hershel-avatar"))]
    
    init(careStore: OCKCarePlanStore) {
        
        self.careStore = careStore
        
        let cardioActivity = OCKCarePlanActivity(identifier: ActivityIdentifier.cardio.rawValue,
                                                 groupIdentifier: "Activities",
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
                                                   groupIdentifier: "Activities",
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
                                                         groupIdentifier: "Activities",
                                                         type: .intervention,
                                                         title: "Target Practice",
                                                         text: nil,
                                                         tintColor: UIColor.darkOrange(),
                                                         instructions: "Gather some objects that frustrated you before the apocalypse, like printers and construction barriers. Keep your eyes sharp and your arm steady, and blow as many holes as you can in them for at least five minutes.",
                                                         imageURL: nil,
                                                         schedule: CareData.dailyScheduleRepeating(occurencesPerDay: 2),
                                                         resultResettable: true,
                                                         userInfo: nil)
        
        let pulseActivity = OCKCarePlanActivity.assessment(withIdentifier: ActivityIdentifier.pulse.rawValue,
                                                           groupIdentifier: "Assessements",
                                                           title: "Pulse",
                                                           text: "Do you have one?",
                                                           tintColor: UIColor.darkGreen(),
                                                           resultResettable: true,
                                                           schedule: CareData.dailyScheduleRepeating(occurencesPerDay: 1),
                                                           userInfo: ["ORKTask": AssessmentTaskFactory.makePulseAssessmentTask()],
                                                           optional: false)
        
        let temperatureActivity = OCKCarePlanActivity.assessment(withIdentifier: ActivityIdentifier.temperature.rawValue,
                                                                 groupIdentifier: "Assessements",
                                                                 title: "Temperature",
                                                                 text: "Oral",
                                                                 tintColor: UIColor.darkYellow(),
                                                                 resultResettable: true,
                                                                 schedule: CareData.dailyScheduleRepeating(occurencesPerDay: 1),
                                                                 userInfo: ["ORKTask": AssessmentTaskFactory.makeTemperatureAssessmentTask()],
                                                                 optional: false)
        
        let activities = [cardioActivity,
                          limberUpActivity,
                          targetPracticeActivity,
                          pulseActivity,
                          temperatureActivity]
        
        super.init()
        
        for activity in activities {
            self.add(activity: activity)
        }
    }
    
    func add(activity: OCKCarePlanActivity) {
        
        self.careStore.activity(forIdentifier: activity.identifier) { [weak self] (success, fetchedActivity, error) in
            
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
