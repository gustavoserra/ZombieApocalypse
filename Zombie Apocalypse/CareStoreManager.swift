//
//  StoreManager.swift
//  Zombie Apocalypse
//
//  Created by Gustavo Serra on 06/07/2017.
//  Copyright © 2017 Gustavo Serra. All rights reserved.
//

import CareKit
import ResearchKit

class CareStoreManager: NSObject {

    static let sharedCarePlanStoreManager = CareStoreManager()
    
    var store: OCKCarePlanStore
    
    override init() {
        
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).last else {
            fatalError("Failed to obtain Documents directory!")
        }
        
        let storeURL = documentDirectory.appendingPathComponent("CarePlanStore")
        
        if !fileManager.fileExists(atPath: storeURL.path) {
            try! fileManager.createDirectory(at: storeURL, withIntermediateDirectories: true, attributes: nil)
        }
        
        store = OCKCarePlanStore(persistenceDirectoryURL: storeURL)
        
        super.init()
        
        self.store.delegate = self
    }
    
    // Convert ORKTaskResult to OCKCarePlanEventResult.
    func buildCarePlanResultFrom(taskResult: ORKTaskResult) -> OCKCarePlanEventResult {
        
        guard let firstResult = taskResult.firstResult as? ORKStepResult,
              let stepResult = firstResult.results?.first else {
            fatalError("Unexepected task results")
        }
        
        if let numericResult = stepResult as? ORKNumericQuestionResult,
            let answer = numericResult.numericAnswer {
            
            return OCKCarePlanEventResult(valueString: answer.stringValue,
                                          unitString: numericResult.unit,
                                          userInfo: nil)
        }
        
        fatalError("Unexpected task result type")
    }
    
    func updateInsights() {
        
        InsightsDataManager().updateInsights { (success, insightItems) in
            
            guard let insightItems = insightItems, success else { return }
            
            //TODO - pass inshits items to insights controller.
        }
    }
}

extension CareStoreManager: OCKCarePlanStoreDelegate {
    
    func carePlanStore(_ store: OCKCarePlanStore, didReceiveUpdateOf event: OCKCarePlanEvent) {
        
        self.updateInsights()
    }
}
