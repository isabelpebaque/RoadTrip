//
//  MapSearchViewController.swift
//  RoadTripAssistant
//
//  Created by Isabel Pebaqué on 2019-04-07.
//  Copyright © 2019 Isabel Pebaqué. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import UserNotifications

class MapSearchViewController: UIViewController, UNUserNotificationCenterDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var lastLocation: CLLocation?
    var searchName = [String]()
    var arrayOfFoundAnnotations = [MKAnnotation]()
    var searchRadius: Double = 0
    var isSameAnnotation: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [[.alert, .sound, .badge]], completionHandler: { (granted, error) in
            print(error?.localizedDescription as Any)
        })
        UNUserNotificationCenter.current().delegate = self
        
        checkLocationServices()
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .sound])
    }
    
    func setupLocalPush(NameOfAnnotation: String, adress: String){
        
        let content = UNMutableNotificationContent()
        content.title = "Du har en match!"
        content.subtitle = NameOfAnnotation
        content.body = adress
        content.sound = .default
        content.categoryIdentifier = "category"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
            if error != nil {
                print("\(error?.localizedDescription ?? "No error info")")
            }
        }
        
        let action = UNNotificationAction(identifier: "action", title: "Färdbeskrivning", options: .foreground)
        let category = UNNotificationCategory(identifier: "category", actions: [action], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    @objc func addSearchFilter() {
        
        let serchRequest = MKLocalSearch.Request()
        
        for name in searchName {
            
            serchRequest.naturalLanguageQuery = name
            serchRequest.region = mapView.region
            
            let activeSearch = MKLocalSearch(request: serchRequest)
            
            activeSearch.start { (response, error) in
                if error != nil {
                    print("There was following error: \(error ?? "No info of error" as! Error)")
                } else if response?.mapItems.count == 0 {
                    print("No matches found!")
                } else {
                    
                    guard let mapItems = response?.mapItems else { return }
                    
                    if self.arrayOfFoundAnnotations.count == 0 {
                        
                        for item in mapItems {
                            let annotation = self.createAnnotation(item: item)
                            self.mapView.addAnnotation(annotation)
                        }
                        
                    } else {
                        for item in (mapItems) {
                            self.isSameAnnotation = false
                            for newItem in self.arrayOfFoundAnnotations {
                                
                                if item.placemark.coordinate.longitude == newItem.coordinate.longitude &&
                                    item.placemark.coordinate.latitude == newItem.coordinate.latitude {
                                    self.isSameAnnotation = true
                                }
                            }
                            
                            if !self.isSameAnnotation {
                                print("tag Ny annotation, lägger till i arrayen")
                                let annotation = self.createAnnotation(item: item)
                                self.mapView.addAnnotation(annotation)
                                self.setupLocalPush(NameOfAnnotation: item.name!, adress: item.placemark.thoroughfare!)
                                
                                print("tag arrayens storlek är: \(self.arrayOfFoundAnnotations.count)")
                                print("TAG name: \(String(describing: item.name))")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func createAnnotation(item: MKMapItem) -> MKPointAnnotation{
        
                // Öppna färdbeskrivning i maps
//        let source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!)))
//        source.name = "Source"
//
//        let destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: item.placemark.coordinate.latitude, longitude: item.placemark.coordinate.longitude)))
//        destination.name = "Destination"
//
//        MKMapItem.openMaps(with: [source, destination], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        
        let newAnnotation = MKPointAnnotation()
        newAnnotation.coordinate = item.placemark.coordinate
        newAnnotation.title = item.name
        newAnnotation.subtitle = item.placemark.thoroughfare
        
        self.arrayOfFoundAnnotations.append(newAnnotation)
        
        return newAnnotation
    }
    
    
    func setupLocationManager() {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerViewOnUserLocation() {
        
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: searchRadius, longitudinalMeters: searchRadius)
//            let region2 = CLLocationCoordinate2DMake(location.latitude, location.longitude)
            mapView.setRegion(region, animated: true)
            mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
//            mapView.setCenter(region2, animated: true)
    }
        
    }
    
    func checkLocationServices() {
        
        if CLLocationManager.locationServicesEnabled(){
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // show alert to user to enable location
        }
    }
    
    func checkLocationAuthorization() {

        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            //centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
            break
        case .denied:
            break
        case .restricted:
            break
        case .authorizedAlways:
            mapView.showsUserLocation = true
            //centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
            break
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        
        print("Removing localPush")
    }
}

extension MapSearchViewController: CLLocationManagerDelegate, MKMapViewDelegate {
    
    

    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
       // mapView.setUserTrackingMode(.followWithHeading, animated: true)
        
        if lastLocation != nil {
            if lastLocation!.verticalAccuracy < 50 && lastLocation!.horizontalAccuracy < 50 {
                if let distance = userLocation.location?.distance(from: lastLocation!) {
                    if distance > 1000 {
                        self.lastLocation = userLocation.location
                        // Nu har vi förflyttat oss minst 1000 meter!
                        // Kolla notificationCenter addObserver applicationWillEnterForeground SO
                        self.addSearchFilter()
                    }
                }
            }
        } else {
            if userLocation.location!.verticalAccuracy < 50 && userLocation.location!.horizontalAccuracy < 50 {
                self.lastLocation = userLocation.location
            }
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }

    
    
}
