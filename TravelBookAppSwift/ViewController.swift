//
//  ViewController.swift
//  TravelBookAppSwift
//
//  Created by Enes Kala on 2.03.2024.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController, MKMapViewDelegate,CLLocationManagerDelegate {

    @IBOutlet weak var nameText: UITextField!
    
    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    
    var chosenLatitude = Double()
    var chosenLongitude = Double()
    
    var selectedTitle = ""
    var selectedId = UUID()
    
    var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        if selectedTitle != "" {
            //coredata
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchReguest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            let idString = selectedId.uuidString
            let predicate = NSPredicate(format: "id = %@",idString)
            fetchReguest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchReguest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let title = result.value(forKey: "title") as? String {
                            annotationTitle = title
                        }
                        if let subtitle = result.value(forKey: "subtitle") as? String {
                            annotationSubtitle = subtitle
                        }
                        if let latitude = result.value(forKey: "latitude") as? Double{
                            annotationLatitude = latitude
                        }
                        if let longitude = result.value(forKey: "longitude") as? Double{
                            annotationLongitude = longitude
                        }
                        
                        
                        let annotation = MKPointAnnotation()
                        annotation.title = annotationTitle
                        annotation.subtitle = annotationSubtitle
                        let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                        annotation.coordinate = coordinate
                        mapView.addAnnotation(annotation)
                        nameText.text = annotationTitle
                        commentText.text = annotationSubtitle
                    }
                }
            }catch{
                print("Error at id ")
            }
            
            
            
        }else{
            
        }
        
        
        
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization() // izin aldık
        locationManager.startUpdatingLocation()
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer: )))
        mapView.addGestureRecognizer(gestureRecognizer)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    @objc func chooseLocation(gestureRecognizer : UILongPressGestureRecognizer) {
        
        if gestureRecognizer.state == .began {
            
            let touchedPoint = gestureRecognizer.location(in: self.mapView)
            let touchedPointCoordinate = mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            
            
            chosenLatitude = touchedPointCoordinate.latitude
            chosenLongitude = touchedPointCoordinate.longitude
            
            let annotation = MKPointAnnotation()
            annotation.title = nameText.text!
            annotation.coordinate = touchedPointCoordinate
            annotation.subtitle = commentText.text!
            
            self.mapView.addAnnotation(annotation)
            
            
        }
        
    }


    @IBAction func saveButtonClicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPlaces = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        newPlaces.setValue(nameText.text!, forKey: "title")
        newPlaces.setValue(commentText.text!, forKey: "subtitle")
        newPlaces.setValue(UUID(), forKey: "id")
        newPlaces.setValue(chosenLatitude, forKey: "latitude")
        newPlaces.setValue(chosenLongitude, forKey: "longitude")
        
        do{
            try context.save()
            print("Success")
        }catch{
            print("error at save")
        }
        
    }
}

