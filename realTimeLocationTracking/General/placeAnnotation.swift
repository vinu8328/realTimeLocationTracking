//
//  placeAnnotation.swift
//  realTimeLocationTracking
//
//  Created by Vinayak Tudayekar on 11/08/19.
//  Copyright © 2019 Vinayak Tudayekar. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class PlaceAnnotation: NSObject,MKAnnotation
{
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var identifier = "Pin"
    var historyText = ""
    var placePhoto:UIImage! = nil
    var deliveryRadius:CLLocationDistance! = nil
    init(coordinate:CLLocationCoordinate2D,title:String?,subtitle:String?){
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}
