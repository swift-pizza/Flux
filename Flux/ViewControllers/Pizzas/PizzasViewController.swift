import UIKit
import WordPressFlux

class PizzasViewController: UITableViewController {
    var store: PizzeriaStore<PizzeriaService>!
    var menu: Menu!
    
    private var receipt: Receipt!
    private var viewModel: PizzasViewModel<PizzeriaService>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setViewModel()
    }
}

private extension PizzasViewController {
    func setupUI(){
        navigationItem.title = menu.title
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Constants.Cells.height
        
        let control = UIRefreshControl()
        refreshControl = control
        refreshControl?.addTarget(self, action: #selector(reloadPizzas(sender:)), for: .valueChanged)
        tableView.beginRefreshing()
    }
    
    func setViewModel() {
        viewModel = PizzasViewModel(store: store, menuType: menu.type)
        receipt = viewModel.onChange { [unowned self] in
            self.updateView()
        }
        viewModel.fetchPizzas(for: menu.type)
    }
    
    @objc func reloadPizzas(sender: UIRefreshControl?) {
        viewModel.reloadPizzas(for: menu.type)
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

extension PizzasViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getPizzas(for: menu.type).count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let pizza = viewModel.getPizzas(for: menu.type)[indexPath.row]
        let cell: UITableViewCell = tableView.dequeue(cellAt: indexPath, for: Constants.Cells.Identifiers.pizza)
        cell.textLabel?.text = pizza.name
        cell.detailTextLabel?.text = pizza.ingredients
        return cell
    }
}
