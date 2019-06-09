import UIKit

class MenusViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let service = PizzeriaService()
        service.execute(.menus) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let pizzeria):
                print(pizzeria.menus)
            }
        }
    }
}
