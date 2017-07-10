//
//  InsightsDataManager.swift
//  Zombie Apocalypse
//
//  Created by Gustavo Serra on 10/07/2017.
//  Copyright © 2017 Gustavo Serra. All rights reserved.
//

import CareKit

class InsightsDataManager {
    
    let store = CareStoreManager.sharedCarePlanStoreManager.store
    
    var completionData = [(dateComponent: DateComponents, value: Double)]()
    let gatherDataGroup = DispatchGroup()
    
    func fetchDailyCompletion(startDate: DateComponents, endDate: DateComponents) {
        
        self.gatherDataGroup.enter()
        
        store.dailyCompletionStatus(with: .intervention,
                                    startDate: startDate,
                                    endDate: endDate,
                                    handler:
        {(dateComponents, completed, total) in
            
            let percentComplete = Double(completed) / Double(total)
            self.completionData.append((dateComponents, percentComplete))
        })
        {(success, error) in
            
            guard success else { fatalError(error!.localizedDescription) }
            
            self.gatherDataGroup.leave()
        }
    }
    
    func updateInsights(_ completion: ((Bool, [OCKInsightItem]?) -> Void)?) {
        
        guard let completion = completion else { return }
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            
            let startDateComponents = DateComponents.firstDateOfCurrentWeek
            let endDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: Date())
            
            //TODO fetch assessment data
            
            self.fetchDailyCompletion(startDate: startDateComponents, endDate: endDateComponents)
            
            self.gatherDataGroup.notify(queue: DispatchQueue.main, execute: { 
                print("completion data: \(self.completionData)")
                completion(false, nil)
            })
        }
    }
}
