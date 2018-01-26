//
//  ViewController.swift
//  Map Message Visualizer
//
//  Created by Admin on 8/4/17.
//  Copyright © 2017 ahmednader. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

class MapViewController: UIViewController {
    
    // MARK: outlets
    @IBOutlet weak var addButtonOultet: UIBarButtonItem!
    
    
    // MARK: variables
    // Networking Related.
    let urlString = "https://spreadsheets.google.com/feeds/list/0Ai2EnLApq68edEVRNU0xdW9QX1BqQXhHRl9sWDNfQXc/od6/public/basic?alt=json"
    var Reviews               = [UserReview]()
    
    // Map Related
    var isAdding              = false
    var mapView               : GMSMapView!
    let defaultLatitude       = 26.5493455
    let defaultLongitude      = 21.7753445
    var currentSelectedMarker = UserReview()
    
    
    // MARK: Actions
    // The add button.
    @IBAction func addButtonAction(_ sender: UIBarButtonItem) {
        // When the user taps disable it until he chooses a location to review.
        isAdding = true
        addButtonOultet.isEnabled = false
    }
    
    
    // MARK: Identifiers
    struct identifiers {
        static let detailedViewController = "ToDetailedViewController"
    }
    
    
    // MARK: VCLifeCycle
    override func loadView() {
        // Setup the camera to a default location.
        let camera = GMSCameraPosition.camera(withLatitude: defaultLatitude, longitude: defaultLongitude, zoom: 3)
        
        mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.mapType = .normal
        mapView.delegate = self
        view = mapView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the data at startup.
        getData(URLString: urlString)
    }
    
    
    // MARK: Networking methods
    /// Used to get the data from the given URL String
    ///
    /// - Parameter urlString: url for the data.
    func getData(URLString urlString : String) {
        
        // Turn the string to a url.
        let url = URL(string: urlString)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url!) {
            data,respnse,error in
            
            // Check for errors.
            if error != nil {
                self.showAlert(Title: "Network Error", Message: "\((error?.localizedDescription)!)")
            } else {
                
                // Try to turn the JSONObject to a dictionary.
                do{
                    let dataDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                    
                    // Get the feed dictionary from the data.
                    let feedDict = dataDictionary["feed"] as! [String:Any]
                    
                    // Get the entry dictionary from the feed dictionary.
                    let entryDict = feedDict["entry"] as! [[String:Any]]
                    
                    // Loop over the entries.
                    for each in entryDict {
                        
                        // Get the content dictionary of the entry dictionary.
                        let content = each["content"] as! [String:String]
                        
                        print("Message : \(content["$t"]!)")
                        // Get the message of the content dictionary
                        let message = content["$t"]
                        
                        // Seperate the message into it's main components (id,message,sentiment)
                        let components = message?.components(separatedBy: ",")
                        
                        // If there are components.
                        if components != nil{
                            DispatchQueue.main.async {
                                // Display the components on the map.
                                self.displayDataOnMap(forComponents: components!)
                            }
                        } else {
                            print("Error")
                        }
                    }
                    
                } catch  {
                    self.showAlert(Title: "Server Error", Message: "Couldn't get the data from the server")
                }
            }
            
        }
        // Start the session.
        dataTask.resume()
        
    }

    // MARK: Map drawing methods
    /// Displays the given data components on the map.
    ///
    /// - Parameter components: Components of the user review.
    func displayDataOnMap(forComponents components:[String]) {
        // Create a UserReview instance to carry the data.
        let userReview = UserReview()
        
        // If there are 5 components then the user provided a country and a city.
        if components.count == 5 {
            // Load the data into the userReview instance in order.
            userReview.messageID = components[0].components(separatedBy: "messageid:")[1]
            userReview.message = components[1].components(separatedBy: "message:")[1]
            userReview.city = components[2]
            userReview.sentiment = components[4].components(separatedBy: "sentiment:")[1]
            
        }
        // If there are 4 components then the user provided a city or a country atleast.
        else if components.count == 4 {
            
            userReview.messageID = components[0].components(separatedBy: "messageid:")[1]
            userReview.message = components[1].components(separatedBy: "message:")[1]
            userReview.city = components[2]
            userReview.sentiment = components[3].components(separatedBy: "sentiment:")[1]
            
        }
        // If there are 3 components.
        else if components.count == 3 {
            userReview.messageID = components[0].components(separatedBy: "messageid:")[1]
            userReview.message = components[1].components(separatedBy: "message:")[1]
            
            // Try to wild guess the city from the text.
            if userReview.message.contains(",") {
                userReview.message = userReview.message.components(separatedBy: ",")[0]
            }
            if userReview.message.contains(" in "){
                userReview.city = userReview.message.components(separatedBy: "in").last!
                
            } else if userReview.message.contains(" from "){
                
                userReview.city = userReview.message.components(separatedBy: "from")[1]
                
            } else if userReview.message.contains(" is "){
                userReview.city = userReview.message.components(separatedBy: "is")[0]
            } else {
                userReview.city = ""
            }
            userReview.sentiment = components[2].components(separatedBy: "sentiment:")[1]
            
        } else {
            print("\tNothing was found")
        }
        
        // Add the user review to the array of reviews.
        Reviews.append(userReview)
        // Set a marker on the map with the review.
        setMarker(forReview: userReview)
    }
    
    
    /// Sets a marker on the map for the given review.
    ///
    /// - Parameter review: The user review that will be displayed.
    func setMarker(forReview review:UserReview){
        // Filter the results according to the closest city name.
        let filter = GMSAutocompleteFilter()
        filter.type = .city
        
        // To get the full address of the place with more accuracy.
        GMSPlacesClient.shared().autocompleteQuery(review.city, bounds: nil, filter: filter, callback: {
            results,error in
            // Check for errors.
            if let error = error {
                
                print("Error : \(error.localizedDescription)")
                
            }
            // If there are returned results.
            else if let results = results {
                
                // Get the first prediction result address.
                let address = results.first?.attributedFullText.string
                
                
                print("The Result for \(review.city) IS : \(String(describing: results.first?.attributedFullText.string))")
                
                // Make sure you have the address.
                if address != nil {
                    // GeoCode the coordinates of the address to be displayed on the map.
                    self.geoCodeAddress(forAddress: address!, Review: review)
                }
            }
        })
    }
    
    
    
    /// Adds a marker on the map at the given coordinates and configures according to the review
    ///
    /// - Parameters:
    ///   - latitude: latitude of the marker.
    ///   - longitude: longitude of the marker.
    ///   - review: The user review to load marker data from.
    func markOnMap(Latitude latitude:CLLocationDegrees , Longitude longitude: CLLocationDegrees,UserReview review:UserReview) {
        
        // Create a marker
        let marker = GMSMarker()
        
        marker.appearAnimation = .pop
        
        // Change the marker color according to the sentiment.
        if review.sentiment.replacingOccurrences(of: " ", with: "") == "Positive" {
            marker.icon = GMSMarker.markerImage(with: .green)
        }
        else if review.sentiment.replacingOccurrences(of: " ", with: "") ==  "Negative" {
            marker.icon = GMSMarker.markerImage(with: .red)
        }
        else if review.sentiment.replacingOccurrences(of: " ", with: "") ==  "Neutral" {
            marker.icon = GMSMarker.markerImage(with: .yellow)
        }
        else {
            marker.icon = GMSMarker.markerImage(with: .blue)
        }
        
        // Set the title to the message.
        marker.title = review.message
        
        // Set the subtitle to the sentiment and id.
        marker.snippet =  "Sentiment:" + review.sentiment + ", id:" + review.messageID
        
        // Place it at the predicted address coordinates.
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        marker.map = self.mapView
    }
    
    
    // MARK: GeoCoding
    /// GeoCode the given address and place a marker to the coordinates of the place.
    ///
    /// - Parameters:
    ///   - address: Address of the review place.
    ///   - review: The user review.
    func geoCodeAddress(forAddress address:String,Review review:UserReview) {
        CLGeocoder().geocodeAddressString(address) {
            place ,error in
            
            // Chech for errors.
            if error != nil {
                print("ReverseGeoCoder Error : \(String(describing: error?.localizedDescription))")
            }
            else {
                // Get the predicted coordinates for the address.
                let lat = place?.last?.location?.coordinate.latitude
                let lon = place?.last?.location?.coordinate.longitude
                
                DispatchQueue.main.async {
                    // Put a marker on the map with the review and coordinates.
                    self.markOnMap(Latitude: lat!, Longitude: lon!, UserReview: review)
                }
                
            }
        }
        
    }
    
    
    
    
    // MARK: Alert
    /// Show a simple alert with a title and a message.
    ///
    /// - Parameters:
    ///   - title: Title of the alert displayed at the top.
    ///   - message: Message of the alert displayed under the title.
    func showAlert(Title title: String, Message message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alert.addAction(action)
        present(alert,animated: true)
    }
    
    /// Show an alert with an 2 editable textFields to add a review and a sentiment.
    ///
    /// - Parameters:
    ///   - title: Title of the alert
    ///   - message: Message displayed
    func showAddReviewAlert(title:String, message:String,Coordinates coordinates:CLLocationCoordinate2D){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Create a review.
        let userReview = UserReview()
        
        // The review textField
        let addReviewAction = UIAlertAction(title: "Review", style: .default, handler: {
            action in
            
            // Get the textFields in the alert.
            guard let reviewTextField = alert.textFields?.first,
                let message = reviewTextField.text else {return}
            
            guard let sentimentTextField = alert.textFields?.last,
                let sentiment = sentimentTextField.text else {return}
            
            
            
            // Load the review with the given message.
            userReview.message = message
            
            // Give it an ID of the size of the array.
            userReview.messageID = String(self.Reviews.count + 1)
            
            // Check if the user typed the sentiment correctly or default it to positive.
            if sentiment == "Positive" || sentiment == "Negative" || sentiment == "Neutral" {
                userReview.sentiment = sentiment
            } else {
                userReview.sentiment = "Positive"
            }
            
            // Add the review to the array of the reviews.
            self.Reviews.append(userReview)
            // Add a marker on the map with the review at the given coordinates.
            self.markOnMap(Latitude: coordinates.latitude, Longitude: coordinates.longitude,UserReview: userReview)
        })
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // Configure the text fields.
        alert.addTextField(configurationHandler: {
            reviewTextField in
            
            reviewTextField.placeholder = "Ex. I enjoyed visiting this place."
            reviewTextField.autocapitalizationType = .sentences
            reviewTextField.clearButtonMode = .whileEditing
        })
        
        alert.addTextField(configurationHandler: {
            sentimentTextField in

            sentimentTextField.placeholder = "Positive , Negative Or Neutral"
            sentimentTextField.autocapitalizationType = .sentences
            sentimentTextField.clearButtonMode = .whileEditing
        })
        
        alert.addAction(addReviewAction)
        alert.addAction(cancelAction)
        
        
        present(alert,animated: true)
    }
    
    
    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Make sure the segue is going to the DetailedViewController.
        if segue.identifier == identifiers.detailedViewController {
            
            let destination = segue.destination as! DetailedViewController
            // Pass the currently selected marker to the DetailedViewController to display the data.
            destination.userReview = currentSelectedMarker
        }
    }
}



// MARK: MapDelegate
extension MapViewController : GMSMapViewDelegate {
    
    // User tapped on the info window of a marker.
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
        var ID = ""
        // Get the ID of the marker.
        ID = (marker.snippet?.components(separatedBy: "id:")[1])!
        // Remove any spaces.
        ID = ID.replacingOccurrences(of: " ", with: "")
        // Set the currently selected marker to the Review with the ID.
        currentSelectedMarker = Reviews[Int(ID)! - 1]
        // Go to the DetailedViewController.
        performSegue(withIdentifier: identifiers.detailedViewController, sender: nil)
        
    }
    

    
    // When the user taps on a place on the map.
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        // If the add button was clicked.
        if isAdding {
            // Show the review alert to get the review from the user.
            showAddReviewAlert(title: "Add a review", message: "",Coordinates:coordinate)
            
            // Reenable the button
            isAdding = false
            addButtonOultet.isEnabled = true
        }
        
    }
    
}

