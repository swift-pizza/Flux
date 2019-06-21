import UIKit

class MenusViewController: UITableViewController {
    private let service = PizzeriaService(.local)
    private var menus: [Menu] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        loadMenus()
    }
}

private extension MenusViewController {
    func setupUI() {
        navigationItem.title = Constants.ScreenTitles.project
    }

    func loadMenus() {
        service.execute(.menus) { (result: Result<Pizzeria, ServiceError>) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let pizzeria):
                self.menus = pizzeria.menus
            }
        }
    }
}

extension MenusViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return menus.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return menus[section].type.rawValue.capitalized
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.Cells.height
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeue(cellAt: indexPath, for: Constants.Cells.Identifiers.menu)
        cell.textLabel?.text = menus[indexPath.section].title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}
