import AVFoundation

final class SpeechController {
    private let synthesizer = AVSpeechSynthesizer()

    func speak(
        text: String,
        webRate: Double,
        voiceIdentifier: String?,
        voiceName: String?,
        language: String?
    ) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        do {
            let session = AVAudioSession.sharedInstance()
            // Playback keeps speech available even when the device's Ring/Silent switch
            // is muted, which is important for an AAC communication app.
            try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try session.setActive(true)
        } catch {
            // Speech can still work if the audio session cannot be changed.
        }

        synthesizer.stopSpeaking(at: .immediate)

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

        synthesizer.speak(utterance)
    }

    private static func nativeRate(fromWebRate webRate: Double) -> Float {
        // The web UI uses familiar 0.65-1.0 style values, while AVSpeechUtterance
        // uses a different scale. Map it into a comfortable spoken range.
        let clamped = min(max(webRate, 0.60), 1.05)
        let fraction = (clamped - 0.60) / 0.45
        return Float(0.36 + (0.20 * fraction))
    }
}
