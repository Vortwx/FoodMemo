//
//  CurrentPlannerViewController.swift
//  FIT3178-Project
//
//  Created by Yi Goh on 24/4/2024.
//

import UIKit

class CurrentPlannerViewController: UIViewController{

    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        childView?.update(withDate: sender.date)
    }
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var currentPlanner: UIView!
    weak var databaseController: DatabaseProtocol?
    var currentDayPlans: [Plan] = []
    var allPlans: [Plan] = []
    /// Child view that will be updated, embedded inside container view
    var childView: NonAdjustablePlannerCollectionViewController?{
        return children.first {$0 is NonAdjustablePlannerCollectionViewController} as? NonAdjustablePlannerCollectionViewController
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        childView?.update(withDate: datePicker.date)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.backButtonTitle = "Back"
    }

}
