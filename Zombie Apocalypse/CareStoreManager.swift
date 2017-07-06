//
//  StoreManager.swift
//  Zombie Apocalypse
//
//  Created by Gustavo Serra on 06/07/2017.
//  Copyright © 2017 Gustavo Serra. All rights reserved.
//

import CareKit

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
    }
}
