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
    
    var query: String = "SCAD"
    let locationManager = CLLocationManager()
    var selectedLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    @IBAction func onCancelButtonPressed(_ sender: UIButton) {
        selectedLocation = nil
    }
    
    
    func search(for query: String) {
        let searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = query
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { (searchResp, error) in
            if let searchResp = searchResp {
                self.mapView.addAnnotations(searchResp.mapItems.map({ $0.placemark }))
                print(searchResp.mapItems.map({ $0.placemark }))
            }
        }
    }
    
}

extension SearchLocationViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 10000, 10000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let coordinate = view.annotation?.coordinate else { return }
        selectedLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        print(selectedLocation?.coordinate)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.search(for: self.query)
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


