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

class MapSearchViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var lastLocation: CLLocation?
    var searchName = [String]()
    var arrayOfFoundAnnotations = [MKAnnotation]()
    var searchRadius: Double = 0
    var isSameAnnotation: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().delegate = self

        checkLocationServices()
        
    }
    
    //MARK: Mapkit search
    func addSearchFilter() {
        
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
                                self.setupLocalNotification(annotation: item)
                                
                                print("tag arrayens storlek är: \(self.arrayOfFoundAnnotations.count)")
                                print("TAG name: \(String(describing: item.name))")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func createAnnotation(item: MKMapItem) -> MKPointAnnotation {
        
        let newAnnotation = MKPointAnnotation()
        newAnnotation.coordinate = item.placemark.coordinate
        newAnnotation.title = item.name
        newAnnotation.subtitle = item.placemark.thoroughfare
        
        self.arrayOfFoundAnnotations.append(newAnnotation)
        
        return newAnnotation
    }
    
    // MARK: Location
    func setRadiusOnMap() {
        
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: searchRadius, longitudinalMeters: searchRadius)
            mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func setupLocationManager() {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationServices() {
        
        if CLLocationManager.locationServicesEnabled(){
            setupLocationManager()
            mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
        } else {
            // show alert to user to enable location
        }
    }
    
    func checkLocationAuthorization() {
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            setRadiusOnMap()
            locationManager.startUpdatingLocation()
            locationManager.allowsBackgroundLocationUpdates = true
            break
        case .denied:
            break
        case .restricted:
            break
        case .authorizedAlways:
            mapView.showsUserLocation = true
            setRadiusOnMap()
            locationManager.startUpdatingLocation()
            locationManager.allowsBackgroundLocationUpdates = true
            break
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        let center = UNUserNotificationCenter.current()
        
        locationManager.stopUpdatingLocation()
        center.removeAllDeliveredNotifications()
        print("Removing localPush")
    }
    
    // MARK: Local Notification
    func setupLocalNotification(annotation: MKMapItem){
        
        let userActions = "User Actions"
        
        let content = UNMutableNotificationContent()
        content.title = "Du har en match!"
        content.subtitle = annotation.name!
        content.body = "Färdbeskrivning"
        content.sound = .default
        content.categoryIdentifier = userActions
        content.userInfo = ["notificationLongitude" : annotation.placemark.coordinate.longitude, "notificationLatitude" : annotation.placemark.coordinate.latitude, "notificationName" : annotation.name!]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        let navigationAction = UNNotificationAction(identifier: "navigation", title: "Färdbeskrivning", options: .foreground)
        let category = UNNotificationCategory(identifier: userActions, actions: [navigationAction], intentIdentifiers: [], options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
    }
    
    func openNavigationInMaps(longitude: CLLocationDegrees, latitude: CLLocationDegrees, name: String) {
        let source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!)))
        source.name = "Din position"
        
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)))
        destination.name = name
        
        MKMapItem.openMaps(with: [source, destination], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}

// MARK: Delegates methods for location and notification
extension MapSearchViewController: CLLocationManagerDelegate, UNUserNotificationCenterDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let mostRecentLocation = locations.last else { return }
        
        if UIApplication.shared.applicationState == .active || UIApplication.shared.applicationState == .background || UIApplication.shared.applicationState == .background {
            print("user on the move")
            if lastLocation != nil {
                if lastLocation!.verticalAccuracy < 50 && lastLocation!.horizontalAccuracy < 50 {
                    let distance = mostRecentLocation.distance(from: lastLocation!)
                    if distance > 1000 {
                        self.lastLocation = mostRecentLocation
                        // Nu har vi förflyttat oss minst 1000 meter!
                        // Kolla notificationCenter addObserver applicationWillEnterForeground SO
                        self.addSearchFilter()
                        
                    }
                }
            } else {
                if mostRecentLocation.verticalAccuracy < 50 && mostRecentLocation.horizontalAccuracy < 50 {
                    self.lastLocation = mostRecentLocation
                }
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        if  response.notification.request.content.categoryIdentifier == "User Actions" {
            let longitude = userInfo["notificationLongitude"] as! CLLocationDegrees
            let latitude = userInfo["notificationLatitude"] as! CLLocationDegrees
            let name = userInfo["notificationName"] as! String
            
            self.openNavigationInMaps(longitude: longitude, latitude: latitude, name: name)
        }
        completionHandler()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
}
