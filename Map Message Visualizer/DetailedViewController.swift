//
//  DetailedViewController.swift
//  Map Message Visualizer
//
//  Created by Admin on 8/4/17.
//  Copyright © 2017 ahmednader. All rights reserved.
//

import UIKit

class DetailedViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var sentimentImage : UIImageView!
    @IBOutlet weak var messageTextView    : UITextView!
    @IBOutlet weak var popUpView: UIView!
    
    
    // MARK: Variables
    var userReview = UserReview()
    
    
    // MARK: VCLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make the popup window have round corners.
        popUpView.layer.cornerRadius = 20
        
        messageTextView.layer.cornerRadius = 25
        // Detect touches outside the view and dismiss the popup.
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
        
        
    }
    override func loadView() {
        super.loadView()
        // Load the data on startup.
        updateUI()
        
    }
    
    // MARK: Init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    // MARK: Configure method
    func updateUI(){
        // Change the image according to the sentiment of the review.
        switch userReview.sentiment.replacingOccurrences(of: " ", with: "") {
        case "Positive":
            sentimentImage.image = #imageLiteral(resourceName: "Positive.png")
            popUpView.backgroundColor = .green
        case "Negative":
            sentimentImage.image = #imageLiteral(resourceName: "Negative.png")
            popUpView.backgroundColor = .red
        case "Neutral":
            sentimentImage.image = #imageLiteral(resourceName: "Neutral.png")
            popUpView.backgroundColor = .yellow
        default:
            // Add a placeholder image.
            break
        }
        // Display the review.
        messageTextView.text = userReview.message
    }

    
    
    // MARK: Dismiss
    func close (){
        dismiss(animated: true, completion: nil)
    }
}



// MARK: Transitions delegate
extension DetailedViewController : UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return DimmingPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

// MARK: Gesture recognizer
extension DetailedViewController : UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Detect if the touch is in the view or outside of it.
        return (touch.view === self.view)
    }
}





