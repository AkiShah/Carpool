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
        
        mapView.addAnnotations(annotations)
    }
    
    @IBAction func onSelectLocationPressed(_ sender: Any) {
        performSegue(withIdentifier: "unwindFromMap", sender: self)
    }
    
    
    @IBAction func onCancelButtonPressed(_ sender: UIButton) {
        selectedLocation = nil
        performSegue(withIdentifier: "unwindFromMap", sender: self)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 2000, 2000)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.addAnnotations(annotations)
    }
    
    
    //Trying to figure out how to get all annotations to show at once. 
//    func zoomMapToFitAnnotations() {
//
//        var zoomRect = MKMapRectNull
//        for annotation in mapView.annotations {
//
//            let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
//
//            let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0)
//
//            if (MKMapRectIsNull(zoomRect)) {
//                zoomRect = pointRect
//            } else {
//                zoomRect = MKMapRectUnion(zoomRect, pointRect)
//            }
//        }
//        self.mapView.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsetsMake(50, 50, 50, 50), animated: true)
//    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let coordinate = view.annotation?.coordinate else { return }
        selectedLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        selectLocationButton.isEnabled = true
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
        //TODO error handling
        print(error)
    }
}


