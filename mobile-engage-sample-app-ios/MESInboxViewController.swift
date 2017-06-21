//
//  Copyright © 2017. Emarsys. All rights reserved.
//

import Foundation
import UIKit

class MESInboxViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //MARK: Outlets
    @IBOutlet weak var notificationTableView: UITableView!

    //MARK: Variables
    var notifications: [MENotification] = []

    //MARK: ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString.init(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh(refreshControl:)), for: .valueChanged)

        self.notificationTableView.addSubview(refreshControl)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        MobileEngage.inbox.resetBadgeCount(successBlock: {
            self.tabBarItem.badgeValue = nil
        }) { error in
            print(error as Any)
        }
    }

    //MARK: Public methods
    public func refresh(refreshControl: UIRefreshControl?) {
        MobileEngage.inbox.fetchNotifications(resultBlock: { [unowned self] notificationInboxStatus in
            guard let inboxStatus = notificationInboxStatus else { return }
            self.notifications = inboxStatus.notifications
            self.notificationTableView?.reloadData()

            self.tabBarItem.badgeValue = inboxStatus.badgeCount != 0 ? "\(inboxStatus.badgeCount)" : nil
            refreshControl?.endRefreshing()
        }) { [unowned self] error in
            print(error as Any)
            let alert = UIAlertController(title: "Error", message: "Please login before fetching inbox", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { action in
                refreshControl?.endRefreshing()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }

    //MARK: UITableViewDataSource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as UITableViewCell
        
        cell.textLabel?.text = notifications[indexPath.row].title
        cell.detailTextLabel?.text = "Received at \(notifications[indexPath.row].receivedAt!)"
        
        return cell
    }

}
