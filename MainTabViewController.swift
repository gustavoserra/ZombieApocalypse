//
//  MainTabViewController.swift
//  Zombie Apocalypse
//
//  Created by Gustavo Serra on 06/07/2017.
//  Copyright © 2017 Gustavo Serra. All rights reserved.
//

import UIKit
import ResearchKit
import CareKit

class MainTabViewController: UITabBarController {
    
    fileprivate let carePlanStoreManager = CareStoreManager.sharedCarePlanStoreManager
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let careCardStack = createCareCardStack()
        let insightsStack = createInsightsStack()
        let connectStack = createConnectStack()
        
        self.viewControllers = [careCardStack,
                                insightsStack,
                                connectStack]
        
        tabBar.tintColor = UIColor.darkOrange()
        tabBar.barTintColor = UIColor.lightGreen()
    }

    fileprivate func createCareCardStack() -> UINavigationController {
        
        let viewController = OCKCareContentsViewController(carePlanStore: carePlanStoreManager.store)
        viewController.customGlyphImageName = "heart"
        viewController.glyphTintColor = UIColor.darkGreen()
        
        viewController.tabBarItem = UITabBarItem(title: "Zombie Training", image: UIImage(named: "carecard"), selectedImage: UIImage(named: "carecard-filled"))
        viewController.title = "Zombie Training"
        return UINavigationController(rootViewController: viewController)
    }
    
    fileprivate func createInsightsStack() -> UINavigationController {
        let viewController = UIViewController()
        
        viewController.tabBarItem = UITabBarItem(title: "Insights", image: UIImage(named: "insights"), selectedImage: UIImage.init(named: "insights-filled"))
        viewController.title = "Insights"
        return UINavigationController(rootViewController: viewController)
    }
    
    fileprivate func createConnectStack() -> UINavigationController {
        let viewController = UIViewController()
        
        viewController.tabBarItem = UITabBarItem(title: "Connect", image: UIImage(named: "connect"), selectedImage: UIImage.init(named: "connect-filled"))
        viewController.title = "Connect"
        return UINavigationController(rootViewController: viewController)
    }

}
