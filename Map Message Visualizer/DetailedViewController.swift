//
//  DetailedViewController.swift
//  Map Message Visualizer
//
//  Created by Admin on 8/4/17.
//  Copyright © 2017 ahmednader. All rights reserved.
//

import UIKit

class DetailedViewController: UIViewController {

    @IBOutlet weak var sentimentImage : UIImageView!
    @IBOutlet weak var messageTextView    : UITextView!
    
    var message   = ""
    var sentiment = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch sentiment {
        case "Positive":
            sentimentImage.image = #imageLiteral(resourceName: "Positive.png")
        case "Negative":
            sentimentImage.image = #imageLiteral(resourceName: "Negative.png")
        case "Neutral":
            sentimentImage.image = #imageLiteral(resourceName: "Neutral.png")
        default:
            // Add a placeholder image.
            break
        }
        messageTextView.text = message
    }

}
