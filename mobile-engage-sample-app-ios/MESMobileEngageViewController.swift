//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

import UIKit
import MobileEngageSDK

class MESMobileEngageViewController: UIViewController, MobileEngageStatusDelegate {

    var pushToken: String?

//MARK: Outlets
    @IBOutlet weak var contactFieldIdTextField: UITextField!
    @IBOutlet weak var contactFieldValueTextField: UITextField!
    @IBOutlet weak var sidTextField: UITextField!
    @IBOutlet weak var customEventNameTextField: UITextField!
    @IBOutlet weak var customEventAttributesTextView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(forName: NotificationNames.pushTokenArrived.asNotificationName(), object: nil, queue: OperationQueue.main) { [unowned self] (notification: Notification) in
            if let data = notification.userInfo?["push_token"] as? Data {
                self.pushToken = String(data: data, encoding: String.Encoding.utf8)
            }
        }
    }

//MARK: ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        self.view.addGestureRecognizer(tapGestureRecognizer)
        MobileEngage.statusDelegate = self

        registerForKeyboardNotifications()
    }

//MARK: Actions
    @IBAction func anonymLoginButtonClicked(_ sender: Any) {
        MobileEngage.appLogin()
    }

    @IBAction func loginButtonClicked(_ sender: Any) {
        guard let idText = self.contactFieldIdTextField.text,
              let valueText = self.contactFieldValueTextField.text,
              let id = Int(idText) else {
            showAlert(with: "Wrong parameter")
            return
        }
        MobileEngage.appLogin(withContactFieldId: id as NSNumber, contactFieldValue: valueText)

        let inboxViewController = self.tabBarController?.viewControllers?[1] as! MESInboxViewController
        inboxViewController.refresh(refreshControl: nil)
    }

    @IBAction func trackMessageButtonClicked(_ sender: Any) {
        guard let sid = sidTextField.text else {
            showAlert(with: "Missing sid")
            return
        }
        MobileEngage.trackMessageOpen(userInfo: ["u": "{\"sid\":\"\(sid)\"}"])
    }

    @IBAction func trackCustomEventButtonClicked(_ sender: Any) {
        guard let eventName = self.customEventNameTextField.text, !eventName.isEmpty else {
            showAlert(with: "Missing eventName")
            return
        }
        var eventAttributes: [String: String]?
        if let attributes = self.customEventAttributesTextView.text {
            if let data = attributes.data(using: .utf8) {
                do {
                    eventAttributes = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String]
                } catch {
                    showAlert(with: "Invalid JSON")
                    print(error.localizedDescription)
                }
            }
        }
        MobileEngage.trackCustomEvent(eventName, eventAttributes: eventAttributes)
    }

    @IBAction func logoutButtonClicked(_ sender: Any) {
        MobileEngage.appLogout()
    }

    func backgroundTapped() {
        self.view.endEditing(true)
    }

    @IBAction func showPushTokenButtonClicked(_ sender: Any) {
        var message: String = ""
        if (self.pushToken != nil) {
            message = self.pushToken!
        } else {
            message = "No pushtoken"
        }

        showAlert(with: message)
        UIPasteboard.general.string = message
    }

//MARK: MobileEngageStatusDelegate
    func mobileEngageLogReceived(withEventId eventId: String, log: String) {
        showAlert(with: "EventId: \(eventId) \n Log: \(log)")
        print(eventId, log)
    }

    func mobileEngageErrorHappened(withEventId eventId: String, error: Error) {
        showAlert(with: "EventId: \(eventId) \n Error: \(error)")
        print(eventId, error)
    }

}
