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
    
    fileprivate let carePlanData: CareData
    
    fileprivate var careCardViewController: OCKCareContentsViewController? = nil
    fileprivate var insightsViewController: OCKInsightsViewController? = nil
    
    required init?(coder aDecoder: NSCoder) {
        
        self.carePlanData = CareData(careStore: self.carePlanStoreManager.store)
        
        super.init(coder: aDecoder)
        
        self.carePlanStoreManager.delegate = self
        self.carePlanStoreManager.updateInsights()
        
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
        
        self.careCardViewController = viewController
        
        viewController.delegate = self
        
        viewController.tabBarItem = UITabBarItem(title: "Zombie Training", image: UIImage(named: "carecard"), selectedImage: UIImage(named: "carecard-filled"))
        viewController.title = "Zombie Training"
        
        return UINavigationController(rootViewController: viewController)
    }
    
    fileprivate func createInsightsStack() -> UINavigationController {
        
        let viewController = OCKInsightsViewController(insightItems: [OCKInsightItem.emptyInsightsMessage()])
        
        self.insightsViewController = viewController
        
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

extension MainTabViewController: OCKCareContentsViewControllerDelegate {
    
    // If user select one assessment event we need to open
    // one view controller fou user does the task.
    func careContentsViewController(_ viewController: OCKCareContentsViewController, didSelectRowWithAssessmentEvent assessmentEvent: OCKCarePlanEvent) {
        
        guard let userInfo = assessmentEvent.activity.userInfo,
            let task: ORKTask = userInfo["ORKTask"] as? ORKTask
            else { return }
        
        let taskViewController = ORKTaskViewController(task: task, taskRun: nil)
        
        taskViewController.delegate = self
        
        present(taskViewController, animated: true, completion: nil)
    }
}

extension MainTabViewController: ORKTaskViewControllerDelegate {
    
    // When user finish the task we need to hold the result and
    // convert this from ORKTaskResult to OCKCarePlanEventResult.
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        
        defer {
            dismiss(animated: true, completion: nil)
        }
        
        guard reason == .completed else { return }
        guard let careCardViewController = careCardViewController,
            let event = careCardViewController.lastSelectedEvent else { return }
        
        let carePlanResult = carePlanStoreManager.buildCarePlanResultFrom(taskResult: taskViewController.result)
        carePlanStoreManager.store.update(event,
                                          with: carePlanResult,
                                          state: .completed) { (success, _, error) in
                                            
                                            if !success {
                                                print(error!.localizedDescription)
                                            }
        }
    }
}

extension MainTabViewController: CareStoreManagerDelegate {
    
    func careStore(_ store: OCKCarePlanStore, didUpdateInsights insights: [OCKInsightItem]) {
        
        self.insightsViewController?.items = insights
    }
}
