import UIKit

final class RandomJokeViewController: UIViewController {
    
    private var viewModel: RandomJokeViewModelProtocol
    
    private lazy var jokeLabel: UILabel = {
        let label = UILabel()
        label.text = "Нажмите «Загрузить»"
        label.numberOfLines = 0
        label.textColor = .black
        label.textAlignment = .center

        return label
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = .medium
        indicator.hidesWhenStopped = true

        return indicator
    }()
    
    private lazy var loadButton: UIButton = {
        let button = UIButton()
        button.setTitle("Загрузить", for: .normal)
        button.tintColor = .white
        button.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        button.layer.cornerRadius = 8.0
        button.backgroundColor = .systemBlue
        button.addTarget(self, action: #selector(loadButtonTapped), for: .touchUpInside)

        return button
    }()
    
    init(viewModel: RandomJokeViewModelProtocol = RandomJokeViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.title = "Случайная цитата"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        bindingViewModel()
    }
    
    private func setupUI() {
        [jokeLabel, activityIndicator, loadButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            jokeLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16.0),
            jokeLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16.0),
            jokeLabel.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor, constant: -24.0),
            jokeLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: jokeLabel.bottomAnchor, constant: 16.0),
            
            loadButton.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 16.0),
            loadButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
            loadButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0)
        ])
    }
    
    private func bindingViewModel() {
        viewModel.onJokeUpdated = { [weak self] text in
            DispatchQueue.main.async {
                self?.jokeLabel.text = text
            }
        }
        
        viewModel.onLoadingChanged = { [weak self] isLoading in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if isLoading {
                    self.activityIndicator.startAnimating()
                    self.jokeLabel.textColor = .gray
                    self.loadButton.alpha = 0.7
                    self.loadButton.isEnabled = false
                } else {
                    self.activityIndicator.stopAnimating()
                    self.jokeLabel.textColor = .black
                    self.loadButton.alpha = 1.0
                    self.loadButton.isEnabled = true
                }
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
    
    @objc private func loadButtonTapped() {
        Task {
            await viewModel.loadRandomJoke()
        }
    }
}
