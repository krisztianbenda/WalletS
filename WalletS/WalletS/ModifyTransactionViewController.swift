//
//  CreateTransactionViewController.swift
//  WalletS
//
//  Created by Benda Krisztián on 2017. 11. 28..
//  Copyright © 2017. krisztianbenda. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ModifyTransactionViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var expenseTextField: UITextField!
    @IBOutlet weak var incomeTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationButton: UIButton!
    
    let locationManager = CLLocationManager()
    
    var transaction: Transaction!
    var wallet: Wallet!
    var transactionLocation: CLLocationCoordinate2D?
    static var enableLocationFinding = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
        
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        if (transaction.longitude != 0.0 && transaction.latitude != 0.0){
            mapView.setCenter(CLLocationCoordinate2DMake(transaction.latitude, transaction.longitude), animated: true)
        }else {
            if let coordinates = mapView.userLocation.location?.coordinate{
                mapView.setCenter(coordinates, animated: true)
            }
        }
        
        addLongPressGesture()
        
        nameTextField.text = transaction.name
        if transaction.income == 0 {
            incomeTextField.text = ""
        } else {
            incomeTextField.text = String(transaction.income)
        }
        if transaction.expense == 0 {
            expenseTextField.text = ""
        } else {
            expenseTextField.text = String(transaction.expense)
        }
        descriptionTextView.text = transaction.transDescription
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if (transaction.longitude == 0.0 && transaction.latitude == 0.0){
            mapView.showsUserLocation = true
        } else {
            let annot = MKPointAnnotation()
            annot.coordinate = CLLocationCoordinate2DMake(transaction.latitude, transaction.longitude)
            self.mapView.addAnnotation(annot)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        mapView.showsUserLocation = false
    }
    
    @IBAction func onBackgroundTouchUpInside(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func modifyTransactionButtonTap(_ sender: Any) {
        modifyTransaction()

    }
    
    func addLongPressGesture(){
        let longPressRecognizer:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ModifyTransactionViewController.handleLongPress(_:)))
        longPressRecognizer.minimumPressDuration = 0.2
        self.mapView.addGestureRecognizer(longPressRecognizer)
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UIGestureRecognizer){
        if gestureRecognizer.state != .began {
            return
        }
        
        let touchPoint: CGPoint = gestureRecognizer.location(in: self.mapView)
        let touchMapCoordinate: CLLocationCoordinate2D = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
        let annot:MKPointAnnotation = MKPointAnnotation()
        annot.coordinate = touchMapCoordinate
        
        self.resetTracking()
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotation(annot)
        self.centerMap(touchMapCoordinate)
    }
    
    func resetTracking(){
        if (mapView.showsUserLocation){
            mapView.showsUserLocation = false
            self.mapView.removeAnnotations(mapView.annotations)
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    func centerMap(_ center: CLLocationCoordinate2D){
        self.saveCurrentLocation(center)
        let spanX = 0.01
        let spanY = 0.01

        let newRegion = MKCoordinateRegion(center: center, span: MKCoordinateSpanMake(spanX, spanY))
        mapView.setRegion(newRegion, animated:  true)
    }
    
    func saveCurrentLocation(_ center: CLLocationCoordinate2D){
        transactionLocation = center
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        centerMap(locValue)
    }
    
    

    @IBAction func getMyLocation(_ sender: UIButton) {
        if CLLocationManager.locationServicesEnabled() {
            if ModifyTransactionViewController.enableLocationFinding {
                locationManager.startUpdatingLocation()
                locationButton.setTitle("Disable my location", for: .normal)
            }else{
                locationManager.stopUpdatingLocation()
                locationButton.setTitle("Find my location", for: .normal)
            }
            ModifyTransactionViewController.enableLocationFinding = !ModifyTransactionViewController.enableLocationFinding
        }
    }
    
    func modifyTransaction(){
        var newName = "EmptyTransaction"
        var newIncome = 0.0
        var newExpense = 0.0
        var newDescription = ""
        var newLatitude = 0.0
        var newLongitude = 0.0
        
        if nameTextField.text != "" {
            newName = nameTextField.text!
        }
        if incomeTextField.text != "" {
            newIncome = Double(incomeTextField.text!)!
        }
        if expenseTextField.text != "" {
            newExpense = Double(expenseTextField.text!)!
        }
        if descriptionTextView.text != "" {
            newDescription = descriptionTextView.text!
        }
        newLatitude = ((mapView.annotations.first)?.coordinate.latitude)!
        newLongitude = ((mapView.annotations.first)?.coordinate.longitude)!
        DataManager.instance.modifyTransaction(which: transaction, toWallet: wallet, toName: newName, toIncome: newIncome, toExpense: newExpense, toDescription: newDescription, toLatitude: newLatitude, toLongitude: newLongitude)
    }
    

}

