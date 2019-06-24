import UIKit

extension UITableView {
    func dequeue<Cell: UITableViewCell>(cellAt indexPath: IndexPath, for identifier: String) -> Cell {
        guard let cell = dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? Cell else {
            fatalError("Could not dequeue cell with identifier: \(identifier)")
        }
        return cell
    }
}

extension UITableView {
    func beginRefreshing() {
        guard let control = refreshControl else {
            return
        }

        control.beginRefreshing()
        
        let contentOffset = CGPoint(x: 0, y: -control.frame.height)
        setContentOffset(contentOffset, animated: true)
    }
    
    func endRefreshing() {
        refreshControl?.endRefreshing()
    }
}
