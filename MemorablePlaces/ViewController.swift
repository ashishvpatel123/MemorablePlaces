//
//  ViewController.swift
//  MemorablePlaces
//
//  Created by IMCS2 on 2/23/19.
//  Copyright © 2019 IMCS2. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class LocationInfo {
    var title : String = ""
    var discription : String = ""
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    
    init(title: String,discription: String,latitude : Double,longitude: Double) {
        self.title = title
        self.discription = discription
        self.latitude = latitude
        self.longitude = longitude
    }
    
}

class ViewController: UIViewController , MKMapViewDelegate {
    
    var locationInfos = [LocationInfo]()
    
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let regionRadius: CLLocationDistance = 1000
        //Do any additional setup after loading the view
        let initialLocation = CLLocation(latitude: 32.900854, longitude: -96.969862)
        let coordinateRegion = MKCoordinateRegion(center: initialLocation.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        
        getDataFromCoreData()
        for location in locationInfos {
            putAnnaotaionToMap(locationinfo: location)
        }
        
        
        //added gesture recognizer to the screen
        let uiLongPress = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressAction(gustureRecognizer:)))
        uiLongPress.minimumPressDuration = 2.0
        mapView.addGestureRecognizer(uiLongPress)
    }
    
    
    
    // longPress adding annotation into the map
    @objc func longPressAction(gustureRecognizer : UIGestureRecognizer){
       
        print("long presed")
        let touchPoint = gustureRecognizer.location(in: self.mapView)
        let coordinates = mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
        alertView(coordinates : coordinates)
    }
    
    
    // alert view to get location information
    func alertView(coordinates : CLLocationCoordinate2D){
        let alert = UIAlertController(title: "Add Location", message: "Please Enter Title and Discription", preferredStyle: .alert)
        alert.addTextField { (textFiled ) in
            textFiled.placeholder = "Title"
        }
        alert.addTextField { (textFiled) in
            textFiled.placeholder = "Discription"
        }
        let actionCancle = UIAlertAction(title: "Cancle", style: .destructive, handler: nil)
        let actionSave = UIAlertAction(title: "Save", style: .default) { (_) in
            let titleTextField = alert.textFields?[0].text!
            //print(titleTextField)
            let subTitleTextField = alert.textFields?[1].text!
            //print(subTitleTextField)
            //return (titleTextField,subTitleTextField)]
            let locationInfo = LocationInfo(title: titleTextField!,
                                            discription: subTitleTextField!,
                                            latitude: coordinates.latitude,
                                            longitude: coordinates.longitude)
            self.putAnnaotaionToMap(locationinfo: locationInfo)
        }
        alert.addAction(actionCancle)
        alert.addAction(actionSave)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    //carating annotaion to map
    func putAnnaotaionToMap(locationinfo : LocationInfo){
        let annotation = MKPointAnnotation()
        annotation.title = locationinfo.title
        annotation.subtitle = locationinfo.discription
        print("iin anotation \(locationinfo.longitude) and \(locationinfo.latitude)")
        annotation.coordinate = CLLocationCoordinate2D(latitude: locationinfo.latitude,longitude: locationinfo.longitude)
        saveToCoreData(locationInfo: locationinfo)
        
        mapView.addAnnotation(annotation)
    }
    //saving to coredatabase
    func saveToCoreData(locationInfo : LocationInfo)  {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Locations", in: context)
        let newLocationInfo = NSManagedObject(entity: entity!, insertInto: context)
        
        newLocationInfo.setValue(locationInfo.title, forKey: "title")
        newLocationInfo.setValue(locationInfo.discription, forKey: "discription")
        newLocationInfo.setValue(locationInfo.longitude, forKey: "longitude")
        newLocationInfo.setValue(locationInfo.latitude, forKey: "latitude")
        
        
        do {
            try context.save()
            print("Data Saved")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
    func getDataFromCoreData(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Locations")
    
        do {
            let locations = try managedContext.fetch(fetchRequest)
            for eachLocation in locations{
                print("blog from persistance \(String(describing: eachLocation.value(forKey: "title")))")
                
                locationInfos.append(LocationInfo(title: eachLocation.value(forKey: "title") as! String,
                                        discription: eachLocation.value(forKey: "discription") as! String,
                                        latitude: eachLocation.value(forKey: "latitude") as! Double,
                                        longitude: eachLocation.value(forKey: "longitude") as! Double))
                
                //                blogsdata.insert(data(title: String(describing: eachBlog.value(forKey: "title")!),content: String(describing: eachBlog.value(forKey: "content")!))
                //                    , at: 0)
            }
            print(locationInfos)
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }
    
    
}



