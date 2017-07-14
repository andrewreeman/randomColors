//
//  Helpers.swift
//  CPCommon
//
//  Created by Andrew on 24/06/2017.
//  Copyright © 2017 ControlPointLLP. All rights reserved.
//

import Foundation

public enum CPCommonImage {
    case qr
    case calendar
    case back
    
    func toResourceName() -> String {
        switch self {
        case .qr:
            return "qr_code"
        case .calendar:
            return "calendar"
        case .back:
            return "back"
            
        }
    }
}

/**
 This empty class is used for easy access of the CPCommon resource bundle 
*/
public class CommonBundle {
    public static func CPCommonBundle() -> Bundle {
        return Bundle.init(for: CommonBundle.self)
    }

    public static func image(_ img: CPCommonImage) -> UIImage {
        return UIImage.init(named: img.toResourceName(), in: CPCommonBundle(), compatibleWith: nil)!
    }    
}
