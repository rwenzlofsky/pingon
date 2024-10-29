import SwiftUI

// Test 2

class PingManager: NSObject, ObservableObject {
    @Published var pingResult: String = ""
    @Published var currentHost: String = ""
    @Published var isPinging: Bool = false

    private var simplePing: SimplePing?
    private var sendTime: Date?
    private var pingTimer: DispatchSourceTimer?
    private var pingTimeoutTimer: DispatchSourceTimer?

    func startPing(host: String) {
        guard !isPinging else { return }

        print("Starting ICMP ping for host:", host)
        currentHost = host
        isPinging = true
        pingResult = "Pinging..."

        simplePing = SimplePing(hostName: host)
        simplePing?.delegate = self
        simplePing?.start()
    }

    func stopPing() {
        guard isPinging else { return }

        simplePing?.stop()
        simplePing = nil
        isPinging = false
        sendTime = nil
        pingResult = "Ping stopped"
        currentHost = ""
        pingTimer?.cancel()
        pingTimer = nil
        pingTimeoutTimer?.cancel()
        pingTimeoutTimer = nil
        print("Pinging stopped manually")
    }

    private func startPingTimer() {
        pingTimer?.cancel()
        pingTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        pingTimer?.schedule(deadline: .now(), repeating: 1.0)
        pingTimer?.setEventHandler { [weak self] in
            self?.sendPing()
        }
        pingTimer?.resume()
    }

    private func sendPing() {
        guard let simplePing = simplePing, isPinging else { return }

        if simplePing.hostAddress == nil {
            print("No host address, restarting SimplePing")
            simplePing.stop()
            simplePing.start()
            return
        }

        simplePing.send(with: nil)
        sendTime = Date()
        startPingTimeoutTimer()
    }

    private func startPingTimeoutTimer() {
        pingTimeoutTimer?.cancel()
        pingTimeoutTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        pingTimeoutTimer?.schedule(deadline: .now() + 1.0)
        pingTimeoutTimer?.setEventHandler { [weak self] in
            self?.handlePingTimeout()
        }
        pingTimeoutTimer?.resume()
    }

    private func handlePingTimeout() {
        guard isPinging else { return }
        DispatchQueue.main.async {
            self.pingResult = "Ping timeout (no response)"
        }
        print("Ping timeout occurred")
    }
}

extension PingManager: SimplePingDelegate {
    func simplePing(_ pinger: SimplePing, didStartWithAddress address: Data) {
        print("SimplePing started with address:", address)
        startPingTimer()
        sendPing()
    }

    func simplePing(_ pinger: SimplePing, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.pingResult = "Ping failed: \(error.localizedDescription)"
        }
        print("SimplePing error:", error.localizedDescription)
        stopPing()
    }

    func simplePing(_ pinger: SimplePing, didSendPacket packet: Data, sequenceNumber: UInt16) {
        print("Ping sent: Sequence \(sequenceNumber)")
        sendTime = Date()
    }

    func simplePing(_ pinger: SimplePing, didReceivePingResponsePacket packet: Data, sequenceNumber: UInt16) {
        pingTimeoutTimer?.cancel()
        pingTimeoutTimer = nil

        guard let sendTime = sendTime, isPinging else {
            print("Received response but send time is missing or pinging has stopped")
            return
        }

        let roundTripTime = Date().timeIntervalSince(sendTime) * 1000  // milliseconds
        DispatchQueue.main.async {
            self.pingResult = String(format: "Ping response: %.2f ms", roundTripTime)
        }
        print("Ping response received: Sequence \(sequenceNumber), Round-trip time: \(roundTripTime) ms")
    }

    func simplePing(_ pinger: SimplePing, didFailToSendPacket packet: Data, sequenceNumber: UInt16, error: Error) {
        pingTimeoutTimer?.cancel()
        pingTimeoutTimer = nil
        DispatchQueue.main.async {
            self.pingResult = "Ping failed to send: \(error.localizedDescription)"
        }
        print("Failed to send ping: Sequence \(sequenceNumber) - Error:", error.localizedDescription)
    }
}
