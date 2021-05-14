//
//  ViewController.swift
//  Map_App_demo1
//
//  Created by SatnamSingh on 14/05/21.
//

import UIKit
import MapKit

class ViewController: UIViewController ,CLLocationManagerDelegate{

    @IBOutlet weak var map: MKMapView!
    var locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //assigning location delegate
        locationManager.delegate = self
        
        //for accuracy
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //requesting location
        locationManager.requestWhenInUseAuthorization()
        
        //start location update
        locationManager.startUpdatingLocation()
        
        // following is used for long press
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        map.addGestureRecognizer(longPressGesture)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
        doubleTapGesture.numberOfTapsRequired = 2
        map.addGestureRecognizer(doubleTapGesture)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location  = locations[0]
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        displayLocation(latitude: latitude, longitude: longitude, title: "Your location", subtitle: "You are here")
        
    }
    
    
    func displayLocation(latitude:CLLocationDegrees,
                         longitude:CLLocationDegrees,
                         title:String,
                         subtitle:String)
    {
        //define span
        let latDelta:CLLocationDegrees = 0.05
        let longDelta:CLLocationDegrees = 0.05
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
        
        //get location
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        //define region where we want to display marker
        let region = MKCoordinateRegion(center: location, span: span)
        
        //set region and for smooth animation.
        map.setRegion(region, animated: true)
        
        //adding annotation
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.subtitle = subtitle
        annotation.coordinate = location
        map.addAnnotation(annotation)
    }
    
    @objc func longPress(_ gestureRecognizer : UIGestureRecognizer){
        let location = gestureRecognizer.location(in: map)
        let coordinates = map.convert(location, toCoordinateFrom: map)
        
        //adding annotation
        let annotation = MKPointAnnotation()
        annotation.title = "My places"
        annotation.coordinate = coordinates
        map.addAnnotation(annotation)
    }
    
    @objc func doubleTap(_ gestureRecognizer : UITapGestureRecognizer){
        
        //to remove all the previous annotations
        map.removeAnnotations(map.annotations)
        
        let location = gestureRecognizer.location(in: map)
        let coordinates = map.convert(location, toCoordinateFrom: map)
        
        //adding annotation
        let annotation = MKPointAnnotation()
        annotation.title = "My places"
        annotation.coordinate = coordinates
        map.addAnnotation(annotation)
    }
    

}

