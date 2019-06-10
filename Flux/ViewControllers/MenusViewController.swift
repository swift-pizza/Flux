import UIKit

class MenusViewController: UITableViewController {
    private let service = PizzeriaService()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
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
                print(pizzeria.menus)
            }
        }
    }
}
