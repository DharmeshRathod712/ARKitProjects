//
//  DataSet.swift
//  ARImageTrackingWithText
//
//  Created by Rathod on 7/18/20.
//  Copyright © 2020 Rathod. All rights reserved.
//

import UIKit

struct DataSet: Decodable {
    let name : String
    let education : String
    let yearPassout : Int
    let profession : String
    let country : String
}
