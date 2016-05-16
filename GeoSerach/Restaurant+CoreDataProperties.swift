//
//  Restaurant+CoreDataProperties.swift
//  GeoSerach
//
//  Created by alexfu on 4/24/16.
//  Copyright © 2016 alexfu. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Restaurant {

    @NSManaged var address: String?
    @NSManaged var businessId: String?
    @NSManaged var city: String?
    @NSManaged var geohash: String?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var name: String?
    @NSManaged var phoneNumber: String?
    @NSManaged var postalCode: String?
    @NSManaged var state: String?

}
