//
//  MasterViewController.swift
//  FlagAppUser
//
//  Created by Sourav Basu Roy on 23/12/17.
//  Copyright © 2017 Sourav Basu Roy. All rights reserved.
//

import UIKit
import SessionHandler

class MasterViewController: UIViewController {

    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var btnSideMenu: UIButton!
    @IBOutlet weak var lblTitleHeader: UILabel!
    
    var sideMenu:SideMenuViewController!
    private var leftDrawerTransition:DrawerTransition!
    var isdriver = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(recivedNotification(notification:)), name: NSNotification.Name(rawValue: "Reservation Details"), object: nil)
        
        initSideMenu()
        
        LoadPage()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func recivedNotification(notification:Notification)  {
        let object = notification.object as? String ?? ""
        if object.count > 0 {
            lblTitleHeader.text = object
        }
        
    }
    
    func initSideMenu() {
        sideMenu = mainStoryboard.instantiateViewController(withIdentifier: "SideMenuViewController") as! SideMenuViewController
        sideMenu.delegate = self
        sideMenu.isDriver = isdriver
        self.leftDrawerTransition = DrawerTransition(target: self, drawer: sideMenu)
        self.leftDrawerTransition.setPresentCompletion { print("left present...") }
        self.leftDrawerTransition.setDismissCompletion { print("left dismiss...") }
        self.leftDrawerTransition.edgeType = .left
    }
    
    @IBAction func SideMenuClick(_ sender: Any) {
        self.leftDrawerTransition.presentDrawerViewController(animated: true)
    }
    fileprivate func removeInactiveViewController(inactiveViewController: UIViewController?) {
        if let inActiveVC = inactiveViewController {
            // call before removing child view controller's view from hierarchy
            inActiveVC.willMove(toParentViewController: nil)
            
            inActiveVC.view.removeFromSuperview()
            
            // call after removing child view controller's view from hierarchy
            inActiveVC.removeFromParentViewController()
        }
    }
    
    fileprivate func updateActiveViewController(activeVC:UIViewController,contentView:UIView) {
        
        // call before adding child view controller's view as subview
        addChildViewController(activeVC)
        
        activeVC.view.frame = contentView.bounds
        contentView.addSubview(activeVC.view)
        
        // call before adding child view controller's view as subview
        activeVC.didMove(toParentViewController: self)
        
    }
    func LoadPage() {
        for viewcontroller in self.childViewControllers {
            removeInactiveViewController(inactiveViewController: viewcontroller)
        }
        
        if isdriver == false {
            let landingMenu = mainStoryboard.instantiateViewController(withIdentifier: "NewReservationViewController") as! NewReservationViewController
            updateActiveViewController(activeVC: landingMenu, contentView: viewContainer)
        }
        else{
            let landingMenu = mainStoryboard.instantiateViewController(withIdentifier: "LandingPageViewController") as! LandingPageViewController
            updateActiveViewController(activeVC: landingMenu, contentView: viewContainer)
        }
        
        
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

extension MasterViewController:SideMenuDelegate{
    func didSelectedMenuItem(item: String) {
        lblTitleHeader.text = item
        for viewcontroller in self.childViewControllers {
            removeInactiveViewController(inactiveViewController: viewcontroller)
        }
        
        if item == "Home Run" {
            let home = mainStoryboard.instantiateViewController(withIdentifier: "LandingPageViewController") as! LandingPageViewController
            updateActiveViewController(activeVC: home, contentView: viewContainer)
        }
        else if item == "My Reservation" {
            let reservation = mainStoryboard.instantiateViewController(withIdentifier: "ReservationListNavigation") as! UINavigationController
            let rootViewController = reservation.visibleViewController as! ReservationListViewController
            rootViewController.type = 1
            updateActiveViewController(activeVC: reservation, contentView: viewContainer)
        }
        else if item == "Reservation Bid" {
            let reservation = mainStoryboard.instantiateViewController(withIdentifier: "ReservationListNavigation") as! UINavigationController
            let rootViewController = reservation.visibleViewController as! ReservationListViewController
            rootViewController.type = 2
            updateActiveViewController(activeVC: reservation, contentView: viewContainer)
        }
        else if item == "Rate" {
            let rate = mainStoryboard.instantiateViewController(withIdentifier: "RateListViewController") as! RateListViewController
            updateActiveViewController(activeVC: rate, contentView: viewContainer)
        }
        else if item == "Referrals" {
            let reservation = mainStoryboard.instantiateViewController(withIdentifier: "ReservationListNavigation") as! UINavigationController
            let rootViewController = reservation.visibleViewController as! ReservationListViewController
            rootViewController.type = 3
            updateActiveViewController(activeVC: reservation, contentView: viewContainer)
        }
        else if item == "Account" {
            let account = mainStoryboard.instantiateViewController(withIdentifier:"DriverProfileViewController") as! DriverProfileViewController
            if isdriver == false {
                account.actype = 1
            }
            updateActiveViewController(activeVC: account, contentView: viewContainer)
        }
        else if item == "Logout" {
            let userData = NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.value(forKey: "userData") as? Data ?? Data()) as? Dictionary<String,Any> ?? Dictionary<String,Any>()
            if let userId = userData["user_id"] as? String {
                let session = SessionHandler()
                let dict = ["user_id":userId]
                let body = session.multipartData(keyValuePair: dict)
                session.view = view
                do{
                    try session.callWebserviceWithClosure(baseUrl: URL(string: logoutUrl)!, httpMethod: "POST", acceptType: "application/json", contentType: nil, httpBody: body, authentication: nil, completionHandler: { (error, response, nil) in
                        if error != nil {
                            self.view.makeToast(error)
                        }
                        else{
                            UserDefaults.standard.removeObject(forKey: "userData")
                            UserDefaults.standard.removeObject(forKey: "userType")
                            let loginPage = mainStoryboard.instantiateViewController(withIdentifier: "loginPage") as! ViewController
                            var viewControllers = self.navigationController?.viewControllers ?? [UIViewController]()
                            viewControllers.removeAll()
                            viewControllers.append(loginPage)
                            self.navigationController?.setViewControllers(viewControllers, animated: true)
                        }
                    })
                }
                catch {
                    print(error.localizedDescription)
                }
                
            }
        }
        else if item == "Monitor All Drivers" {
            let drivers = mainStoryboard.instantiateViewController(withIdentifier: "DriversViewController") as! DriversViewController
            updateActiveViewController(activeVC: drivers, contentView: viewContainer)
        }
        else if item == "Create New Reservation" {
            let reservation = mainStoryboard.instantiateViewController(withIdentifier: "NewReservationViewController") as! NewReservationViewController
            updateActiveViewController(activeVC: reservation, contentView: viewContainer)
        }
        else if item == "Edit Reservation" {
            let reservation = mainStoryboard.instantiateViewController(withIdentifier: "ReservationListNavigation") as! UINavigationController
            let rootViewController = reservation.visibleViewController as! ReservationListViewController
            rootViewController.type = 4
            updateActiveViewController(activeVC: reservation, contentView: viewContainer)
        }
        else if item == "Monitor All Reservations" {
            let reservation = mainStoryboard.instantiateViewController(withIdentifier: "ReservationListNavigation") as! UINavigationController
            let rootViewController = reservation.visibleViewController as! ReservationListViewController
            rootViewController.type = 5
            updateActiveViewController(activeVC: reservation, contentView: viewContainer)
        }
        else if item == "Assign Drivers" {
            let reservation = mainStoryboard.instantiateViewController(withIdentifier: "ReservationListNavigation") as! UINavigationController
            let rootViewController = reservation.visibleViewController as! ReservationListViewController
            rootViewController.type = 6
            updateActiveViewController(activeVC: reservation, contentView: viewContainer)
        }
        else if item == "Unassign Drivers" {
            let drivers = mainStoryboard.instantiateViewController(withIdentifier: "DriversViewController") as! DriversViewController
            updateActiveViewController(activeVC: drivers, contentView: viewContainer)
        }
        else if item == "Cancel Reservation" {
            let reservation = mainStoryboard.instantiateViewController(withIdentifier: "ReservationListNavigation") as! UINavigationController
            let rootViewController = reservation.visibleViewController as! ReservationListViewController
            rootViewController.type = 8
            updateActiveViewController(activeVC: reservation, contentView: viewContainer)
        }
        else if item == "Future Reservation" {
            let reservation = mainStoryboard.instantiateViewController(withIdentifier: "ReservationListNavigation") as! UINavigationController
            let rootViewController = reservation.visibleViewController as! ReservationListViewController
            rootViewController.type = 7
//            rootViewController.celltype = 1
            updateActiveViewController(activeVC: reservation, contentView: viewContainer)
        }
        else if item == "Past Reservation" {
            let reservation = mainStoryboard.instantiateViewController(withIdentifier: "ReservationListNavigation") as! UINavigationController
            let rootViewController = reservation.visibleViewController as! ReservationListViewController
            rootViewController.type = 6
            updateActiveViewController(activeVC: reservation, contentView: viewContainer)
        }
        else if item == "Set Pax Ready To Go" {
            let reservation = mainStoryboard.instantiateViewController(withIdentifier: "ReservationListNavigation") as! UINavigationController
            let rootViewController = reservation.visibleViewController as! ReservationListViewController
            rootViewController.type = 5
            updateActiveViewController(activeVC: reservation, contentView: viewContainer)
        }
        else if item == "Create Driver Account" {
            let registration = mainStoryboard.instantiateViewController(withIdentifier: "RegistrationViewController") as! RegistrationViewController
            registration.fromSideMenu = true
            updateActiveViewController(activeVC: registration, contentView: viewContainer)
            
        }
        else if item == "Earnings" {
            let earnings = mainStoryboard.instantiateViewController(withIdentifier: "EarningViewController") as! EarningViewController
            updateActiveViewController(activeVC: earnings, contentView: viewContainer)
        }
        else if item == "Fare" {
            let fare = mainStoryboard.instantiateViewController(withIdentifier: "RateViewController") as! RateViewController
            updateActiveViewController(activeVC: fare, contentView: viewContainer)
            
        }
        else if item == "Dispatch" {
            let dispatch = mainStoryboard.instantiateViewController(withIdentifier: "dispatch") as! UINavigationController
            updateActiveViewController(activeVC: dispatch, contentView: viewContainer)
            
        }

    }
}
