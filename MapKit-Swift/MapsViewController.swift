//
//  ViewController.swift
//  MapKit-Swift
//
//  Created by Fazlı Koç on 27.09.2022.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapsViewController: UIViewController,MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var isimField: UITextField!
    @IBOutlet weak var noteField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager=CLLocationManager()
    
    var selectedLatitude = Double()
    var selectedLongitude = Double()
    
    
    var slctDetailName = String()
    var slctDetailID : UUID?
    
    
    var annotationName = String()
    var annotationNote = String()
    var annotationLatitude = Double()
    
    var annotationLongitude = Double()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(selectLocaton(gesture:)))
        gestureRecognizer.minimumPressDuration = 1
        mapView.addGestureRecognizer(gestureRecognizer)
        
        
        if slctDetailName != ""{
            
            if let uuidCast = slctDetailID?.uuidString{
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
                request.predicate =  NSPredicate(format: "id = %@", uuidCast)
                request.returnsObjectsAsFaults = false
                
                do{
                    let datas = try context.fetch(request)
                    print(datas.count)
                    if datas.count > 0 {
                        for data in datas as! [NSManagedObject]{
                            
                            if let nameCast = data.value(forKey: "name") as? String{
                                annotationName = nameCast
                                if let noteCast = data.value(forKey: "note") as? String{
                                    annotationNote = noteCast
                                    if let latitudeCast = data.value(forKey: "latitude") as? Double{
                                        annotationLatitude=latitudeCast
                                        if let longitudeCast = data.value(forKey: "longitude") as? Double{
                                            annotationLongitude=longitudeCast
                                            
                                            
                                            let annotation = MKPointAnnotation()
                                            annotation.title=annotationName
                                            annotation.subtitle=annotationNote
                                            let cordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                                            
                                            annotation.coordinate = cordinate
                                            
                                            mapView.addAnnotation(annotation)
                                            isimField.text = annotationName
                                            noteField.text = annotationNote
                                            noteField.text = annotationNote
                                            
                                            locationManager.stopUpdatingLocation()
                                            
                                            
                                            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                            
                                            let mkCordinateRegion = MKCoordinateRegion(center: cordinate, span: span)
                                            
                                            mapView.setRegion(mkCordinateRegion, animated: true)
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                            
                            
                            
                            
                        }
                    }
                }
                catch{print("Mapse veriler çekilemedi")}
            }
            
            
        }
        else{
            //yeni veri ekleyecek
        }
    }
    
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if slctDetailName != "" {
            
            let requestLocation = CLLocation(latitude: annotationLatitude, longitude: annotationLongitude)
            
            CLGeocoder().reverseGeocodeLocation(requestLocation, completionHandler:
                 {(placemarks, error) in
             
                if let placemarksCast = placemarks {
                    
                    if placemarksCast.count > 0 {
                      
                        let item=MKMapItem(placemark: MKPlacemark(placemark: placemarksCast[0]))
                        
                        item.name=self.annotationName
                        item.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
                        
                        
                    }
                }
             })
        }
    }
    
    fileprivate func customPinView(_ mapView: MKMapView, _ annotation: MKAnnotation) -> MKAnnotationView? {
        let reusedID = "ourAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reusedID)
        
        if pinView == nil {
            
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reusedID )
            pinView?.canShowCallout = true
            pinView?.tintColor = .red
            
            let buttonPin = UIButton(type: .detailDisclosure)
            
            pinView?.rightCalloutAccessoryView = buttonPin
            
            
            
        }
        else{
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        
        if annotation is MKUserLocation{
            return nil
        }
        else{
            return customPinView(mapView, annotation)
        }
    }
    
    @objc func selectLocaton(gesture : UILongPressGestureRecognizer){
        
        if gesture.state == .began {
            let touchPoint = gesture.location(in: mapView)
            let touchCordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            
            
            selectedLatitude=touchCordinate.latitude
            selectedLongitude=touchCordinate.longitude
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchCordinate
            annotation.title = isimField.text
            annotation.subtitle = noteField.text
            mapView.addAnnotation(annotation)
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if slctDetailName == "" {
            let location =  CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
            
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            
            let mkCordinateRegion = MKCoordinateRegion(center: location, span: span)
            
            mapView.setRegion(mkCordinateRegion, animated: true)
        }
    }
    
    
    @IBAction func saveButton(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        
        let newArea = NSEntityDescription.insertNewObject(forEntityName: "Location", into: context)
        
        newArea.setValue(isimField.text, forKey: "name")
        newArea.setValue(noteField.text, forKey: "note")
        newArea.setValue(selectedLatitude, forKey: "latitude")
        newArea.setValue(selectedLongitude, forKey: "longitude")
        newArea.setValue(UUID(), forKey: "id")
        
        do{
            try context.save()
        }
        catch{
            print("Veri giderken hata oldu")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "insert"), object: nil)
        navigationController?.popViewController(animated: true)
    }
    
    
    
}

