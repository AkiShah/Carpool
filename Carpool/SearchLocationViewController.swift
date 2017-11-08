//
//  SearchLocationViewController.swift
//  Carpool
//
//  Created by Zaller on 11/8/17.
//  Copyright © 2017 Codebase. All rights reserved.
//

import UIKit
import MapKit

class SearchLocationViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let query: String = "SCAD"
    let locationManager = CLLocationManager()
    var selectedLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        search(for: query)
    }
    
    func search(for query: String) {
        let searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = query
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { (searchResp, error) in
            if let searchResp = searchResp {
                self.mapView.addAnnotations(searchResp.mapItems.map({ $0.placemark }))
            }
        }
    }
    
}

extension SearchLocationViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        //userLocation.coordinate
        //guard let UserCoordinate = userLocation.location?.coordinate else { return }
        //let coordinateRegion = MKCoordinateRegionMakeWithDistance(UserCoordinate, 10000, 10000)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 10000, 10000)
        
        mapView.setRegion(coordinateRegion, animated: true)
        
        search(for: "Pizza")
        
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        //view.annotation
        selectedLocation = view.annotation as? CLLocation
        print(selectedLocation?.coordinate)
    }
    
}

extension SearchLocationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else { return }
        mapView.showsUserLocation = true
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}


