//
//  MapViewController.swift
//  friendFinder
//


import Foundation
import GoogleMaps
import UIKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate {
//    GMSMapViewDelegate  <-- need to implement
    
    //this is the userName to show up
    var userName: String?
    
    let socket = SocketIOClient(socketURL: "http://192.168.1.8:5000")
    let colors: [Int : String] = [0 : "red", 1 : "blue", 2 :"green", 3 : "purple", 4 : "yellow", 5 : "black"]
    var userColor:  String = ""
//    weak var delegate: SignInDetailsViewControllerDelegate?
    weak var cancelButtonDelegate: CancelButtonDelegate?
    let locationManager = CLLocationManager()
    var timer = 10
    var locationTimer: NSTimer!
        func countdown() {
        --timer
        print(timer)
            if timer == 0 {
                print("new coordinates time!")
                updateMapCall()
                timer = 10
            }
    }
    
    func updateMapCall() {
        print("settingup new ccord")
        let currentPosition: CLLocation = self.locationManager.location!
        let camera = GMSCameraPosition.cameraWithLatitude(currentPosition.coordinate.latitude,
            longitude: currentPosition.coordinate.longitude, zoom: 12)
        let mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        
        mapViewUpdate(mapView, idleAtCameraPosition: camera)
    }
    
    @IBAction func cancelBarButtonPressed(sender: UIBarButtonItem) {
        
        cancelButtonDelegate?.cancelButtonPressedFrom(self)
        print("cancel")
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        var clock = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("countdown"), userInfo: nil, repeats: true)

        let camera = GMSCameraPosition.cameraWithLatitude(37.335358,
            longitude: -121.89658, zoom: 10)

        let mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        mapView.mapType = kGMSTypeHybrid
        mapView.settings.myLocationButton = true
        mapView.myLocationEnabled = true
        mapView.settings.compassButton = true
        mapView.settings.scrollGestures = true
        mapView.settings.zoomGestures = true
        let currentPosition: CLLocation = self.locationManager.location!
        print(currentPosition.coordinate.latitude, currentPosition.coordinate.longitude, "are my current coordinates")
        
        //        mapView.delegate = self
        socket.connect()
        
        socket.on("connect") { data, ack in
            print("iOS::WE ARE USING SOCKETS!")
            print(data)
            let currentPosition: CLLocation = self.locationManager.location!
            print(currentPosition.coordinate.latitude, currentPosition.coordinate.longitude, "are my current coordinates")
            var coord = [String: AnyObject] ()
            coord["x"] = currentPosition.coordinate.latitude
            coord["y"] = currentPosition.coordinate.longitude
            coord["name"] = self.userName!
//            coord["distance"] = 0
            let random = Int(arc4random_uniform(5))
            
            coord["colorID"] = self.colors[random]! as String
            
            self.userColor = String(coord["colorID"]!)
            print((self.userColor), "is the user color")
            print(coord, "is being sent to the server")
            //this is the sent coordinates
        
            self.socket.emit("myLocation", coord  )
            self.countdown()
            print("tried to emit")
            
        }
        
        socket.on("newUserCoordinates") { data, ack in
            print("Got new coordinates")
             let marker = GMSMarker()
            mapView.clear()
            if String(data[0]["name"]) != self.userName! {
                print(data[0]["x"]!, data[0]["y"]!)
                if let lat = data[0]["x"] {
                    if let long = data[0]["y"] {
                        marker.position = CLLocationCoordinate2DMake(Double(lat! as! NSNumber), Double(long! as! NSNumber))
                    }
                }
                
                if let otherName = data[0]["name"] {
                    marker.title = otherName! as! String
                }
                
                
                if (data[0]["colorID"]?!)! as! String == "red" {
                             marker.icon = GMSMarker.markerImageWithColor(UIColor.redColor())
                    }
                     if (data[0]["colorID"]?!)! as! String == "blue" {
                        marker.icon = GMSMarker.markerImageWithColor(UIColor.blueColor())
                    }
                     if  (data[0]["colorID"]?!)! as! String  == "green"  {
                        marker.icon = GMSMarker.markerImageWithColor(UIColor.greenColor())
                    }
                     if (data[0]["colorID"]?!)! as! String  == "purple"  {
                        marker.icon = GMSMarker.markerImageWithColor(UIColor.purpleColor())
                    }
                     if (data[0]["colorID"]?!)! as! String  == "yellow"  {
                        marker.icon = GMSMarker.markerImageWithColor(UIColor.yellowColor())
                    }
//                marker.snippet = String(data[0]["distance"])
                
                marker.map = mapView
            }
            
        } 

        if let mylocation = mapView.myLocation {
            print("User's location is \(mylocation)")
            let locationManager = CLLocationManager()
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            
            func getLocation(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
                let currentPosition: CLLocation = self.locationManager.location!
                var userCoordinates = "\(String(currentPosition.coordinate.latitude)) \(String(currentPosition.coordinate.longitude))"
                var userLocation:CLLocation = locations[0] as! CLLocation
                let long = userLocation.coordinate.longitude;
                let lat = userLocation.coordinate.latitude;
                //Do What ever you want with it, aka SOCKETSSSS MANG
                
                print("tried to emit after successful get location")

            }
            
        } else {
            print("User's location is unknown")
//             let currentPosition: CLLocation = self.locationManager.location!

        }
        
        self.view = mapView
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(19.4333 , 99.1333)
        marker.title = userName!
        marker.snippet = "Mexico"
        marker.map = mapView
        print(userName!, "Is the user!")
    }
    
    //end of viewDidLoad
    
    //for updating the marker
    
    func mapViewUpdate(mapView: GMSMapView!, idleAtCameraPosition cameraPosition: GMSCameraPosition!) {
        print(self.userColor, "TRYING TO SEND WITH THIS COLR")
            var coord = [String: AnyObject] ()
            let currentPosition: CLLocation = self.locationManager.location!
//            let handler = { (response : GMSReverseGeocodeResponse!, error: NSError!) -> Void in
//                if let result = response.firstResult() {
                    let marker = GMSMarker()
                    
                    coord["x"] = currentPosition.coordinate.latitude
                    coord["y"] = currentPosition.coordinate.longitude
                    marker.position = cameraPosition.target
                    marker.title = self.userName
                    coord["name"] = self.userName
                    coord["colorID"] = self.userColor
        
                    marker.map = mapView!
                    
                    self.socket.emit("myLocation", coord)
                    print("tried to send my new coordinates ", coord)
                }
//            }
//
//        }
    
    
        //        geocoder?.reverseGeocodeCoordinate(cameraPosition.target, completionHandler: handler)
//        else {
//            return
//        }
    
//    let newSpot = mapView(mapView, cameraPosition: GMSCameraPosition!)
    

    func mapView(mapView: GMSMapView!, willMove gesture: Bool) {
        mapView.clear()
    }
    
    

    
}


