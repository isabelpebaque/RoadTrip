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

class MapSearchViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 1000
    
    var searchName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
    //    addSearchFilter(searchName: searchName ?? "")
        
        var timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(addSearchFilter), userInfo: nil, repeats: true)

    }
    
        @objc func addSearchFilter() {
            let serchRequest = MKLocalSearch.Request()
            serchRequest.naturalLanguageQuery = searchName
            serchRequest.region = mapView.region
    
            let activeSearhc = MKLocalSearch(request: serchRequest)
    
            activeSearhc.start { (response, error) in
                if error != nil {
                    print("There was following error: \(error ?? "No info of error" as! Error)")
                } else if response?.mapItems.count == 0 {
                    print("No matches found!")
                } else {
                    print("You got following results: ")
                   // var allItemArray = [MKMapItem]()
    
                    guard let mapItems = response?.mapItems else { return }
                    for item in (mapItems) {
    
                        print("URL=\(String(describing: item.url))")
                        print("Name=\(item.name ?? "No info")")
                        print("Phone Number\(item.phoneNumber ?? "No phoneNumber")")
    
                       // allItemArray.append(item as MKMapItem)
    
                       // print("Matching items = \(allItemArray.count)")
    
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = item.placemark.coordinate
                        annotation.title = item.name
                        self.mapView.addAnnotation(annotation)
                    }
                }
            }
        }
    
    func setupLocationManager() {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerViewOnUserLocation() {
        
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
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
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
            break
        case .denied:
            break
        case .restricted:
            break
        case .authorizedAlways:
            break
        }
    }
}

extension MapSearchViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let center = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
