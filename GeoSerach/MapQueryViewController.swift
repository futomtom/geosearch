//
//  MapQueryViewController.swift
//  GeoSerach
//
//  Created by alexfu on 4/23/16.
//  Copyright © 2016 alexfu. All rights reserved.
//

import UIKit
import MapKit
import BNRCoreDataStack

class MapQueryViewController: UIViewController, MKMapViewDelegate ,FetchedResultsControllerDelegate{
	var coreDataStack: CoreDataStack!
	var drawing = false
	var coordinates = [CLLocationCoordinate2D]()
	var polygon = MKPolygon()
	var frc: FetchedResultsController<Restaurant>?


	@IBOutlet weak var mapView: MKMapView!

	override func viewDidLoad() {
		super.viewDidLoad()
		let center = CLLocationCoordinate2D(latitude: 37.7678103, longitude: -122.4549953)
		let span = MKCoordinateSpanMake(0.3, 0.3)
		let region = MKCoordinateRegion(center: center, span: span)
		mapView.setRegion(region, animated: true)
		SetBarItem()

		// Do any additional setup after loading the view.
	}

	func SetBarItem() {
		let barItem = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: #selector(MapQueryViewController.SearchTap))
		self.navigationItem.setRightBarButtonItem(barItem, animated: true)
	}

	func SearchTap() {
		drawing = false
		mapView.userInteractionEnabled = true
		var centerCoordinate: CLLocationCoordinate2D {
			get {
				let pt = MKMapPointMake(MKMapRectGetMidX(polygon.boundingMapRect), MKMapRectGetMidY(polygon.boundingMapRect))
				return MKCoordinateForMapPoint(pt)
			}
		}
          print("\(centerCoordinate.latitude), \(centerCoordinate.longitude)")
        
		let querystr = Geohash.encode(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude , 5)
		print(querystr)
		let fetchRequest = NSFetchRequest(entityName: Restaurant.entityName)
		fetchRequest.predicate = NSPredicate(format: "geohash BEGINSWITH %@", querystr)
    //    fetchRequest.predicate = NSPredicate(format: "name BEGINSWITH 'A'")
        
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
		frc = FetchedResultsController<Restaurant>(fetchRequest: fetchRequest,
			managedObjectContext: self.coreDataStack.mainQueueContext)
		
		frc!.setDelegate(self)
        
        do {
            try frc!.performFetch()
        } catch {
            print("Failed to fetch objects: \(error)")
        }
    
        let ann = MKPointAnnotation()
        
  
        
		zoomToDrawArea()
	}

	@IBAction func DrawAreaOnMap(sender: AnyObject) {
		drawing = !drawing
		if drawing {
			// Disable the map from moving
			print("drawing")
			mapView.userInteractionEnabled = false
		}
		else {
			// Enable the map to move
			mapView.userInteractionEnabled = true
		}
	}
    

    


    func fetchedResultsControllerDidPerformFetch(controller: FetchedResultsController<Restaurant>) {
        
        
        
        
            //    MKPolygonView *polygonView = [[MKPolygonView alloc] initWithPolygon:self];
            let polygonView: MKPolygonRenderer = MKPolygonRenderer(polygon: polygon)
            let restaurants = controller.fetchedObjects!.filter ({
                let pt = MKMapPointForCoordinate(CLLocationCoordinate2D(latitude: $0.latitude!.doubleValue, longitude: $0.longitude!.doubleValue))
                let polygonViewPoint = polygonView.pointForMapPoint(pt)
                return CGPathContainsPoint(polygonView.path, nil, polygonViewPoint, false) == true
            })
      
        
        
        
        
        
        print(controller.fetchedObjects?.count)
        for item in restaurants {
            let restaurant = item as Restaurant
            let ann = MKPointAnnotation()
           print("\(restaurant.latitude!.doubleValue), \(restaurant.longitude!.doubleValue)")
            print("\(restaurant.name)")
            ann.coordinate = CLLocationCoordinate2D(latitude: restaurant.latitude!.doubleValue, longitude: restaurant.longitude!.doubleValue)
            ann.title = "Park here"
            ann.subtitle = "Fun awaits down the road!"
            mapView!.addAnnotation(ann)
        }
    }
    
    func fetchedResultsControllerWillChangeContent(controller: FetchedResultsController<Restaurant>) {
        
    }
    
    func fetchedResultsControllerDidChangeContent(controller: FetchedResultsController<Restaurant>) {
        print("h")
    }
    
    func fetchedResultsController(controller: FetchedResultsController<Restaurant>,
                                  didChangeObject change: FetchedResultsObjectChange<Restaurant>) {
        print("h")
    }
    
    func fetchedResultsController(controller: FetchedResultsController<Restaurant>,
                                  didChangeSection change: FetchedResultsSectionChange<Restaurant>) {
        print("h")
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var v: MKAnnotationView! = nil
        
            let ident = "greenPin"
            v = mapView.dequeueReusableAnnotationViewWithIdentifier(ident)
            if v == nil {
                v = MKPinAnnotationView(annotation: annotation, reuseIdentifier: ident)
                (v as! MKPinAnnotationView).pinTintColor = MKPinAnnotationView.greenPinColor() // or any UIColor
                v.canShowCallout = true
               // (v as! MKPinAnnotationView).animatesDrop = true
            }
           
            v.annotation = annotation

        return v
    }
    
   


}




extension MapQueryViewController { // Map drawquery

			// MARK: - Handle Touches
			override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
				// If editing
				if drawing {
					// Empty array
					coordinates.removeAll()

					// Convert touches to map coordinates
					for touch in touches {
						let coordinate = mapView.convertPoint(touch.locationInView(mapView), toCoordinateFromView: mapView)
						coordinates.append(coordinate)
					}
				}
			}

			override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
				// If editing
				if drawing {
					// Convert touches to map coordinates
					for touch in touches {
						// Use this method to convert a CGPoint to CLLocationCoordinate2D
						let coordinate = mapView.convertPoint(touch.locationInView(mapView), toCoordinateFromView: mapView)
						// Add the coordinate to the array
						coordinates.append(coordinate)
					}
				}
			}

			override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
				// If editing
				if drawing {
					// Convert touches to map coordinates
					for touch in touches {
						let coordinate = mapView.convertPoint(touch.locationInView(mapView), toCoordinateFromView: mapView)
						coordinates.append(coordinate)
					}

					// Remove existing polygon
					mapView.removeOverlay(polygon)

					// Create new polygon
					polygon = MKPolygon(coordinates: &coordinates, count: coordinates.count)

					// Add polygon to map
					mapView.addOverlay(polygon)
				}
			}

			override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
				// If editing
				if drawing {
					print("cancel")
				}
			}

			func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
				// Create polygon renderer
				let renderer = MKPolygonRenderer(overlay: overlay)

				// Set the line color
				renderer.strokeColor = UIColor.blueColor()

				// Set the line width
				renderer.lineWidth = 3.0

				// Return the customized renderer
				return renderer
			}

			func zoomToDrawArea() {
				mapView.setRegion(MKCoordinateRegionForMapRect(polygon.boundingMapRect), animated: true)
				// mapView.setVisibleMapRect(polygon.boundingMapRect, edgePadding: UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0), animated: false)
			}
		}

