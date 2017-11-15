//
//  SearchLocationViewController.swift
//  Carpool
//
//  Created by Zaller on 11/8/17.
//  Copyright © 2017 Codebase. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var selectLocationButton: UIButton!
    
    
    var annotations: [MKAnnotation] = []
    var selectedLocation: CLLocation?
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        mapView.delegate = self
        selectLocationButton.isEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        
        mapView.showAnnotations(annotations, animated: true)
    }
    
    @IBAction func onCancelButtonPressed(_ sender: UIButton) {
        selectedLocation = nil
        performSegue(withIdentifier: "unwindToCreateTrip", sender: self)
    }
}

extension MapViewController: MKMapViewDelegate {
//    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
//        let coordinateRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 10000, 10000)
//        mapView.setRegion(coordinateRegion, animated: true)
//        mapView.addAnnotations(annotations)
//        print(annotations)
//    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let coordinate = view.annotation?.coordinate else { return }
        selectedLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        selectLocationButton.isEnabled = true
        print(selectedLocation)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        selectLocationButton.isEnabled = false
        selectedLocation = nil
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else { return }
        mapView.showsUserLocation = true
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}


