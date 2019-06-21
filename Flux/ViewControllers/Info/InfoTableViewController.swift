import UIKit
import SafariServices
import WordPressFlux

class InfoTableViewController: UITableViewController {
    private let service = PizzeriaService(Constants.environment)

    private var receipt: Receipt!
    private var viewModel: InfoViewModel<PizzeriaService>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setViewModel()
    }
}

extension InfoTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections[section].info.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.sections[section].title
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.Cells.height
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeue(cellAt: indexPath, for: Constants.Cells.Identifiers.info)
        cell.textLabel?.text = viewModel.sections[indexPath.section].info[indexPath.row].title
        cell.detailTextLabel?.text = viewModel.sections[indexPath.section].info[indexPath.row].url
        cell.imageView?.tintColor = .customColor(.darkYellow)
        cell.imageView?.image = UIImage(named: viewModel.sections[indexPath.section].info[indexPath.row].icon)?.withRenderingMode(.alwaysTemplate)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let urlString = viewModel.sections[indexPath.section].info[indexPath.row].url
        open(urlString)
    }
}

private extension InfoTableViewController {
    func setupUI() {
        navigationItem.title = Constants.ScreenTitles.info

        let control = UIRefreshControl()
        refreshControl = control
        refreshControl?.addTarget(self, action: #selector(refreshControlDidStart(sender:)), for: .valueChanged)
        refreshControl?.beginRefreshing()

        let contentOffset = CGPoint(x: 0, y: -control.frame.height)
        tableView.setContentOffset(contentOffset, animated: true)
    }
    
    @objc func refreshControlDidStart(sender: UIRefreshControl?) {
        viewModel.fetchInfo()
    }
    
    func setViewModel() {
        viewModel = InfoViewModel(service: service)
        receipt = viewModel.onChange { [unowned self] in
            self.updateView()
        }
        viewModel.fetchInfo()
    }
    
    func updateView() {
        DispatchQueue.main.async {
            switch self.viewModel.state {
            case .loading, .stationary:
                self.refreshControl?.beginRefreshing()
            case .completed:
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }

    func open(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        let safari = SFSafariViewController(url: url)
        present(safari, animated: true, completion: nil)
    }
}
