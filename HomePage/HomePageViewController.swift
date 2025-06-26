//
//  HomePageViewController.swift
//  FIT3178-Project
//
//  Created by Yi Goh on 24/4/2024.
//

import UIKit
//listen to onPlanChange and onPlanRecipeChange
//onPlanChange: check if the current plan is the nearest plan
//onPlanRecipeChange: configure the page again (no matter it has update or not)
class HomePageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        backgroundView.image = UIImage(imageLiteralResourceName: "pancake.jpg")
        
        reminderTable.delegate = self
        reminderTable.dataSource = self
        view.addSubview(reminderTable)
        reloadReminderTable()
        
        /// setup the homepage and initialise timer for keep track of the next recipe shown
        /// add Observer for UserDefault change (in this case reminder for each notification)
        startTimer()
        setup()
        UserDefaultObserver.shared.addObserver(self, selector: #selector(userDefaultsDidChange))
        
    }
    
    @IBOutlet weak var backgroundView: UIImageView!
    
    @IBAction func viewPlanButtonTapped(_ sender: Any) {
    }
    
    @IBOutlet weak var fixedNextMealLabel: UILabel!
    @IBOutlet weak var currentMealView: UIImageView!
    @IBOutlet weak var viewPlanButton: UIButton!
    @IBOutlet weak var currentMealNameLabel: UILabel!
    @IBOutlet weak var reminderTable: UITableView!
    var reminders: [(String,[String])] = []
    let identifier = "reminderCell"
    weak var databaseController: DatabaseProtocol?
    var listenerType: ListenerType = ListenerType.plan
    var nextPlan: Plan?
    var allPlans: [Plan] = []
    var timer: Timer?
    
    override func viewDidLayoutSubviews() {
        backgroundView.layer.cornerRadius = backgroundView.layer.bounds.width/2
        backgroundView.clipsToBounds = true
        currentMealView.layer.cornerRadius = currentMealView.layer.bounds.width/2
        currentMealView.clipsToBounds = true
        currentMealView.layer.borderColor = UIColor.white.cgColor
        currentMealView.layer.borderWidth = 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        /// listener will not be dismissed as it may introduce bug that the reminder is not synchronous to current plan
        /// if we make several changes to plan without come back to home screen
    }
    
    @objc func userDefaultsDidChange(){
        reloadReminderTable()
    }

}

extension HomePageViewController: UITableViewDataSource{
    /// There shoule be at least 1 row
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(reminders.count,1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        if reminders.count == 0{
            cell.textLabel?.text = "There's no upcoming plan reminder"
            cell.textLabel?.textColor = UIColor(displayP3Red: 0.8, green: 0.0, blue: 0.0, alpha: 1.0)
            cell.detailTextLabel?.text = "Set your plan now !"
            cell.textLabel?.sizeToFit()
            return cell
        }
        cell.textLabel?.text = reminders[indexPath.row].1[0]
        cell.textLabel?.textColor = UIColor.black
        cell.detailTextLabel?.text = reminders[indexPath.row].1[1]
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return "Reminder"
        }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
}

extension HomePageViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

extension HomePageViewController: DatabaseListener{
    func onIngredientChange(change: DatabaseChange, ingredients: [Ingredient]) {
        //nothing
    }
    
    func onRecipeIngredientChange(change: DatabaseChange, recipeIngredients: [Ingredient]) {
        //nothing
    }
    
    func onRecipeChange(change: DatabaseChange, recipes: [Recipe]) {
        //nothing
    }
    
    func onPlanRecipeChange(change: DatabaseChange, planRecipes: [Recipe], plan:Plan?) {
        /// the change is handled during the change made
    }
    
    func onPlanChange(change: DatabaseChange, plan: [Plan]) {
        allPlans = plan
        findNextPlan()
        setup()
        reloadReminderTable()

    }
    
    func onCollectionChange(change: DatabaseChange, collections: [Recipe]) {
        //nothing
    }
    
    
}

extension HomePageViewController{
    
    /// show the next latest planned meal 
    func setup(){
        if let shownPlan = nextPlan{
            guard let shownRecipe = shownPlan.recipeMember else {return}
            Task{
                await requestImages(model: shownRecipe)
            }
            currentMealNameLabel.text = shownRecipe.name
        } else {
            currentMealView.image = UIImage(systemName: "questionmark")
            currentMealNameLabel.text = "No Plans Ahead"
        }
    }
    
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(checkDate), userInfo: nil, repeats: true)
    }
    
    /// if the next meal shown is already due, update and switch to the nextPlan
    @objc func checkDate(){
        guard let plan = nextPlan, let date = plan.date else {return}
        if compareDate(Date(), largerOrEqualTo: date){
            findNextPlan()
            setup()
        }
    }
    
    /**
    - Description: The behaviour of this function is that it will choose the last item if multiple plan is in the same time
    */
    func findNextPlan(){
        let currentDate = Date()
        var nearestDate = Date.distantFuture
        var planIndex = 0
        let comingPlan = allPlans.filter {
            guard let eatingTime = $0.eatingTime else {return false}
            return compareDate(eatingTime, largerOrEqualTo: currentDate)}
        
        if comingPlan.count == 0{
            nextPlan = nil
            return
        }
        
        
        for (index,plan) in comingPlan.enumerated(){
            guard let time = plan.eatingTime else {return}
            if compareDate(nearestDate, largerOrEqualTo: time){
                nearestDate = time
                planIndex = index
            }
        }
        nextPlan = comingPlan[planIndex]
    }
    
    func requestImages(model: Recipe) async{
            var searchURLComponents = URLComponents()
            var imageLink = model.imageURL
            guard let url = URL(string: imageLink!) else{
                print("Invalid URL")
                currentMealView.image = UIImage(systemName: "fork.knife")
                return
            }
            guard var urlComponenets = URLComponents(url: url, resolvingAgainstBaseURL: true) else{
                print("Failed to create URL Components")
                return
            }
            
            urlComponenets.scheme = "https"
            guard let requestImageURL = urlComponenets.url else {
                return
            }
            let imageRequest = URLRequest(url: requestImageURL)
            
            do{
                let (data, response) = try await URLSession.shared.data(for: imageRequest)
                guard let image=UIImage(data: data) else{
                    print("Invalid image")
                    return
                }
                currentMealView.image = image
            } catch let error{
                    print(error)
            }
            
            
            
        }
    
//    func reloadReminderTable(){
//        DispatchQueue.main.async{
//            [self] in
//            reminders.removeAll()
//            for invPlan in allPlans{
//                var identifier = invPlan.id.uuidString
//                var msg = UserDefaults.standard.array(forKey: identifier) as? [String]
//                if let msg = msg{
//                    reminders.append((identifier,msg))
//                } else {continue}
//            }
//            reminderTable.reloadData()
//        }
//    }
    
    func reloadReminderTable(){
                    reminders.removeAll()
                    for invPlan in allPlans{
                        var identifier = invPlan.id.uuidString
                        var msg = UserDefaults.standard.array(forKey: identifier) as? [String]
                        if let msg = msg{
                            reminders.append((identifier,msg))
                        } else {continue}
                    }
                    reminderTable.reloadData()
    }
}


