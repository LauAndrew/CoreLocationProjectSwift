//
//  mapViewController.swift
//  CoreLocationProject
//
//  Created by Toro Roan on 9/14/17.
//  Copyright © 2017 Eat_JR. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import UserNotifications


class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in }
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
    }
    
    @IBAction func addRegion(_ sender: Any) {
        guard let longPressed = sender as? UILongPressGestureRecognizer else
            {return}
        let touchLocation = longPressed.location(in: mapView)
        let coordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        let region = CLCircularRegion(center: coordinate, radius: 50, identifier: "geofence")
        mapView.removeOverlays(mapView.overlays)
        locationManager.startMonitoring(for: region)
        let cicrle = MKCircle(center: coordinate, radius: region.radius)
        mapView.add(cicrle)
        
        let newPin = MKPointAnnotation()
        newPin.coordinate = coordinate
        mapView.addAnnotation(newPin)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Oops", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func showNotification(title: String, message: String) {
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        let location = locations[0]
        mapView.setRegion(MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500), animated: true)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let title = "Reminder"
        let message = "Stuff you need to do"
        showAlert(title: title, message: message)
        showNotification(title: title, message: message)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let title = "Reminder"
        let message = "Have you completed it?"
        showAlert(title: title, message: message)
        showNotification(title: title, message: message)
    }
    
    
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let circleOverlay = overlay as? MKCircle
            else {
                return MKOverlayRenderer()
            }
        let circleRenderer = MKCircleRenderer(circle: circleOverlay)
        circleRenderer.strokeColor = .blue
        circleRenderer.fillColor = .blue
        circleRenderer.alpha = 0.5
        return circleRenderer
    }
}
