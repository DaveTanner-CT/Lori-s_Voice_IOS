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
            try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try session.setActive(true)
        } catch {
            // Speech can still work if the audio session cannot be changed.
        }

        synthesizer.stopSpeaking(at: .immediate)

        let utterance = AVSpeechUtterance(string: text)
        utterance.pitchMultiplier = 1.0
        utterance.rate = webRate < 0.85 ? 0.42 : AVSpeechUtteranceDefaultSpeechRate

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
}
