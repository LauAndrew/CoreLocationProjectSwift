//
//  MapViewController.swift
//  CoreLocationProject
//
//  Created by Enrico Pineda on 9/14/17.
//  Copyright © 2017 Eat_JR. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import UserNotifications

class MapViewController: UIViewController, UISearchBarDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        //locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        {(granted, error) in}
        }
    
    
    @IBAction func searchButton(_ sender: Any) {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self as UISearchBarDelegate
        present(searchController, animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        self.view.addSubview(activityIndicator)
        
        //Hide Search Bar
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        //Create Search Request
        let searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        
        activeSearch.start { (response, error) in
            
            activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if response == nil
            {
        print ("error")
            }
            else
            {
                // Remove Annotations
                let annotations = self.mapView.annotations
                self.mapView.removeAnnotations(annotations)
                
                //Getting Data
                let latitude = response?.boundingRegion.center.latitude
                let longitude = response?.boundingRegion.center.longitude
                
                // Create Annotaitions
                let annotation = MKPointAnnotation()
                annotation.title = searchBar.text
                annotation.coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
                self.mapView.addAnnotation(annotation)
                
                //Zooming in on annotation
                let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude!, longitude!)
                let span = MKCoordinateSpanMake(0.1, 0.1)
                let region = MKCoordinateRegionMake(coordinate, span)
                self.mapView.setRegion(region, animated: true)
                
                
            }
        }
        
        
    }
    
    
    @IBAction func addRegion(_ sender: Any?) {
        print("add region")
        guard let longPress = sender as? UILongPressGestureRecognizer else
        {return}
        let touchLocation = longPress.location(in: mapView)
        let coordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        let region = CLCircularRegion(center: coordinate, radius: 200, identifier: "geofence")
        
        mapView.removeOverlays(mapView.overlays)
        locationManager.startMonitoring(for: region)
        let circle = MKCircle(center: coordinate, radius: region.radius)
        mapView.add(circle)

    }
    
    func showAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated:  true, completion: nil)
        
    }
    
    func showNotification(title: String, message: String){
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.badge = 1
        content.sound = .default()
        let request = UNNotificationRequest(identifier: "notif", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
    }

}

extension MapViewController: CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //locationManager.stopUpdatingLocation()
        //mapView.showsUserLocation = true
        
        let location = locations[0]
        
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let myLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
       let region: MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        mapView.setRegion(region, animated: true)
        
        mapView.showsUserLocation = true
        
        let pin = MKPointAnnotation()
        
        mapView.addAnnotation(pin)
        
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let title = "You entered region"
        let message = "Nice"
        showAlert(title: title, message: message)
        showNotification(title: title, message: message)
    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let title = "You exited region"
        let message = "Bye"
        showAlert(title: title, message: message)
        showNotification(title: title, message: message)
    }
}

extension MapViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let circleOverlay = overlay as? MKCircle else {
            return MKOverlayRenderer()
        }
        let circleRenderer = MKCircleRenderer(circle: circleOverlay)
        circleRenderer.strokeColor = .blue
        circleRenderer.fillColor = .blue
        circleRenderer.alpha = 0.5
        return circleRenderer
    }
}




















