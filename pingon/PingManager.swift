import Foundation
import Combine

/// Manages simultaneous pings for multiple clients.
class MultiPingManager: ObservableObject {
    @Published var pingResults: [String: [Int]] = [:]  // Dictionary to store arrays of ping results for each client
    @Published var isPingingAll: Bool = false           // Tracks whether all clients are being pinged
    
    private var pingTimers: [String: Timer] = [:]       // Dictionary to hold a timer for each client
    
    /// Starts pinging all specified hosts by creating a timer for each client.
    func startPingAll(clients: [TailscaleClient]) {
        stopPingAll()  // Stop any existing pings first
        
        // Set up individual timers for each client
        for client in clients {
            let clientID = client.ipAddress
            self.pingResults[clientID] = []  // Initialize empty array for each client
            
            // Schedule a timer for each client to ping every 1.5 seconds
            pingTimers[clientID] = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] timer in
                guard let self = self else {
                    timer.invalidate()
                    return
                }
                
                // Simulate a round-trip time (RTT) in milliseconds
                let rtt = Int.random(in: 20...100)
                
                // Append RTT to the ping results array, keeping only the last 15 results
                self.pingResults[clientID, default: []].append(rtt)
                if self.pingResults[clientID]?.count ?? 0 > 15 {
                    self.pingResults[clientID]?.removeFirst()
                }
                
                print("Ping to \(clientID): RTT = \(rtt) ms")
            }
        }
        
        isPingingAll = true
    }
    
    /// Stops pinging all clients by invalidating all timers and clearing results.
    func stopPingAll() {
        for timer in pingTimers.values {
            timer.invalidate()
        }
        pingTimers.removeAll()
        isPingingAll = false
        
        // Set all results to an empty array
        for clientID in pingResults.keys {
            pingResults[clientID] = []
        }
    }
    
    deinit {
        stopPingAll()
    }
}
