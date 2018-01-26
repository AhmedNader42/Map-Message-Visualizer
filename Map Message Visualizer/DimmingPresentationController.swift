//
//  DimmingPresentationController.swift
//  Map Message Visualizer
//
//  Created by Admin on 8/5/17.
//  Copyright © 2017 ahmednader. All rights reserved.
//

import UIKit

class DimmingPresentationController: UIPresentationController {

    // Do not remove the map when presenting the DetailedViewController.
    override var shouldRemovePresentersView: Bool{
        return false
    }
}
