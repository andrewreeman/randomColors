//
//  ViewController.swift
//  SourceControlStuff
//
//  Created by Andrew on 14/07/2017.
//  Copyright © 2017 ControlPoint. All rights reserved.
//

import UIKit
import CPCommon

extension Array {
            
    // Mixes up the elements in an array
    public func shuffle() -> [Element] {
        var shuffledArray = [Element]()
        
        var originalColors = self
        
        originalColors.count.times {
            let i = self.index(originalColors.startIndex, offsetBy: originalColors.count.random())
            let item = originalColors.remove(at: i)
            shuffledArray.append( item )
        }
        
        return shuffledArray
    }
}


class ViewController: UIViewController {

    @IBOutlet var stackView: UIStackView!
    
    @IBOutlet var view1: UIView!
    
    @IBOutlet var view2: UIView!
    @IBOutlet var view3: UIView!
    @IBOutlet var view4: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()                        
        
   
        
        
       
        
        
    }

    @IBAction func shuffleColorsTapped() {
        let colors = [
            UIColor.blue,
            UIColor.orange,
            UIColor.green,
            UIColor.red,
            UIColor.purple,
            UIColor.yellow]
        print("shuufling colours...")
        let colorshuffle =  colors.shuffle()
        
        view1.backgroundColor = colorshuffle[0]
        
        
        view2.backgroundColor = colorshuffle[1]
        
        
        
        
        view3.backgroundColor = colorshuffle[2]
        
        
        
        view4.backgroundColor = colorshuffle[3]
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

