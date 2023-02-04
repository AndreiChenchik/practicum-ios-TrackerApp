import UIKit

final class YPInputCollectionCell: UICollectionViewCell {
    private var onChange: ((String?) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        cell.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cell)

        NSLayoutConstraint.activate([
            cell.topAnchor.constraint(equalTo: topAnchor),
            cell.leadingAnchor.constraint(equalTo: leadingAnchor),
            cell.trailingAnchor.constraint(equalTo: trailingAnchor),
            cell.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var cell = CellView(content: textInput)

    private lazy var textInput: UITextField = {
        let input = UITextField()

        input.font = .asset(.ysDisplayRegular, size: 17)
        input.clearButtonMode = .always

        input.addTarget(self, action: #selector(textChanged), for: .allEditingEvents)

        input.translatesAutoresizingMaskIntoConstraints = false
        return input
    }()

    @objc func textChanged(_ sender: UITextInput) {
        onChange?(textInput.text)
    }

    func configure(
        text: String?,
        placeholder: String?,
        outCorner: [CellCorner],
        onChange: ((String?) -> Void)?
    ) {
        textInput.text = text
        textInput.placeholder = placeholder
        self.onChange = onChange
        cell.update(outCorner: outCorner)
    }

    override func prepareForReuse() {
        configure(text: nil, placeholder: nil, outCorner: [], onChange: nil)
    }
}
