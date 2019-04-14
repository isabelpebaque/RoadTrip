//
//  FirstViewController.swift
//  RoadTripAssistant
//
//  Created by Isabel Pebaqué on 2019-04-07.
//  Copyright © 2019 Isabel Pebaqué. All rights reserved.
//

import UIKit
import UserNotifications

class FirstViewController: UIViewController {

    @IBOutlet weak var restaurantSwitch: UISwitch!
    @IBOutlet weak var attractionSwitch: UISwitch!
    @IBOutlet weak var gasStationSwitch: UISwitch!
    
    @IBOutlet weak var radius2Km: UISwitch!
    @IBOutlet weak var radius3Km: UISwitch!
    @IBOutlet weak var radius4Km: UISwitch!
    
    
    var name = [String]()
    var radius: Double = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        name.removeAll()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        print("Button pressed")
        checkSearchName()
        addRadiusToSearch()
    }
    
    func checkSearchName() {
        
        if restaurantSwitch.isOn {
            name.append("Restaurant")
        } else if attractionSwitch.isOn {
            name.append("Landmarks")
        } else if gasStationSwitch.isOn {
            name.append("Gasstation")
        }
    }
    
    func addRadiusToSearch() {
        
        if radius2Km.isOn {
            radius = 2000
        } else if radius3Km.isOn {
            radius = 3000
        } else if radius4Km.isOn {
            radius = 4000
        } else {
            radius = 1000
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destination = segue.destination as! MapSearchViewController
        destination.searchName = name
        destination.searchRadius = radius
    }
 

}
