import UIKit

final class TrackerCategoryViewController: UIViewController {
    private let completion: (TrackerCategory, [TrackerCategory]) -> Void

    private var categories: [TrackerCategory]
    private var selectedCategory: TrackerCategory?

    init(
        _ categories: [TrackerCategory],
        selectedCategory: TrackerCategory?,
        completion: @escaping (TrackerCategory, [TrackerCategory]) -> Void
    ) {
        self.categories = categories
        self.selectedCategory = selectedCategory

        self.completion = completion

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        title = "Категория"
        setupAppearance()
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
        button.addTarget(self, action: #selector(done), for: .touchUpInside)

        return button
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if categories.count > 0 {
            tableView.scrollToRow(at: .init(row: 0, section: 0), at: .top, animated: false)
        }
    }
}

// MARK: - UITableViewDelegate
extension TrackerCategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = categories[indexPath.row]
        selectedCategory = category
        completion(category, categories)

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
        categories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "\(CategoryTableViewCell.self)", for: indexPath
        ) as? CategoryTableViewCell else {
            fatalError("Can't get cell for ImagesList")
        }

        let category = categories[indexPath.row]

        let isFirstCell = indexPath.row == 0
        let isLastCell = indexPath.row == categories.count - 1
        let isSelected = category == selectedCategory

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
    func setupAppearance() {
        navigationItem.hidesBackButton = true

        view.backgroundColor = .asset(.white)

        view.addSubview(tableView)
        view.addSubview(addButton)

        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            addButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            addButton.heightAnchor.constraint(equalToConstant: 60),
            addButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - Actions

private extension TrackerCategoryViewController {
    @objc func done() {
        completion(selectedCategory!, categories)

        if let navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}

// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct TrackerCategoryViewController_Previews: PreviewProvider {
    static var previews: some View {
        Text("hello")
            .sheet(isPresented: .constant(true)) {
                UIViewControllerPreview {
                    let array = [TrackerCategory](repeating: .mockHome, count: 20)
                    let rootVC = TrackerCategoryViewController(array, selectedCategory: array[3]) { _, _ in }
                    let viewController = UINavigationController(rootViewController: rootVC)
                    viewController.configureForModal()
                    return viewController
                }
                .edgesIgnoringSafeArea(.all)
            }
            .edgesIgnoringSafeArea(.all)
    }
}
#endif
