//
//  HelpViewController.swift
//  MyShopping
//
//  Created by Sami Rämö on 28/06/2017.
//  Copyright © 2017 Sami Ramo. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var exitButton: UIButton!
    
    var imageName: String?
    
    var pageIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = UIImage(named: imageName!)
        exitButton.backgroundColor = UIColor.white
        exitButton.layer.cornerRadius = 23.0
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func exit(_ sender: UIButton) {
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
