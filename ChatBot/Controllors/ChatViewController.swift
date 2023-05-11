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

    private let textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Send a message."
        textField.backgroundColor = .systemGray3
        textField.rightViewMode = .always
        textField.borderStyle = .roundedRect
        return textField
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
        return indicator
    }()

    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigation()
        configureView()
        configureConstraints()
    }

    // MARK: Methods
    private func configureNavigation() {
        navigationItem.title = "AI Chat"
    }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            tableView.bottomAnchor.constraint(equalTo: textField.topAnchor, constant: -8),

            textField.heightAnchor.constraint(equalToConstant: 50),
            textField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            textField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            textField.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
        ])
    }

    private func configureView() {
        tableView.dataSource = self
        textField.delegate = self
        textField.rightView = sendButton

        sendButton.addAction(UIAction(handler: { [weak self] action in
            self?.touchUpSendButton()
        }), for: .touchUpInside)

        view.addSubview(tableView)
        view.addSubview(textField)
    }

    private func clearTextField() {
        textField.text = nil
        textField.resignFirstResponder()
    }

    private func touchUpSendButton() {
        guard let inputMessage = textField.text else {
            return
        }

        messages.append(inputMessage)
        updateTableView()
        clearTextField()
        showLoadingIndicator(true)

        chatManager.sendMessage(inputMessage) { [weak self] result in
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

    private func updateTableView() {
        self.tableView.reloadData()
        let lastRowIndex = self.tableView.numberOfRows(inSection: 0) - 1
        let lastIndexPath = IndexPath(row: lastRowIndex, section: 0)
        self.tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
    }

    private func showLoadingIndicator(_ flag: Bool) {
        let rightView = flag ? loadingIndicator : sendButton
        textField.rightView = rightView
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

// MARK: TextField Delegate
extension ChatViewController: UITextFieldDelegate {
    // 리턴키 누르면 키보드 사라지게 하기
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // 입력한 메시지 없으면 sendButton 비활성화
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let inputMessage = textField.text, !inputMessage.isEmpty {
            sendButton.isEnabled = true
        } else {
            sendButton.isEnabled = false
        }
    }
}
