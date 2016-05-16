//
//  AppDelegate.swift
//  GeoSerach
//
//  Created by alexfu on 4/22/16.
//  Copyright © 2016 alexfu. All rights reserved.
//

import UIKit
import BNRCoreDataStack
import SwiftCSV

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?
	private var coreDataStack: CoreDataStack?
	var operationContext: NSManagedObjectContext!
	private let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
    private lazy var loadingVC: UIViewController = {
        return self.mainStoryboard.instantiateViewControllerWithIdentifier("LoadingVC")
    }()
    private lazy var  myCoreDataVC: MapQueryViewController = {
        return self.mainStoryboard.instantiateViewControllerWithIdentifier("mapvc")
            as! MapQueryViewController
    }()
    
    


    

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
         window = UIWindow(frame: UIScreen.mainScreen().bounds)
         window?.rootViewController = loadingVC
		CoreDataStack.constructSQLiteStack(withModelName: "GeoSerach") { result in
			switch result {
			case .Success(let stack):
				self.coreDataStack = stack
                
                if NSUserDefaults.standardUserDefaults().boolForKey("isFirstLaunch") {
                    
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isFirstLaunch")
                    NSUserDefaults.standardUserDefaults().synchronize()
                }
                let isFirstLaunch = NSUserDefaults.standardUserDefaults().valueForKey("isFirstLaunch") as? Bool
                if (isFirstLaunch == nil) {
                    print("first time")
                    self.seedInitialData()
                }
                else {
                    print("second time")
                }
                
				
                
				dispatch_async(dispatch_get_main_queue()) {
                 
                    
					self.myCoreDataVC.coreDataStack = stack
                    let navController = UINavigationController(rootViewController: self.myCoreDataVC)

					self.window?.rootViewController = navController
                   
				}
			case .Failure(let error):
				assertionFailure("\(error)")
			}
		}
        window?.makeKeyAndVisible()
		return true
	}

	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
		// Saves changes in the application's managed object context before the application terminates.
	}

	private func seedInitialData() {
		guard coreDataStack != nil else {
			assertionFailure("Stack was not setup first")
			return
		}

		coreDataStack!.newBatchOperationContext() { result in
			switch result {
			case .Success(let batchContext):
				self.operationContext = batchContext
                self.BatchOperation()
                print("ok")
			case .Failure(let error):
				print(error)
			}
		}
	}
    
    func BatchOperation() {
        let csvURL = NSBundle.mainBundle().URLForResource("businesses", withExtension: "csv")!
        let csv = try! CSV(url: csvURL, loadColumns: false)
        let operationMOC = self.operationContext
        
        operationMOC.performBlockAndWait() {
            for (index, row) in csv.rows.enumerate() {
                if let restaurant = NSEntityDescription.insertNewObjectForEntityForName("Restaurant", inManagedObjectContext: operationMOC) as? Restaurant {
                    restaurant.businessId = row["business_id"]
                    restaurant.address = row["address"]
                    restaurant.city = row["city"]
                    
            
                    
                    if let lat = Double(row["latitude"]!) {
                        restaurant.latitude = NSNumber(double: lat)
                        
                        if let lon = Double(row["longitude"]!) {
                            restaurant.longitude = NSNumber(double: lon)
                          //  print("\(restaurant.latitude?.doubleValue), \(restaurant.longitude?.doubleValue)")

                            restaurant.geohash = Geohash.encode(latitude: lat, longitude: lon, 8)
                        }
                    }
                    
                    
                    restaurant.name = row["name"]
                    restaurant.phoneNumber = row["phone_number"]
                    restaurant.postalCode = row["postal_code"]
                    restaurant.state = row["state"]
                   
                }
                else {
                    print("Failed to create a new Restaurant object in the context")
                }
            }
            try! operationMOC.save()
        }
    }

}
