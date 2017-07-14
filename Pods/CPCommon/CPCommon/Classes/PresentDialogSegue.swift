//
//  PresentDialogSegue.swift
//  AntHire
//
//  Created by Andrew on 23/11/2016.
//  Copyright © 2016 ControlPointLLP. All rights reserved.
//

import Foundation
import UIKit

public final class PresentDialogSegue : UIStoryboardSegue {
    override public func perform() {
        
        source.addChildViewController( destination )
        source.view.addSubview( destination.view )
        source.view.bringSubview(toFront: destination.view )
        
        var frame = CGRect.init()
        
        frame.size.height = source.view.frame.size.height
        frame.size.width = source.view.frame.size.width
        frame.origin.x = source.view.bounds.origin.x
        frame.origin.y = source.view.bounds.origin.y
        
        destination.view.frame = frame
        
        let d = destination
        d.view.alpha = 0.0
        UIView.animate(withDuration: 0.2) {
            d.view.alpha = 1.0
        }
    }
}
