//
//  SettingsViewController.swift
//  MyShopping
//
//  Created by Sami Rämö on 01/06/2017.
//  Copyright © 2017 Sami Ramo. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    private let userDefaults = UserDefaults.standard
    
    @IBOutlet weak var pickedItemSettingSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickedItemSettingSwitch.setOn(userDefaults.bool(forKey: SettingKeys.pickedItemsToBottomSetting), animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pickedItemsSettingChanged(_ sender: UISwitch) {
        userDefaults.set(sender.isOn, forKey: SettingKeys.pickedItemsToBottomSetting)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
