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
    @IBOutlet weak var locationbtn: UIButton!
    
    var locationManager = CLLocationManager()
    var destination : CLLocationCoordinate2D!
    
    var transportType : MKDirectionsTransportType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //adding map delegate to show polyline on map
        map.delegate = self
        
        //assigning location delegate
        locationManager.delegate = self
        
        //for accuracy
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //requesting location
        locationManager.requestWhenInUseAuthorization()
        
        //start location update
        locationManager.startUpdatingLocation()
        
        locationbtn.isHidden = true
        
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
        map.removeOverlays(map.overlays)
        
        let location = gestureRecognizer.location(in: map)
        let coordinates = map.convert(location, toCoordinateFrom: map)
        
        //adding annotation
        let annotation = MKPointAnnotation()
        annotation.title = "Destination"
        annotation.coordinate = coordinates
        map.addAnnotation(annotation)
        
        locationbtn.isHidden = false
        destination = coordinates
        
    }
    
    @IBAction func drawRoute(_ sender: UIButton) {
        //this will remove all the overlays
        map.removeOverlays(map.overlays)
        
        //getting the destination
        let sourcePlaceMarker = MKPlacemark(coordinate: locationManager.location!.coordinate)
        let destinationPlaceMarker = MKPlacemark(coordinate: destination)
        
        //request direction
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourcePlaceMarker)
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMarker)
        
        //transport type
        directionRequest.transportType = .automobile
        
        //calculating the direction
        let directions =  MKDirections(request: directionRequest)
        directions.calculate{ response,error in
            guard let directionResponse = response else {return}
            
            //create route
            let route = directionResponse.routes[0]
            //draw polyline
            self.map.addOverlay(route.polyline, level: .aboveRoads)
            
            //define map boundary for screen
            let rect = route.polyline.boundingMapRect
            self.map.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top:100,left:100,bottom:100,right:100), animated: true)
            
            
        }
    }
}

extension ViewController : MKMapViewDelegate{
    //for rendering the polyline
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle{
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.fillColor = UIColor.black.withAlphaComponent(0.5)
            renderer.strokeColor = .green
            renderer.lineWidth = 2
            return renderer
        }else if overlay is MKPolyline{
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .blue
            renderer.lineWidth = 5
            return renderer
        }
        return MKOverlayRenderer()
    }
}

