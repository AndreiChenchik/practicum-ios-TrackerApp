import UIKit

final class TrackerCategoryViewController: UIViewController {
    private let viewModel: TrackerCategoryViewModel

    init(viewModel: TrackerCategoryViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

        viewModel.bind { [weak self] in
            self?.tableView.reloadData()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        title = "Категория"
        setupAppearance()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updatePlaceholderVisibility()
        tableView.reloadData()

        if viewModel.categories.count > 0 {
            tableView.scrollToRow(at: .init(row: 0, section: 0), at: .top, animated: false)
        }
    }

    // MARK: Components

    private lazy var tableView: UITableView = {
        let table = UITableView()

        table.register(CategoryTableViewCell.self,
                       forCellReuseIdentifier: "\(CategoryTableViewCell.self)")

        table.contentInset = .init(top: 24, left: 0, bottom: 95, right: 0)
        table.separatorColor = .clear

        table.delegate = self
        table.dataSource = self
        table.tableHeaderView = UIView()

        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    private lazy var addButton: UIButton = {
        let button = YPButton(label: "Добавить категорию")
        button.addTarget(self, action: #selector(addCategory), for: .touchUpInside)

        return button
    }()

    private lazy var startPlaceholderView: UIView = {
        let view = UIView.placeholderView(
            message: "Привычки и события можно\nобъединить по смыслу",
            icon: .trackerStartPlaceholder
        )

        view.alpha = 0

        return view
    }()
}

// MARK: - UITableViewDelegate
extension TrackerCategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectCategory(indexPath)

        if let navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}

// MARK: - UITableViewDataSource

extension TrackerCategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.categories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "\(CategoryTableViewCell.self)", for: indexPath
        ) as? CategoryTableViewCell else {
            fatalError("Can't get cell for ImagesList")
        }

        let category = viewModel.categories[indexPath.row]

        let isFirstCell = indexPath.row == 0
        let isLastCell = indexPath.row == viewModel.categories.count - 1
        let isSelected = category == viewModel.selectedCategory

        cell.configure(
            label: category.label,
            isSelected: isSelected,
            outCorner: (isFirstCell ? [.top] : []) + (isLastCell ? [.bottom] : []),
            hasDivider: !isLastCell
        )

        return cell
    }
}

// MARK: - Appearance

private extension TrackerCategoryViewController {
    func updatePlaceholderVisibility() {
        self.startPlaceholderView.alpha = viewModel.categories.count == 0 ? 1 : 0
    }

    func setupAppearance() {
        navigationItem.hidesBackButton = true

        view.backgroundColor = .asset(.white)

        view.addSubview(tableView)
        view.addSubview(addButton)
        view.addSubview(startPlaceholderView)

        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            addButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            addButton.heightAnchor.constraint(equalToConstant: 60),
            addButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -16),
            startPlaceholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            startPlaceholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - Actions

private extension TrackerCategoryViewController {
    @objc func addCategory() {
        viewModel.onNewCategory()
    }
}
