//
//  ViewController.swift
//  realTimeLocationTracking
//
//  Created by Vinayak Tudayekar on 10/08/19.
//  Copyright © 2019 Vinayak Tudayekar. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Reachability

class ViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var distanceCovered: UILabel!
    
    @IBOutlet weak var distanceView: UIView!
    
    var locationManager = CLLocationManager()
    var latitude:Double?
    var longitude:Double?
    var lastLatitude:Double?
    var lastLongitude:Double?
    var centerFirst : CLLocation? = nil
    var centerLast : CLLocation? = nil
    var coordinate2D = CLLocationCoordinate2DMake(22, 50)
    var camera = MKMapCamera()
    var sourceLocation = CLLocationCoordinate2D()
    var DestinationLocation = CLLocationCoordinate2D()
    var reachability = Reachability()
    var startLocation:CLLocation? = nil
    
    //MARK:-View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        distanceView.isHidden = true
        mapView.delegate = self
        locationManager.delegate = self
        updateMapRegion(rangeSpan: 300)
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.mapType = MKMapType(rawValue: 0)!
        mapView.userTrackingMode = MKUserTrackingMode(rawValue: 2)!
        
        //Notification addObserver for reachability
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do{
            try reachability?.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
      
    }
    override func viewDidDisappear(_ animated: Bool) {
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
    }
    
    //MARK:- Check Internet reachability
    //Notification reciever
    @objc func reachabilityChanged(note: Notification) {
        
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi:
            print("Reachable via WiFi")
        case .cellular:
            print("Reachable via Cellular")
        case .none:
            print("Network not reachable")
            alert(message: "You have no internet connection", title: "This is an alert")
        }
    }
    
  
    
    //MARK: Location
    func setupCoreLocation(){
        switch CLLocationManager.authorizationStatus(){
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            break
        case .authorizedAlways,.authorizedWhenInUse:
            enableLocationServices()
        case .restricted,.denied:
            showAlert("You have to enable the Location Service to use this App. To enable, please go to Settings->Privacy->Location Services")
        default:
            break
        }
    }
    //MARK:- Start location service
    func enableLocationServices(){
        if CLLocationManager.locationServicesEnabled(){
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.distanceFilter = 50
            locationManager.startUpdatingLocation()
            
            mapView.setUserTrackingMode(.followWithHeading, animated: true)
        }
        
    }
    //MARK: End Location service
    func disableLocationServies(){
        locationManager.stopUpdatingLocation()
    }
    func updateMapRegion(rangeSpan:CLLocationDistance){
        let region = MKCoordinateRegion(center: coordinate2D, latitudinalMeters: rangeSpan, longitudinalMeters: rangeSpan)
        mapView.region = region
    }
 
    func updateMapCamera(heading:CLLocationDirection, altitude:CLLocationDistance){
        camera.centerCoordinate = coordinate2D
        camera.heading = heading
        camera.altitude = altitude
        camera.pitch = 0.0
       // changePitch.setTitle("0º", for: .normal)
        mapView.camera = camera
    }
 

    //MARK: Overlay delegates
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 5.0
        renderer.alpha = 0.7
        return renderer
    }
   
    //MARK:Location Manager Delegates
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            print("authorized always")
        case .authorizedWhenInUse:
            print("authorizedWhenInUse")
        case .denied,.restricted:
            print("Not athorized")
             showAlert("You have to enable the Location Service to use this App. To enable, please go to Settings->Privacy->Location Services")
        default:
            print("default")
            locationManager.requestAlwaysAuthorization()
        }
    }
  
    
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        
        if let location = locations.first
        {
        print("first location : \(location.coordinate.latitude), \(location.coordinate.longitude)")
            
         //   let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
            
           self.centerFirst = CLLocation(latitude:    self.latitude!, longitude:self.longitude!)
            
            if startLocation == nil
            {
                self.startLocation = self.centerFirst
            }
           // self.sourceLocation = CLLocationCoordinate2D (latitude: self.latitude!,longitude: self.longitude!)
        
        }
        if let location2 = locations.last{
             print("last location : \(location2.coordinate.latitude), \(location2.coordinate.longitude)")
          //  let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            self.lastLatitude = location2.coordinate.latitude
            self.lastLongitude = location2.coordinate.longitude
              self.centerLast = CLLocation(latitude:    self.lastLatitude!, longitude:self.lastLongitude!)
            self.DestinationLocation = CLLocationCoordinate2D(latitude: self.lastLatitude!,longitude: self.lastLongitude!)
            
        }
        
        
        addDirectionOnMap()
        addAnnotationsOnMap(locationToPoint: self.centerLast!)
        addAnnotationsOnMap(locationToPoint: self.centerFirst!)
        
       
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if (error as? CLError)?.code == .denied {
            manager.stopUpdatingLocation()
         
        }
    }
    func addDirectionOnMap()
    {
        
        // let sourcePlacemark = MKPlacemark(coordinate: self.DestinationLocation)
        let destinationPlacemark = MKPlacemark(coordinate: self.DestinationLocation)
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem.forCurrentLocation()
        directionRequest.requestsAlternateRoutes = false
        //    directionRequest.source = MKMapItem(placemark: sourcePlacemark)
        directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
        directionRequest.transportType = .any
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let directionResonse = response else {
                if let error = error {
                    print("we have error getting directions==\(error.localizedDescription)")
                }
                return
            }
            for route in response?.routes ?? []
            {
                self.mapView?.addOverlay(route.polyline, level: .aboveRoads)
                
                //  let rect = route.polyline.boundingMapRect
                //self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
            }
            
            
            
            
        }
        //Calculate distance
        distanceView.isHidden = false
        let distance = centerLast!.distance(from:  self.startLocation!)/1000
        distanceCovered.text = "\(distance)"+"Km"
        print("distance = \(distance)")
    }

    //MARK:-function to add annotation to map view
    func addAnnotationsOnMap(locationToPoint : CLLocation){
        
        var annotation = MKPointAnnotation()
        annotation.coordinate = locationToPoint.coordinate
        var geoCoder = CLGeocoder ()
        geoCoder.reverseGeocodeLocation(locationToPoint, completionHandler: { (placemarks, error) -> Void in
            
            if let placemarks = placemarks as? [CLPlacemark], placemarks.count > 0 {
                var placemark = placemarks[0]
                var addressDictionary = placemark.addressDictionary;
               
                annotation.title = addressDictionary?["City"] as? String
              
                annotation.subtitle = addressDictionary?["Name"] as? String
                self.sourceLocation = CLLocationCoordinate2D(latitude: self.latitude!, longitude:  self.longitude!)
                
                 self.DestinationLocation = CLLocationCoordinate2D(latitude: self.lastLatitude!, longitude: self.lastLongitude!)
                
                let sourcePin = PlaceAnnotation(coordinate: self.sourceLocation, title:annotation.title, subtitle: annotation.subtitle)
                
               let destinationPin = PlaceAnnotation(coordinate: self.DestinationLocation, title: annotation.title , subtitle: annotation.subtitle)
                
               // self.mapView.addAnnotation(sourcePin)
               self.mapView.addAnnotation(destinationPin)
                
            }
        })
    }
    
    //MARK:- Button action
    @IBAction func startTrackBtn(_ sender: Any)
    {
        setupCoreLocation()
      
        
    }
    @IBAction func endTrackBtn(_ sender: Any)
    {
       locationManager.stopUpdatingLocation()
        if CLLocationManager.locationServicesEnabled(){
            
            if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways) || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse
            {
                
            addAnnotationsOnMap(locationToPoint: self.centerLast!)
            }
        }
       
       
    }
    
}

