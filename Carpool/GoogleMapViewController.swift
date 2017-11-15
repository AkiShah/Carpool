////
////  GoogleMapViewController.swift
////  Carpool
////
////  Created by Zaller on 11/13/17.
////  Copyright © 2017 Codebase. All rights reserved.
////
//
//import UIKit
//import MapKit
//
//class GoogleMapViewController: UIViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
//
//    @IBOutlet weak var theMap: MKMapView!
//    @IBOutlet weak var searchText: UITextField!
//    var matchingItems: [MKMapItem] = []
//    @IBAction func onTextFieldReturn(_ sender: UITextField) {
//        _ = sender.resignFirstResponder()
//        mapView.removeAnnotations(mapView.annotations)
//        self.performSearch()
//    }
//
//    let mapView = MKMapView()
//    let request = MKLocalSearchRequest()
//
//    func performSearch() {
//
//        matchingItems.removeAll()
//        let request = MKLocalSearchRequest()
//        request.naturalLanguageQuery = searchText.text
//        request.region = mapView.region
//
//        let search = MKLocalSearch(request: request)
//
//        search.start(completionHandler: {(response, error) in
//
//            if error != nil {
//                print("Error occured in search: \(error!.localizedDescription)")
//            } else if response!.mapItems.count == 0 {
//                print("No matches found")
//            } else {
//                print("Matches found")
//
//                for item in response!.mapItems {
//                    print("Name = \(item.name)")
//                    print("Phone = \(item.phoneNumber)")
//
//                    self.matchingItems.append(item as MKMapItem)
//                    print("Matching items = \(self.matchingItems.count)")
//
//                    let annotation = MKPointAnnotation()
//                    annotation.coordinate = item.placemark.coordinate
//                    annotation.title = item.name
//                    self.mapView.addAnnotation(annotation)
//                }
//            }
//        })
//    }
//}

