import UIKit

final class NewCategoryViewController: UIViewController {
    private let store: TrackerStoring

    private var categoryName: String? { didSet { updateButtonStatus() } }

    init(
        store: TrackerStoring
    ) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        title = NSLocalizedString("newTracker.newCategory.title", comment: "Screen title")
        setupAppearance()
    }

    // MARK: Components

    private lazy var addButton: UIButton = {
        let button = YPButton(
            label: NSLocalizedString("newTracker.newCategory.create",
                                     comment: "Button label for creating new category")
        )
        button.addTarget(self, action: #selector(addCategory), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()

    private lazy var textInput: UIView = {
        let input = UITextField()

        input.font = .asset(.ysDisplayRegular, size: 17)
        input.clearButtonMode = .always
        input.placeholder = NSLocalizedString("newTracker.newCategory.textPlaceholder",
                                              comment: "Placeholder when text field is empty")

        input.addTarget(self, action: #selector(textChanged), for: .allEditingEvents)

        let inputView = CellView(content: input)
        inputView.update(outCorner: [.all])

        inputView.translatesAutoresizingMaskIntoConstraints = false
        return inputView
    }()
}

// MARK: - Appearance

private extension NewCategoryViewController {
    func setupAppearance() {
        view.backgroundColor = .asset(.white)
        navigationItem.hidesBackButton = true

        view.addSubview(addButton)
        view.addSubview(textInput)

        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            textInput.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 24),
            textInput.heightAnchor.constraint(equalToConstant: 75),
            textInput.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            textInput.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            addButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            addButton.heightAnchor.constraint(equalToConstant: 60),
            addButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -16)
        ])
    }
}

// MARK: - Actions

private extension NewCategoryViewController {
    @objc func addCategory() {
        guard let categoryName else {
            assertionFailure("Button should not be enabled")
            return
        }

        store.addCategory(.init(label: categoryName, trackers: []))

        if let navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    @objc func textChanged(_ sender: UITextInput) {
        let start  = sender.beginningOfDocument
        let end = sender.endOfDocument

        guard let range = sender.textRange(from: start, to: end) else {
            assertionFailure("Something went wrong")
            return
        }

        categoryName = sender.text(in: range)
    }

    func updateButtonStatus() {
        addButton.isEnabled = categoryName != nil && categoryName != ""
    }
}
