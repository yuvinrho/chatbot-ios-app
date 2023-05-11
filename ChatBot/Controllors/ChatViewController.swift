import UIKit

final class ChatViewController: UIViewController {
    // MARK: Properties
    private let chatManager = ChatManager()
    private var messages: [String] = []

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
        textView.text = " "
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

    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigation()
        configureView()
        configureConstraints()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    // MARK: Methods
    private func configureNavigation() {
        navigationItem.title = "AI Chat"
    }

    private func configureConstraints() {
        view.addSubview(tableView)
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            tableView.bottomAnchor.constraint(equalTo: textView.topAnchor, constant: -8),

            stackView.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            stackView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),

            textView.heightAnchor.constraint(equalToConstant: textView.contentSize.height)
        ])
    }

    private func configureView() {
        tableView.dataSource = self
        textView.delegate = self

        sendButton.addAction(UIAction(handler: { [weak self] action in
            self?.touchUpSendButton()
        }), for: .touchUpInside)

        [textView, sendButton, loadingIndicator].forEach {
            stackView.addArrangedSubview($0)
        }
    }

    private func clearInputMessage() {
        textView.text = nil
        toggleSendButton()
        resizeTextViewHeight()
    }

    private func touchUpSendButton() {
        guard let inputMessage = textView.text else {
            return
        }

        messages.append(inputMessage)
        updateTableView()
        updateTextView()
        showLoadingIndicator(true)
        sendMessage(inputMessage)
    }

    private func sendMessage(_ message: String) {
        chatManager.sendMessage(message) { [weak self] result in
            switch result {
            case .success(let message):
                self?.messages.append(message)
            case .failure(let error):
                self?.messages.append(error.localizedDescription)
            }

            DispatchQueue.main.async {
                self?.updateTableView()
                self?.showLoadingIndicator(false)
            }
        }
    }

    private func updateTextView() {
        textView.resignFirstResponder()
        clearInputMessage()
    }

    private func updateTableView() {
        self.tableView.reloadData()
        let lastRowIndex = self.tableView.numberOfRows(inSection: 0) - 1
        let lastIndexPath = IndexPath(row: lastRowIndex, section: 0)
        self.tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
    }

    private func showLoadingIndicator(_ flag: Bool) {
        loadingIndicator.isHidden = !flag
        sendButton.isHidden = flag
    }

    // 입력한 메시지 크기에 따라 텍스트뷰 높이 동적으로 조절
    private func resizeTextViewHeight() {
        let maxSize = view.frame.height / 4
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

    // 입력한 메시지가 있으면 버튼 활성화, 없으면 비활성화
    private func toggleSendButton() {
        if let inputMessage = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines),
           !inputMessage.isEmpty,
           inputMessage != "" {
            sendButton.isEnabled = true
        } else {
            sendButton.isEnabled = false
        }
    }
}

// MARK: TableView DataSource
extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
}

// MARK: TextView Delegate
extension ChatViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        // 텍스트 라인에 따라 텍스트뷰 크기 동적으로 변경
        resizeTextViewHeight()
        // 텍스트 비어있는지 여부에 따라 sendButton 토글
        toggleSendButton()
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // 텍스트 없는 상태에서 리턴키 들어오면 입력받지 않음
        if text == "\n" && textView.text.isEmpty {
            return false
        }

        return true
    }
}
