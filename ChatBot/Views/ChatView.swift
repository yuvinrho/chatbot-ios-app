import UIKit

final class ChatView: UIView {
    // MARK: Private Properties
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = .systemGray6
        return tableView
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()

    private let textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.backgroundColor = .systemGray3
        textView.layer.cornerRadius = 10
        textView.text = " " // 컨텐츠 크기에 따라 텍스트뷰 높이를 동적으로 조절하기 떄문에 빈칸 있어야함
        textView.textColor = .black
        return textView
    }()

    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "paperplane"), for: .normal)
        button.isEnabled = false
        return button
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.startAnimating()
        indicator.isHidden = true
        return indicator
    }()

    // MARK: Properties
    var inputMessage: String? {
        return textView.text
    }

    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)

        configureView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Private Methods
    private func configureView() {
        addSubview(tableView)
        addSubview(stackView)

        [textView, sendButton, loadingIndicator].forEach {
            stackView.addArrangedSubview($0)
        }

        configureConstraints()
    }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),

            stackView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor, constant: -8),

            textView.heightAnchor.constraint(equalToConstant: textView.contentSize.height)
        ])
    }

    // MARK: Methods
    func setTextViewDelegate(delegate: UITextViewDelegate) {
        textView.delegate = delegate
    }

    func setTableViewDataSource(dataSource: UITableViewDataSource) {
        tableView.dataSource = dataSource
    }

    func setSendButtonAction(action: UIAction) {
        sendButton.addAction(action, for: .touchUpInside)
    }

    func setLoadingIndicatorVisible(_ isVisible: Bool) {
        loadingIndicator.isHidden = !isVisible
        sendButton.isHidden = isVisible
    }

    func enabledSendButton(_ isEnable: Bool) {
        sendButton.isEnabled = isEnable
    }

    func configureCell(with messages: [String], indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = messages[indexPath.row]
        cell.textLabel?.numberOfLines = 0

        if indexPath.row % 2 == 0 {
            cell.contentView.backgroundColor = .systemGray4
        } else {
            cell.contentView.backgroundColor = .white
        }

        return cell
    }

    func clearTextView() {
        textView.resignFirstResponder()
        textView.text = " "
    }

    func updateTableView() {
        tableView.reloadData()
        let lastRowIndex = self.tableView.numberOfRows(inSection: 0) - 1
        let lastIndexPath = IndexPath(row: lastRowIndex, section: 0)
        tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
    }

    // 입력한 메시지가 있으면 버튼 활성화, 없으면 비활성화
    func updateSendButtonState() {
        if let inputMessage = inputMessage?.trimmingCharacters(in: .whitespacesAndNewlines),
           !inputMessage.isEmpty,
           inputMessage != "" {
            sendButton.isEnabled = true
        } else {
            sendButton.isEnabled = false
        }
    }

    // 입력한 메시지 크기에 따라 텍스트뷰 높이 동적으로 조절
    func resizeTextViewHeight() {
        let maxSize = frame.height / 4
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)

        textView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                if estimatedSize.height >= maxSize {
                    constraint.constant = maxSize
                    return
                }

                constraint.constant = estimatedSize.height
            }
        }
    }
}
