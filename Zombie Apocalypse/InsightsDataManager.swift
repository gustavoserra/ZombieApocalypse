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
    
    var completionSeries: OCKBarSeries {
        
        let completionValues = completionData.map({ NSNumber(value: $0.value) })
        let completionValueLabels = completionValues.map({ NumberFormatter.localizedString(from: $0, number: .percent) })
        
        return OCKBarSeries(title: "Zombie Activities",
                            values: completionValues,
                            valueLabels: completionValueLabels,
                            tintColor: UIColor.darkOrange())
    }
    
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
                
                let insightItems = self.produceInsightsForAdherence()
                
                completion(true, insightItems)
            })
        }
    }
    
    func produceInsightsForAdherence() -> [OCKInsightItem] {
        
        let dateStrings = completionData.map({(entry) -> String in
            
            guard let date = Calendar.current.date(from: entry.dateComponent) else { return "" }
            
            return DateFormatter.localizedString(from: date,
                                                 dateStyle: .short,
                                                 timeStyle: .none)
        })
        
        //TODO build assessment series
        
        let chart = OCKBarChart(title: "Zombie Training Plan",
                                text: "Training Compilance and Zombie Risks",
                                tintColor: UIColor.green,
                                axisTitles: dateStrings,
                                axisSubtitles: nil,
                                dataSeries: [completionSeries])
        
        return [chart]
    }
}
