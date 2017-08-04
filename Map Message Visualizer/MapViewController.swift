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
    
    var mapView               : GMSMapView!
    let defaultLatitude       = 26.5493455
    let defaultLongitude      = 21.7753445
    let cityName              = "Tahrir"
    
    
    override func loadView() {
        
        let camera = GMSCameraPosition.camera(withLatitude: defaultLatitude, longitude: defaultLongitude, zoom: 10)
        
        mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.mapType = .normal
        mapView.delegate = self
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
                
                let lat = place?.last?.location?.coordinate.latitude
                let lon = place?.last?.location?.coordinate.longitude
                
                self.mapView.animate(toLocation: CLLocationCoordinate2D(latitude: lat!, longitude: lon!))
                
                let marker = GMSMarker()
                
                // Do a switch on the data to find the sentiment.
                marker.icon = GMSMarker.markerImage(with: .green)
                
                // Set the title to the message.
                marker.title = "I had fun in here"
                
                
                marker.position = CLLocationCoordinate2D(latitude: lat!, longitude: lon!)
                
                marker.map = self.mapView
                
            }
            
        }
        
        
        let url = URL(string: "https://spreadsheets.google.com/feeds/list/0Ai2EnLApq68edEVRNU0xdW9QX1BqQXhHRl9sWDNfQXc/od6/public/basic?alt=json")
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url!) {
            data,respnse,error in
            
            if error != nil {
                print("Error : \(error?.localizedDescription)")
            } else {
                
                do{
                    let d = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                    
                    //print("Data[feed] : \(d["feed"])")
                    let e = d["feed"] as! [String:Any]
                    //print("Data[entry] : \(e["entry"]) ")
                    
                    let every = e["entry"] as! [[String:Any]]
                    
                    for each in every {
                        //print("Each : \(each["content"]!) ")
                        let m = each["content"] as! [String:String]
                        
                    
                        print("Message : \(m["$t"]!)")
                    }
                    
                    
                } catch {
                    print("JSON Error")
                }
                
                
                
                
            }
        }
        dataTask.resume()
        
    }
    
    func showAlert(Title title: String, Message message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alert.addAction(action)
        present(alert,animated: true)
    }
}


extension MapViewController : GMSMapViewDelegate {
    
    
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        showAlert(Title: "OKKK", Message: "Will go to")
    }
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("Tap location : \(coordinate.latitude),\(coordinate.longitude)")
    }
    
}

