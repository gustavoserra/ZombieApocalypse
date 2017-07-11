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
    
    var pulseData = [DateComponents: Double]()
    var temperatureData = [DateComponents: Double]()
    
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
            
            // Dates interval to get the data.
            let startDateComponents = DateComponents.firstDateOfCurrentWeek
            let endDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: Date())
            
            // Get activity for pulse
            guard let pulseActivity = self.findActivityWith(ActivityIdentifier.pulse) else { return }
            
            // Get data from events for pulse
            self.fetchActivityResultsFor(pulseActivity,
                                         startDate: startDateComponents,
                                         endDate: endDateComponents,
                                         completionClosure:
            {(fetchedData) in
                
                self.pulseData = fetchedData
            })
            
            // Get activity for temperature
            guard let temperatureActivity = self.findActivityWith(ActivityIdentifier.temperature) else { return }
            
            // Get data from events for temperature
            self.fetchActivityResultsFor(temperatureActivity,
                                         startDate: startDateComponents,
                                         endDate: endDateComponents,
                                         completionClosure:
            {(fetchedData) in
                
                self.temperatureData = fetchedData
            })
            
            // Get activities without assessments
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
        
        let pulseAssessmentSeries = barSeriesFor(data: pulseData,
                                                 title: "Pulse",
                                                 tintColor: UIColor.darkGreen())
        
        let temperatureAssessmentSeries = barSeriesFor(data: temperatureData,
                                                       title: "Temperature",
                                                       tintColor: UIColor.darkYellow())
        
        let chart = OCKBarChart(title: "Zombie Training Plan",
                                text: "Training Compilance and Zombie Risks",
                                tintColor: UIColor.green,
                                axisTitles: dateStrings,
                                axisSubtitles: nil,
                                dataSeries: [completionSeries,
                                             pulseAssessmentSeries,
                                             temperatureAssessmentSeries])
        
        return [chart]
    }
    
    func findActivityWith(_ activityIdentifier: ActivityIdentifier) -> OCKCarePlanActivity? {
        
        // For run synchronously
        let semaphore = DispatchSemaphore(value: 0)
        
        var activity: OCKCarePlanActivity?
        
        DispatchQueue.main.async {
            
            // You call on the main queue due to a bug that results in a crash if run elsewhere. 
            // Apple references a radar that exists for this in their sample CareKit application.
            self.store.activity(forIdentifier: activityIdentifier.rawValue,
                                completion: { (success, foundActivity, error) in
                                    
                                    activity = foundActivity
                                    semaphore.signal()
            })
        }
        
        let _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return activity
    }
    
    func fetchActivityResultsFor(_ activity: OCKCarePlanActivity, startDate: DateComponents, endDate: DateComponents, completionClosure: @escaping (_ fetchedData: [DateComponents: Double]) -> ()) {
        
        var fetchedData = [DateComponents: Double]()
        
        self.gatherDataGroup.enter()
        
        store.enumerateEvents(of: activity,
                              startDate: startDate,
                              endDate: endDate,
                              handler:
        {(event, stop) in
            
            if let event = event,
                let result = event.result,
                let value = Double(result.valueString) {
                
                fetchedData[event.date] = value
            }
        }) { (success, error) in
            
            guard success else { fatalError(error!.localizedDescription) }
            
            completionClosure(fetchedData)
            
            self.gatherDataGroup.leave()
        }
    }
    
    func barSeriesFor(data: [DateComponents: Double], title: String, tintColor: UIColor) -> OCKBarSeries {
        
        let rawValues = completionData.map { (entry) -> Double? in
            return data[entry.dateComponent]
        }
        
        let values = DataHelpers().normalize(rawValues) as [NSNumber]
        
        let valuesLabels = rawValues.map { (value) -> String in
            
            guard let value = value else { return "N/A" }
            
            return NumberFormatter.localizedString(from: NSNumber(value: value), number: .decimal)
        }
        
        return OCKBarSeries(title: title,
                            values: values,
                            valueLabels: valuesLabels,
                            tintColor: tintColor)
    }
}
