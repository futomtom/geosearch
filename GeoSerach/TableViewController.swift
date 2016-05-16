//
//  BooksTableViewController.swift
//  CoreDataStack
//
//  Created by Robert Edwards on 11/23/15.
//  Copyright © 2015 Big Nerd Ranch. All rights reserved.
//

import UIKit

import BNRCoreDataStack


class TableViewController: UITableViewController {

    private var stack: CoreDataStack!
    private lazy var fetchedResultsController: FetchedResultsController<Restaurant> = {
        let fetchRequest = NSFetchRequest(entityName: Restaurant.entityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let frc = FetchedResultsController<Restaurant>(fetchRequest: fetchRequest,
            managedObjectContext: self.stack.mainQueueContext)
         //   sectionNameKeyPath: nil)
        frc.setDelegate(self.frcDelegate)
        return frc
    }()
    private lazy var frcDelegate: BooksFetchedResultsControllerDelegate = {
        return BooksFetchedResultsControllerDelegate(tableView: self.tableView)
    }()

    // MARK: - Lifecycle

    init(coreDataStack stack: CoreDataStack) {
        super.init(nibName: nil, bundle: nil)
        self.stack = stack
    }

    required init?(coder aDecoder: NSCoder) {
        preconditionFailure("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "GenericReuseCell")

        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Failed to fetch objects: \(error)")
        }
        
        

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done,
            target: self,
            action: "dismiss")
    }

    // MARK: - Actions

    @objc private func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }


    

     override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
     return self.fetchedResultsController.sections?.count ?? 0
     }
     
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print (fetchedResultsController.sections?[section].objects.count)
        return fetchedResultsController.sections?[section].objects.count ?? 0
    }
 

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GenericReuseCell") ?? UITableViewCell()

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

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultsController.sections?[section].indexTitle
    }

    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return fetchedResultsController.sections?.map() { $0.indexTitle ?? "" }
    }
}

class BooksFetchedResultsControllerDelegate: FetchedResultsControllerDelegate {

    private weak var tableView: UITableView?

    // MARK: - Lifecycle

    init(tableView: UITableView) {
        self.tableView = tableView
    }

    func fetchedResultsControllerDidPerformFetch(controller: FetchedResultsController<Restaurant>) {
        tableView?.reloadData()
    }

    func fetchedResultsControllerWillChangeContent(controller: FetchedResultsController<Restaurant>) {
        tableView?.beginUpdates()
    }

    func fetchedResultsControllerDidChangeContent(controller: FetchedResultsController<Restaurant>) {
        tableView?.endUpdates()
    }

    func fetchedResultsController(controller: FetchedResultsController<Restaurant>,
        didChangeObject change: FetchedResultsObjectChange<Restaurant>) {
            switch change {
            case let .Insert(_, indexPath):
                tableView?.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)

            case let .Delete(_, indexPath):
                tableView?.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)

            case let .Move(_, fromIndexPath, toIndexPath):
                tableView?.moveRowAtIndexPath(fromIndexPath, toIndexPath: toIndexPath)

            case let .Update(_, indexPath):
                tableView?.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
    }

    func fetchedResultsController(controller: FetchedResultsController<Restaurant>,
        didChangeSection change: FetchedResultsSectionChange<Restaurant>) {
            switch change {
            case let .Insert(_, index):
                tableView?.insertSections(NSIndexSet(index: index), withRowAnimation: .Automatic)

            case let .Delete(_, index):
                tableView?.deleteSections(NSIndexSet(index: index), withRowAnimation: .Automatic)
            }
    }
}
