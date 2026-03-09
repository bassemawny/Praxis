import AVFoundation
import Observation

@Observable
@MainActor
final class AudioRecorderService {
    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?

    func startRecording() {
        let session = AVAudioSession.sharedInstance()

        do {
            try session.setCategory(.record, mode: .default)
            try session.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
            return
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("m4a")

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.record()
            recordingURL = url
        } catch {
            print("Failed to start recording: \(error)")
        }
    }

    func stopRecording() -> Data? {
        audioRecorder?.stop()
        audioRecorder = nil

        guard let url = recordingURL else { return nil }

        defer {
            try? FileManager.default.removeItem(at: url)
            recordingURL = nil
        }

        return try? Data(contentsOf: url)
    }
}
