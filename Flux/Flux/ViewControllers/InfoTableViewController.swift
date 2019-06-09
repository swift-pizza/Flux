import UIKit

class InfoTableViewController: UITableViewController {
    private let service = PizzeriaService()
    private var sections: [InfoSection] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        loadInfo()
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
        cell.imageView?.image = UIImage(named: sections[indexPath.section].info[indexPath.row].icon)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

private extension InfoTableViewController {
    func setupUI() {
        navigationItem.title = Constants.ScreenTitles.info
    }
    
    func loadInfo() {
        service.execute(.info) { [unowned self] (result: Result<About, ServiceError>) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let me):
                self.sections = me.sections
                self.tableView.reloadData()
            }
        }
    }
}
