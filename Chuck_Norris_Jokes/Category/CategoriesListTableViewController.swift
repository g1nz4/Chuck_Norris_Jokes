import UIKit

final class CategoriesListTableViewController: UITableViewController {

    private var viewModel: CategoriesListViewModelProtocol
    
    init(viewModel: CategoriesListViewModelProtocol = CategoriesListViewModel()) {
        self.viewModel = viewModel
        super.init(style: .plain)
        self.title = "Категории"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        bindingViewModel()
        viewModel.loadListCategories()
        addObserver()
    }
    
    private func bindingViewModel() {
        viewModel.onDataChanged = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        viewModel.onError = { [weak self] message in
            DispatchQueue.main.async {
                let alert = UIAlertController(
                    title: "Ошибка",
                    message: message,
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleJokesDidChange),
            name: .jokesDidChange,
            object: nil
        )
    }
    
    @objc private func handleJokesDidChange() {
        viewModel.loadListCategories()
    }

    override func numberOfSections(
        in tableView: UITableView
    ) -> Int {
        return 1
    }

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return viewModel.numberOfItems
    }

    override func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath
    )-> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.text = viewModel.categoryName(at: indexPath.row)
        cell.accessoryType = .disclosureIndicator
        cell.contentConfiguration = config
        
        return cell
    }

    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        let category = viewModel.categoryName(at: indexPath.row)
        let vm = JokesListViewModel(mode: .category(category))
        let jokesVC = JokesListTableViewController(viewModel: vm)
        jokesVC.title = category
        navigationController?.pushViewController(jokesVC, animated: true)
    }
}
