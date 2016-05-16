//
//  ViewController.swift
//  GeoSerach
//
//  Created by alexfu on 4/22/16.
//  Copyright © 2016 alexfu. All rights reserved.
//

import UIKit

import BNRCoreDataStack


class ViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource
{
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var coreDataStack: CoreDataStack!

    
    private lazy var fetchedResultsController: FetchedResultsController<Restaurant> = {
        let fetchRequest = NSFetchRequest(entityName: Restaurant.entityName)
        weak var tableview: UITableView!
        let hash = Geohash.encode(latitude: 37.7702087, longitude: -122.4458823, 5)
        fetchRequest.predicate = NSPredicate(format: "geohash BEGINSWITH %@",hash)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let frc = FetchedResultsController<Restaurant>(fetchRequest: fetchRequest,
                                                       managedObjectContext: self.coreDataStack.mainQueueContext)
        //   sectionNameKeyPath: nil)
        frc.setDelegate(self.frcDelegate)
        return frc
    }()
    
   
    private lazy var frcDelegate: BooksFetchedResultsControllerDelegate = {
        return BooksFetchedResultsControllerDelegate(tableView: self.tableView)
    }()
    
    @IBAction func DoSomeThing(sender: AnyObject) {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Failed to fetch objects: \(error)")
        }
        print ("\(fetchedResultsController.sections?[0].objects.count)")
        
    }
       
    override func viewDidLoad() {
        super.viewDidLoad()
       assert(coreDataStack != nil)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print (fetchedResultsController.sections?[section].objects.count)
        return fetchedResultsController.sections?[section].objects.count ?? 0
    }
    
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") ?? UITableViewCell()
        
        guard let sections = fetchedResultsController.sections else {
            assertionFailure("Sections missing")
            return cell
        }
        
        let section = sections[indexPath.section]
        let Restaurant = section.objects[indexPath.row]
        print("\(Restaurant.address),\(Restaurant.businessId)")
        cell.textLabel?.text = Restaurant.name
        
        return cell
    }
    
  

    
   

 

}

