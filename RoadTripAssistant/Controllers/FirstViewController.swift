//
//  FirstViewController.swift
//  RoadTripAssistant
//
//  Created by Isabel Pebaqué on 2019-04-07.
//  Copyright © 2019 Isabel Pebaqué. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    @IBOutlet weak var restaurantSwitch: UISwitch!
    @IBOutlet weak var attractionSwitch: UISwitch!
    @IBOutlet weak var gasStationSwitch: UISwitch!
    
    var name: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        print("Button pressed")
        checkSearchName()
    }
    
    func checkSearchName() {
        
        if restaurantSwitch.isOn {
            name = "Restaurant"
        } else if attractionSwitch.isOn {
            name = "Tourist attraction"
        } else if gasStationSwitch.isOn {
            name = "Petrol station"
        }
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destination = segue.destination as! MapSearchViewController
        destination.searchName = name
    }
 

}
