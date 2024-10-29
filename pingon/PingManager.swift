import Foundation
import Combine

class PingManager: ObservableObject {
    @Published var pingResult: String = ""       // Holds the latency result in milliseconds
    @Published var isPinging: Bool = false       // Tracks whether a ping is ongoing
    var currentHost: String = ""                 // Stores the currently pinged host
    private var pingTimer: Timer?                // Timer to manage repeated ping calls
    private var stopPingDelay: DispatchWorkItem? // Delayed work item for setting "Ping stopped"
    
    // Start pinging a given host
    func startPing(host: String) {
        stopPing(updateResult: false)  // Stop any ongoing ping without clearing result immediately
        
        self.currentHost = host
        self.isPinging = true
        
        // Start a timer to simulate pinging every second
        pingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            guard self.isPinging else {
                timer.invalidate()
                return
            }
            
            // Simulate round-trip time (RTT) for the ping in milliseconds, formatted as an integer
            let rtt = Int(Double.random(in: 20...100))  // Replace with actual RTT calculation if available
            self.pingResult = "\(rtt) ms"  // Update ping result without decimals
            print("Ping to \(host): RTT = \(rtt) ms")
        }
    }
    
    // Stop the current ping with an option to delay the "Ping stopped" result
    func stopPing(updateResult: Bool = true) {
        pingTimer?.invalidate()  // Invalidate the timer to stop further pings
        pingTimer = nil
        isPinging = false
        
        // Cancel any previous delayed work
        stopPingDelay?.cancel()
        
        if updateResult {
            // Create a delayed task to update `pingResult` if no new ping starts
            stopPingDelay = DispatchWorkItem { [weak self] in
                self?.pingResult = "Ping stopped"
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: stopPingDelay!)
        }
    }
}
