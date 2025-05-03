import UIKit

/// Delegate to handle sending configuration to the network.
protocol NetworkConfigViewDelegate: AnyObject {
    /// Called when the user taps "Send".
    /// - Parameters:
    ///   - view: The NetworkConfigView instance.
    ///   - ip: The IP address input.
    ///   - port: The port number input.
    ///   - distance: The current distance string from LocationFields.
    ///   - azimuth: The current azimuth string from LocationFields.
    func networkConfigView(_ view: NetworkConfigView,
                           didTapSendTo ip: String,
                           port: Int,
                           distance: String,
                           azimuth: String)
}

/// A view that allows entering an IP and Port, and sending distance/azimuth via HTTP.
class NetworkConfigView: UIView {
    // MARK: – Public API
    weak var delegate: NetworkConfigViewDelegate?

    /// Reference to the LocationFields view to read current values.
    weak var locationFields: LocationFields?

    // MARK: – Subviews
    private let ipTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "IP Address"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .decimalPad
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

    private let sendButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.title = "Send"
            config.baseBackgroundColor = .systemBlue
            config.baseForegroundColor = .white
            config.cornerStyle = .medium
            btn.configuration = config
        } else {
            btn.setTitle("Send", for: .normal)
            btn.setTitleColor(.white, for: .normal)
            btn.backgroundColor = .systemBlue
            btn.layer.cornerRadius = 8
        }
        return btn
    }()

    // MARK: – Initialization
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

    // MARK: – View Setup
    private func setupSubviews() {
        addSubview(ipTextField)
        addSubview(portTextField)
        addSubview(sendButton)

        // Actions
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)

        // Dismiss keyboard on tap outside
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        addGestureRecognizer(tapGesture)
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

            // Send button
            sendButton.topAnchor.constraint(equalTo: ipTextField.topAnchor),
            sendButton.leadingAnchor.constraint(equalTo: portTextField.trailingAnchor, constant: 8),
            sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            sendButton.centerYAnchor.constraint(equalTo: ipTextField.centerYAnchor),
            sendButton.heightAnchor.constraint(equalToConstant: 36),
            sendButton.widthAnchor.constraint(equalToConstant: 80)
        ])
    }

    // MARK: – Actions
    @objc private func sendTapped() {
        dismissKeyboard()
        // Validate IP & port
        guard let ip = ipTextField.text, !ip.isEmpty,
              let portText = portTextField.text,
              let port = Int(portText) else { return }

        // Read distance & azimuth from the associated LocationFields
        let distance = locationFields?.currentDistance ?? ""
        let azimuth  = locationFields?.currentAzimuth  ?? ""

        // Notify delegate
        delegate?.networkConfigView(self,
                                    didTapSendTo: ip,
                                    port: port,
                                    distance: distance,
                                    azimuth: azimuth)
    }

    @objc private func dismissKeyboard() {
        endEditing(true)
    }

    // MARK: – Intrinsic Content Size
    override var intrinsicContentSize: CGSize {
        // Ensures the view has a visible height in a UIStackView
        return CGSize(width: UIView.noIntrinsicMetric, height: 52)
    }
}

