import SwiftUI

struct ClientRowView: View {
    let client: Client

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(client.name)
                .font(.headline)

            if let lastSession = client.pastSessions.first {
                Text("Last session: \(lastSession.date, format: .relative(presentation: .named))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("No sessions yet")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
