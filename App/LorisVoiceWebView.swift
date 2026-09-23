import AVFoundation
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers
import WebKit

struct LorisVoiceWebView: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        let controller = WKUserContentController()
        controller.add(context.coordinator, name: "lorisVoice")

        if let boardJSON = BoardStore.shared.loadJSON(),
           let jsonLiteral = Self.javaScriptStringLiteral(boardJSON) {
            let source = "window.__LORIS_NATIVE_MODEL__ = JSON.parse(\(jsonLiteral));"
            controller.addUserScript(WKUserScript(
                source: source,
                injectionTime: .atDocumentStart,
                forMainFrameOnly: true
            ))
        }

        if let voicesJSON = Self.nativeVoicesJSON() {
            let source = "window.__LORIS_NATIVE_VOICES__ = \(voicesJSON);"
            controller.addUserScript(WKUserScript(
                source: source,
                injectionTime: .atDocumentStart,
                forMainFrameOnly: true
            ))
        }

        if let appInfoJSON = Self.nativeAppInfoJSON() {
            let source = "window.__LORIS_NATIVE_INFO__ = \(appInfoJSON);"
            controller.addUserScript(WKUserScript(
                source: source,
                injectionTime: .atDocumentStart,
                forMainFrameOnly: true
            ))
        }

        let configuration = WKWebViewConfiguration()
        configuration.userContentController = controller
        configuration.websiteDataStore = .default()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true

        let webView = WKWebView(frame: .zero, configuration: configuration)
        context.coordinator.webView = webView
        webView.navigationDelegate = context.coordinator
        webView.scrollView.bounces = false
        webView.allowsBackForwardNavigationGestures = false
        webView.isOpaque = false
        webView.backgroundColor = UIColor(red: 243/255, green: 239/255, blue: 231/255, alpha: 1)
        webView.scrollView.backgroundColor = webView.backgroundColor

        #if DEBUG
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
        #endif

        guard let indexURL = Bundle.main.url(forResource: "index", withExtension: "html") else {
            assertionFailure("Bundled index.html was not found.")
            return webView
        }

        webView.loadFileURL(indexURL, allowingReadAccessTo: indexURL.deletingLastPathComponent())
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        uiView.configuration.userContentController.removeScriptMessageHandler(forName: "lorisVoice")
    }

    private static func javaScriptStringLiteral(_ value: String) -> String? {
        guard let data = try? JSONEncoder().encode(value) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private static func nativeVoicesJSON() -> String? {
        let voices = AVSpeechSynthesisVoice.speechVoices().map { voice in
            [
                "name": voice.name,
                "lang": voice.language,
                "voiceURI": voice.identifier,
                "localService": true
            ] as [String: Any]
        }
        guard let data = try? JSONSerialization.data(withJSONObject: voices),
              let json = String(data: data, encoding: .utf8) else { return nil }
        return json
    }

    private static func nativeAppInfoJSON() -> String? {
        let info: [String: Any] = [
            "version": Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0",
            "build": Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "",
            "storage": BoardStore.shared.storageDescription
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: info),
              let json = String(data: data, encoding: .utf8) else { return nil }
        return json
    }

    final class Coordinator: NSObject,
                             WKScriptMessageHandler,
                             WKNavigationDelegate,
                             UIDocumentPickerDelegate,
                             PHPickerViewControllerDelegate {
        weak var webView: WKWebView?
        private let speech = SpeechController()

        func userContentController(_ userContentController: WKUserContentController,
                                   didReceive message: WKScriptMessage) {
            guard message.name == "lorisVoice",
                  let body = message.body as? [String: Any],
                  let action = body["action"] as? String else { return }

            switch action {
            case "saveModel":
                guard let json = body["json"] as? String else { return }
                let requestId = body["requestId"] as? String
                do {
                    try BoardStore.shared.save(json: json)
                    if let requestId {
                        completeSave(requestId: requestId, ok: true, message: "")
                    }
                } catch {
                    if let requestId {
                        completeSave(requestId: requestId, ok: false, message: error.localizedDescription)
                    }
                }

            case "speak":
                guard let text = body["text"] as? String else { return }
                let rate = body["rate"] as? Double ?? 0.9
                let voiceURI = body["voiceURI"] as? String
                let voiceName = body["voiceName"] as? String
                let lang = body["lang"] as? String
                speech.speak(
                    text: text,
                    webRate: rate,
                    voiceIdentifier: voiceURI,
                    voiceName: voiceName,
                    language: lang
                )

            case "exportBoard":
                guard let json = body["json"] as? String else { return }
                let filename = (body["filename"] as? String) ?? "Loris_Voice_Backup.json"
                exportBoard(json: json, filename: filename)

            case "importBoard":
                presentDocumentPicker()

            case "pickPhoto":
                presentPhotoPicker()

            default:
                break
            }
        }

        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }

            if url.isFileURL || url.scheme == "about" {
                decisionHandler(.allow)
                return
            }

            if let scheme = url.scheme?.lowercased(), scheme == "http" || scheme == "https" {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }

            decisionHandler(.allow)
        }

        private func exportBoard(json: String, filename: String) {
            let safeName = filename.replacingOccurrences(of: "/", with: "-")
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(safeName)
            do {
                try json.write(to: url, atomically: true, encoding: .utf8)
                guard let presenter = Self.topViewController() else { return }
                let share = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                if let popover = share.popoverPresentationController {
                    popover.sourceView = presenter.view
                    popover.sourceRect = CGRect(
                        x: presenter.view.bounds.midX,
                        y: presenter.view.bounds.midY,
                        width: 1,
                        height: 1
                    )
                    popover.permittedArrowDirections = []
                }
                presenter.present(share, animated: true)
            } catch {
                showAlert(title: "Backup could not be created", message: error.localizedDescription)
            }
        }

        private func presentDocumentPicker() {
            guard let presenter = Self.topViewController() else { return }
            let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.json], asCopy: true)
            picker.delegate = self
            picker.allowsMultipleSelection = false
            presenter.present(picker, animated: true)
        }

        func documentPicker(_ controller: UIDocumentPickerViewController,
                            didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            do {
                let data = try Data(contentsOf: url)
                guard let json = String(data: data, encoding: .utf8),
                      let literal = LorisVoiceWebView.javaScriptStringLiteral(json) else {
                    throw CocoaError(.fileReadCorruptFile)
                }
                webView?.evaluateJavaScript("window.nativeImportBoard(\(literal));")
            } catch {
                showAlert(title: "Backup could not be opened", message: error.localizedDescription)
            }
        }

        private func presentPhotoPicker() {
            guard let presenter = Self.topViewController() else { return }
            var configuration = PHPickerConfiguration(photoLibrary: .shared())
            configuration.filter = .images
            configuration.selectionLimit = 1
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            presenter.present(picker, animated: true)
        }

        func picker(_ picker: PHPickerViewController,
                    didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self) else { return }

            provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                if let error {
                    DispatchQueue.main.async {
                        self?.showAlert(title: "Photo could not be opened", message: error.localizedDescription)
                    }
                    return
                }

                guard let image = object as? UIImage,
                      let jpeg = image.resized(maxDimension: 480).jpegData(compressionQuality: 0.82) else { return }

                let dataURL = "data:image/jpeg;base64,\(jpeg.base64EncodedString())"
                guard let literal = LorisVoiceWebView.javaScriptStringLiteral(dataURL) else { return }
                DispatchQueue.main.async {
                    self?.webView?.evaluateJavaScript("window.nativePhotoSelected(\(literal));")
                }
            }
        }

        private func completeSave(requestId: String, ok: Bool, message: String) {
            guard let requestLiteral = LorisVoiceWebView.javaScriptStringLiteral(requestId),
                  let messageLiteral = LorisVoiceWebView.javaScriptStringLiteral(message) else { return }
            let script = "window.nativeSaveCompleted(\(requestLiteral), \(ok ? "true" : "false"), \(messageLiteral));"
            DispatchQueue.main.async { [weak self] in
                self?.webView?.evaluateJavaScript(script)
            }
        }

        private func showAlert(title: String, message: String) {
            DispatchQueue.main.async {
                guard let presenter = Self.topViewController() else { return }
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                presenter.present(alert, animated: true)
            }
        }

        private static func topViewController(base: UIViewController? = nil) -> UIViewController? {
            let root: UIViewController? = base ?? UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first(where: { $0.isKeyWindow })?
                .rootViewController

            if let navigation = root as? UINavigationController {
                return topViewController(base: navigation.visibleViewController)
            }
            if let tab = root as? UITabBarController, let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
            if let presented = root?.presentedViewController {
                return topViewController(base: presented)
            }
            return root
        }
    }
}

private extension UIImage {
    func resized(maxDimension: CGFloat) -> UIImage {
        let largest = max(size.width, size.height)
        guard largest > maxDimension else { return self }

        let scale = maxDimension / largest
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
