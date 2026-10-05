import AVFoundation

final class SpeechController: NSObject, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()

    private var pendingStart: DispatchWorkItem?
    private var currentUtterance: AVSpeechUtterance?
    var onError: ((String) -> Void)?

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(
        text: String,
        webRate: Double,
        voiceIdentifier: String?,
        voiceName: String?,
        language: String?
    ) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        pendingStart?.cancel()
        currentUtterance = nil
        if synthesizer.isSpeaking || synthesizer.isPaused {
            synthesizer.stopSpeaking(at: .immediate)
        }

        do {
            let session = AVAudioSession.sharedInstance()
            // Playback keeps speech available even when the device's Ring/Silent switch
            // is muted, which is important for an AAC communication app.
            try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try session.setActive(true)
        } catch {
            onError?("Audio could not start. Please try Speak again. (\(error.localizedDescription))")
            return
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.pitchMultiplier = 1.0
        utterance.rate = Self.nativeRate(fromWebRate: webRate)

        if let voiceIdentifier,
           !voiceIdentifier.isEmpty,
           let exactVoice = AVSpeechSynthesisVoice(identifier: voiceIdentifier) {
            utterance.voice = exactVoice
        } else if let voiceName, !voiceName.isEmpty,
                  let namedVoice = AVSpeechSynthesisVoice.speechVoices().first(where: { $0.name == voiceName }) {
            utterance.voice = namedVoice
        } else if let language, !language.isEmpty {
            utterance.voice = AVSpeechSynthesisVoice(language: language)
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        }

        currentUtterance = utterance
        let timeout = DispatchWorkItem { [weak self, weak utterance] in
            guard let self, let utterance, self.currentUtterance === utterance else { return }
            self.currentUtterance = nil
            self.synthesizer.stopSpeaking(at: .immediate)
            self.onError?("Speech did not start. Please try again. If this continues, choose another voice in Settings.")
        }
        pendingStart = timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: timeout)
        synthesizer.speak(utterance)
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            guard let self, self.currentUtterance === utterance else { return }
            self.pendingStart?.cancel()
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            guard let self, self.currentUtterance === utterance else { return }
            self.pendingStart?.cancel()
            self.currentUtterance = nil
        }
    }

    private static func nativeRate(fromWebRate webRate: Double) -> Float {
        // Lori's Voice intentionally uses three clearly separated speech speeds.
        // The HTML stores 0.62 / 0.74 / 0.92 for backward compatibility with
        // existing saved boards, but native iOS speech uses these fixed AVSpeech rates.
        if webRate < 0.69 {
            return 0.30   // Slow
        }
        if webRate < 0.85 {
            return 0.40   // Normal
        }
        return 0.52       // Fast
    }
}
