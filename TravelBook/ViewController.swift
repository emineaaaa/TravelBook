//
//  ViewController.swift
//  TravelBook
//
//  Created by Emine Aydınlı on 29.07.2024.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController ,MKMapViewDelegate ,CLLocationManagerDelegate ,UITextFieldDelegate{

    @IBOutlet weak var commmentText: UITextField!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    var locationManager=CLLocationManager()
    var chosenLatitude=Double()
    var chosenLongitude=Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate=self
        locationManager.delegate=self
        locationManager.desiredAccuracy=kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let gestureRecognizer=UILongPressGestureRecognizer(target: self, action: #selector(choosenLocation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration=3
        mapView.addGestureRecognizer(gestureRecognizer)
        
        nameText.delegate = self
        commmentText.delegate = self
               
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func hideKeyboard() {
           view.endEditing(true)
       }

    
    @objc func choosenLocation(gestureRecognizer: UILongPressGestureRecognizer) {
           if gestureRecognizer.state == .began {
               if nameText.text?.isEmpty == true || commmentText.text?.isEmpty == true {
                   let alert = UIAlertController(title: "Error", message: "Name and comment cannot be empty before adding a location.", preferredStyle: .alert)
                   let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                   alert.addAction(okAction)
                   present(alert, animated: true, completion: nil)
               } else {
                   let touchedPoint = gestureRecognizer.location(in: self.mapView)
                   let touchedCoordinates = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
                   
                   chosenLatitude = touchedCoordinates.latitude
                   chosenLongitude = touchedCoordinates.longitude
                   
                   let annotation = MKPointAnnotation()
                   annotation.coordinate = touchedCoordinates
                   annotation.title = nameText.text
                   annotation.subtitle = commmentText.text
                   self.mapView.addAnnotation(annotation)
               }
           }
       }
       
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location=CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span=MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region=MKCoordinateRegion(center:location, span:span)
        mapView.setRegion(region, animated: true)
    }

    @IBAction func saveButtonClicked(_ sender: Any) {
        if nameText.text?.isEmpty == true || commmentText.text?.isEmpty == true {
            
            let alert = UIAlertController(title: "Error", message: "Name and comment cannot be empty.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        } else {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
            
            newPlace.setValue(nameText.text, forKey: "title")
            newPlace.setValue(commmentText.text, forKey: "subtitle")
            newPlace.setValue(chosenLatitude, forKey: "latitude")
            newPlace.setValue(chosenLongitude, forKey: "longitude")
            newPlace.setValue(UUID(), forKey: "id")


            do {
                try context.save()
                print("Saved successfully")
            } catch {
                print("Failed to save: \(error.localizedDescription)")
            }
        }
    }

}

