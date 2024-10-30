import SwiftUI

struct ContentView: View {
    @StateObject private var pingManager = MultiPingManager()
    @StateObject private var tailscaleManager = TailscaleManager()
    
    var body: some View {
        VStack(spacing: 20) {
            // List of Clients with Individual Ping Results and Bar Charts
            List(tailscaleManager.clients) { client in
                HStack(spacing: 10) { // Reduced spacing between items
                    // Client name
                    Text(client.hostname)
                        .font(.headline)
                    
                    Spacer()
                    
                    // Bar chart showing last 15 ping results for each client
                    if let pings = pingManager.pingResults[client.ipAddress] {
                        PingBarChart(pingResults: pings)
                            .frame(width: 150, height: 20)
                    } else {
                        Text("No data")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    // Display the latest ping result in milliseconds after the bar chart, with animation
                    Text("\(pingManager.pingResults[client.ipAddress]?.last ?? 0) ms")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .transition(.scale) // Scale effect for smooth entry
                        .animation(.easeInOut(duration: 0.3), value: pingManager.pingResults[client.ipAddress]?.last) // Animate on change
                }
                .padding(.vertical, 5)  // Decrease vertical padding for each list item
            }
            .frame(maxHeight: 400)  // Adjust list height as needed
            
            // Simplified Start/Stop All Pings Button
            Button(action: {
                if pingManager.isPingingAll {
                    pingManager.stopPingAll()
                } else {
                    pingManager.startPingAll(clients: tailscaleManager.clients)
                }
            }) {
                Text(pingManager.isPingingAll ? "Stop" : "Start")
                    .font(.body)
                    .padding(5) // Smaller padding for a compact look
            }
            .buttonStyle(.bordered) // Simple bordered button style
            .padding(.top, 10) // Small padding above button

            Spacer()
        }
        .padding()
        .frame(minWidth: 500, minHeight: 600)
        .onAppear {
            tailscaleManager.fetchClients()
        }
    }
}
