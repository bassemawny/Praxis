import Testing
import Foundation
@testable import Praxis

@Suite("AudioRecorderService State Tests")
@MainActor
struct AudioRecorderServiceTests {

    @Test("Initial state: permissionDenied is false")
    func initialState() {
        let service = AudioRecorderService()
        #expect(service.permissionDenied == false)
    }

    @Test("stopRecording returns nil when not recording")
    func stopWithoutStart_returnsNil() {
        let service = AudioRecorderService()
        let data = service.stopRecording()
        #expect(data == nil)
    }

    @Test("stopRecording twice returns nil on second call")
    func doubleStop_returnsNil() {
        let service = AudioRecorderService()
        _ = service.stopRecording()
        let data = service.stopRecording()
        #expect(data == nil)
    }
}
