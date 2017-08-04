//
//  ViewController.swift
//  Map Message Visualizer
//
//  Created by Admin on 8/4/17.
//  Copyright © 2017 ahmednader. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class MapViewController: UIViewController {
    
    let mapView = GMSMapView()
    let defaultLatitude       = 26.5493455
    let defaultLongitude      = 21.7753445
    let cityName              = "Cairo"
    
    
    override func loadView() {
        
        let camera = GMSCameraPosition.camera(withLatitude: defaultLatitude, longitude: defaultLongitude, zoom: 10)
        mapView.camera = camera
        view = mapView
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        CLGeocoder().geocodeAddressString(cityName){
            place ,error in
            
            if error != nil {
                print("ReverseGeoCoder Error : \(error?.localizedDescription)")
            }
            else {
                let lat = place?.first?.location?.coordinate.latitude
                let lon = place?.first?.location?.coordinate.longitude
                
                self.mapView.animate(toLocation: CLLocationCoordinate2D(latitude: lat!, longitude: lon!))
                
                let marker = GMSMarker()
                
                marker.icon  = #imageLiteral(resourceName: "Positive.png")
                marker.title = "I had fun in here"
                marker.position = CLLocationCoordinate2D(latitude: lat!, longitude: lon!)
                
                marker.map = self.mapView
                
            }
            
        }
    }

    


}

