import UIKit

final class JokesListTableViewController: UITableViewController {

    private var viewModel: JokesListViewModelProtocol
   
    init(viewModel: JokesListViewModelProtocol = JokesListViewModel(mode: .all)) {
        self.viewModel = viewModel
        super.init(style: .plain)
        self.title = "Все цитаты"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        bindingViewModel()
        viewModel.loadJokes()
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
                guard let self = self else { return }
                let alert = UIAlertController(
                    title: "Ошибка",
                    message: message,
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
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
        DispatchQueue.main.async { [weak self] in
            self?.viewModel.loadJokes()
        }
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
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "Cell",
            for: indexPath
        )

        var config = cell.defaultContentConfiguration()
        config.text = viewModel.jokeText(at: indexPath.row)
        config.textProperties.numberOfLines = 0
        config.secondaryText = viewModel.subtitleText(at: indexPath.row)
        config.secondaryTextProperties.numberOfLines = 1
        cell.contentConfiguration = config

        return cell
    }
    
    override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            viewModel.deleteJoke(at: indexPath.row)
        }
    }
}
