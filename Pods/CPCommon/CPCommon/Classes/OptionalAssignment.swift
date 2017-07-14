//
//  OptionalAssignment.swift
//  CPCommon
//
//  Created by Andrew on 22/06/2017.
//  Copyright © 2017 ControlPointLLP. All rights reserved.
//

import Foundation


/**
 These operators will only assign or evaluate methods if one of the operands is not optional
*/

// assign only if right is not nil http://stackoverflow.com/a/41120784/1742518
precedencegroup OptionalAssignment {
    associativity: right
}


infix operator ?=: AssignmentPrecedence

// Optional assignment: only assign if left is nil
public func ?=<T>(left: inout T?, right: T) {
    if left == nil {
        left = right
    }
}

// Optional assignment: only evaluate function and assign if left is nil
public func ?=<T>(left: inout T?, right: () -> T?) {
    if left == nil {
        left = right()
    }
}


// Optional assignment: only assign if right is not nil
infix operator =?: AssignmentPrecedence

public func =?<T>(left: inout T, right: T?) {
    if right != nil {
        left = right!
    }
}
