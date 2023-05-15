import UIKit

final class ChatViewController: UIViewController {
    // MARK: Properties
    private let chatView: ChatView = {
        let view = ChatView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let chatManager = ChatManager()
    private var messages: [String] = []

    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigation()
        configureView()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    // MARK: Methods
    private func configureNavigation() {
        navigationItem.title = "AI Chat"
    }

    private func configureView() {
        view.addSubview(chatView)

        NSLayoutConstraint.activate([
            chatView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            chatView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            chatView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            chatView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        chatView.setTextViewDelegate(delegate: self)
        chatView.setTableViewDataSource(dataSource: self)
        chatView.setSendButtonAction(action: UIAction(handler: { [weak self] action in
            self?.touchUpSendButton()
        }))
    }

    private func touchUpSendButton() {
        guard let inputMessage = chatView.inputMessage?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return
        }

        messages.append(inputMessage)
        updateChatView()
        sendMessage(inputMessage)
    }

    private func updateChatView() {
        chatView.updateTableView()
        chatView.clearTextView()
        chatView.resizeTextViewHeight()
        chatView.updateSendButtonState()
        chatView.setLoadingIndicatorVisible(true)
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
                self?.chatView.updateTableView()
                self?.chatView.setLoadingIndicatorVisible(false)
            }
        }
    }
}

// MARK: TableView DataSource
extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatView.configureCell(with: messages, indexPath: indexPath)
        return cell
    }
}

// MARK: TextView Delegate
extension ChatViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        // 텍스트 라인에 따라 텍스트뷰 크기 동적으로 변경
        chatView.resizeTextViewHeight()
        // 텍스트 비어있는지 여부에 따라 sendButton 상태 업데이트
        chatView.updateSendButtonState()
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // 텍스트 없는 상태에서 리턴키 들어오면 입력받지 않음
        if text == "\n" && textView.text.isEmpty {
            return false
        }

        return true
    }
}
