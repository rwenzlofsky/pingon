import SwiftUI

struct ContentView: View {
    @State private var serverAddress: String = "1.1.1.1"
    @StateObject private var pingManager = PingManager()
    @StateObject private var tailscaleManager = TailscaleManager()
    
    // Track the currently selected client IP for pinging
    @State private var selectedClientIP: String? = nil
    
    // Define grid layout with flexible columns
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: 20) {
    
            
            Text("Pinging: \(pingManager.currentHost.isEmpty ? "None" : pingManager.currentHost)")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding()

            // Display latency with large font and animated mechanical clock effect
            Text(pingManager.pingResult)
                .font(.system(size: 72, weight: .bold, design: .monospaced)) // Larger, monospaced font
                .transition(.asymmetric(insertion: .scale, removal: .opacity)) // Scale and fade effects
                .animation(.easeInOut(duration: 0.3), value: pingManager.pingResult) // Smooth animation
                .padding()
            
            // Client Count Debugging
            Text("Number of clients: \(tailscaleManager.clients.count)")
                .padding()
            
            // Grid of Client Buttons
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(tailscaleManager.clients) { client in
                        Button(action: {
                            if selectedClientIP == client.ipAddress {
                                // If the selected client IP is already being pinged, stop pinging
                                pingManager.stopPing()
                                selectedClientIP = nil
                            } else {
                                // Stop any ongoing ping before switching to a new client
                                pingManager.stopPing()
                                pingManager.startPing(host: client.ipAddress)
                                selectedClientIP = client.ipAddress
                            }
                        }) {
                            Text(client.hostname)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(selectedClientIP == client.ipAddress ? Color.red : Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }
            .frame(maxHeight: 400)  // Adjust grid height as needed
            
            Spacer()
        }
        .padding()
        .frame(minWidth: 500, minHeight: 600)  // Set the minimum window size
        .onAppear {
            tailscaleManager.fetchClients()  // Load clients on app start
        }
    }
}
