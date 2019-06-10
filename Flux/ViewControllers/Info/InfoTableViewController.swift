import UIKit
import SafariServices
import WordPressFlux

class InfoTableViewController: UITableViewController {
    private var receipt: Receipt!
    private let viewModel = InfoViewModel()
    private var sections: [InfoSection] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setViewModel()
    }
}

extension InfoTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].info.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.Cells.height
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeue(cellAt: indexPath, for: Constants.Cells.Identifiers.info)
        cell.textLabel?.text = sections[indexPath.section].info[indexPath.row].title
        cell.detailTextLabel?.text = sections[indexPath.section].info[indexPath.row].url
        cell.imageView?.tintColor = .customColor(.darkYellow)
        cell.imageView?.image = UIImage(named: sections[indexPath.section].info[indexPath.row].icon)?.withRenderingMode(.alwaysTemplate)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let urlString = sections[indexPath.section].info[indexPath.row].url
        open(urlString)
    }
}

private extension InfoTableViewController {
    func setupUI() {
        navigationItem.title = Constants.ScreenTitles.info
    }
    
    func setViewModel() {
        receipt = viewModel.onChange { [unowned self] in
            switch self.viewModel.state {
            case .loading, .stationary:
                // loading
                break
            case .completed(let success, let sections):
                if success {
                    self.sections = sections
                }
                break
            }
        }
        viewModel.start()
    }

    func open(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        let safari = SFSafariViewController(url: url)
        present(safari, animated: true, completion: nil)
    }
}
