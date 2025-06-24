import UIKit

/// Delegate to handle sending configuration to the network at 3 Hz.
protocol NetworkConfigViewDelegate: AnyObject {
    func networkConfigView(_ view: NetworkConfigView,
                           didTapSendTo ip: String,
                           port: Int,
                           payload: Data)
}

/// A view that lets the user enter an IP/port and stream distance & azimuth to the server
/// when connected. It toggles between **Connect** and **Disconnect** and emits delegate
/// callbacks three times per second while connected.
class NetworkConfigView: UIView {

    // MARK: – Public API
    weak var delegate: NetworkConfigViewDelegate?
    /// Reference to the view that exposes the current distance & azimuth strings.
    weak var locationFields: LocationFields?
    /// Callback providing info about all connected devices to send over the network.
    var dataProvider: (() -> [[String: Any]])?

    // MARK: – Connection State
    private var isConnected = false
    private var sendTimer: Timer?
    private var cachedIP   = ""
    private var cachedPort = 0

    // MARK: – Sub‑views
    private let ipTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "IP Address"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .decimalPad  // dotted‑decimal keypad for IPv4
        return tf
    }()

    private let portTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Port"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .numberPad
        return tf
    }()

    private let connectButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.title = "Connect"
            config.baseBackgroundColor = .systemGreen
            config.baseForegroundColor = .white
            config.cornerStyle = .medium
            btn.configuration = config
        } else {
            btn.setTitle("Connect", for: .normal)
            btn.setTitleColor(.white, for: .normal)
            btn.backgroundColor = .systemGreen
            btn.layer.cornerRadius = 8
        }
        return btn
    }()

    // MARK: – Initialisation
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        translatesAutoresizingMaskIntoConstraints = false
        setupSubviews()
        setupConstraints()
    }

    deinit {
        sendTimer?.invalidate()   // ensure the timer stops when the view is gone
    }

    // MARK: – View Composition
    private func setupSubviews() {
        addSubview(ipTextField)
        addSubview(portTextField)
        addSubview(connectButton)

        connectButton.addTarget(self, action: #selector(connectTapped), for: .touchUpInside)

        // Dismiss keyboard when tapping outside the text‑fields
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        addGestureRecognizer(tap)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // IP field
            ipTextField.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            ipTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            ipTextField.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5, constant: -12),
            ipTextField.heightAnchor.constraint(equalToConstant: 36),

            // Port field
            portTextField.topAnchor.constraint(equalTo: ipTextField.topAnchor),
            portTextField.leadingAnchor.constraint(equalTo: ipTextField.trailingAnchor, constant: 8),
            portTextField.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.25, constant: -12),
            portTextField.heightAnchor.constraint(equalToConstant: 36),

            // Connect button
            connectButton.topAnchor.constraint(equalTo: ipTextField.topAnchor),
            connectButton.leadingAnchor.constraint(equalTo: portTextField.trailingAnchor, constant: 8),
            connectButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            connectButton.centerYAnchor.constraint(equalTo: ipTextField.centerYAnchor),
            connectButton.heightAnchor.constraint(equalToConstant: 36),
            connectButton.widthAnchor.constraint(equalToConstant: 100)
        ])
    }

    // MARK: – User Interaction
    @objc private func connectTapped() {
        dismissKeyboard()

        if isConnected {
            stopStreaming()
            updateButton(isConnected: false)
            return
        }

        // Validate inputs
        guard let ip = ipTextField.text, !ip.isEmpty,
              let portText = portTextField.text, let port = Int(portText) else { return }

        cachedIP = ip
        cachedPort = port

        startStreaming()
        updateButton(isConnected: true)
    }

    @objc private func dismissKeyboard() {
        endEditing(true)
    }

    // MARK: – Streaming helpers
    private func startStreaming() {
        // Kick off with an immediate packet, then schedule 3 Hz updates.
        sendPacket()

        sendTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 3.0, repeats: true) { [weak self] _ in
            self?.sendPacket()
        }
        if let timer = sendTimer {
            // Keep firing during scroll/gesture by putting the timer in `.common` run‑loop modes.
            RunLoop.main.add(timer, forMode: .common)
        }
        isConnected = true
    }

    private func stopStreaming() {
        sendTimer?.invalidate()
        sendTimer = nil
        isConnected = false
    }

    private func sendPacket() {
        let info = dataProvider?() ?? []
        guard JSONSerialization.isValidJSONObject(info),
              let json = try? JSONSerialization.data(withJSONObject: info) else {
            return
        }

        delegate?.networkConfigView(self,
                                    didTapSendTo: cachedIP,
                                    port: cachedPort,
                                    payload: json)
    }

    // MARK: – UI State
    private func updateButton(isConnected: Bool) {
        if #available(iOS 15.0, *) {
            connectButton.configuration?.title = isConnected ? "Disconnect" : "Connect"
            connectButton.configuration?.baseBackgroundColor = isConnected ? .systemRed : .systemGreen
        } else {
            connectButton.setTitle(isConnected ? "Disconnect" : "Connect", for: .normal)
            connectButton.backgroundColor = isConnected ? .systemRed : .systemGreen
        }
    }

    // MARK: – Intrinsic Size
    override var intrinsicContentSize: CGSize {
        // Keeps the view visible when used inside a UIStackView
        CGSize(width: UIView.noIntrinsicMetric, height: 52)
    }
}
