import UIKit
import WordPressFlux

class MenusViewController: UITableViewController {
    private let service = PizzeriaService(.local)
    
    private var receipt: Receipt!
    private var viewModel: MenusViewModel<PizzeriaService>!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setViewModel()
    }
}

private extension MenusViewController {
    func setupUI() {
        navigationItem.title = Constants.ScreenTitles.project
    }

    func setViewModel() {
        viewModel = MenusViewModel(service: service)
        receipt = viewModel.onChange { [unowned self] in
            self.updateView()
        }
        viewModel.fetchMenus()
    }
    
    func updateView() {
        DispatchQueue.main.async {
            switch self.viewModel.state {
            case .loading, .stationary:
                self.tableView.beginRefreshing()
            case .completed:
                self.tableView.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }
}

extension MenusViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.menus.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.menus[section].type.rawValue.capitalized
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.Cells.height
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeue(cellAt: indexPath, for: Constants.Cells.Identifiers.menu)
        cell.textLabel?.text = viewModel.menus[indexPath.section].title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)

        tableView.deselectRow(at: indexPath, animated: true)
    }
}