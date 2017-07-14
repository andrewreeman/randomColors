//
//  Weak.swift
//  CPCommon
//
//  Created by Andrew on 25/10/2016.
//  Copyright © 2016 ControlPointLLP. All rights reserved.
//

import Foundation

// for using in collections
public class Weak<T: AnyObject> {
    public weak var value : T?
    public init(value: T) {
        self.value = value
    }
}
