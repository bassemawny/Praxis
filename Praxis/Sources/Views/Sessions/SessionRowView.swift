import SwiftUI

struct SessionRowView: View {
    let session: Session

    var body: some View {
        HStack {
            Circle()
                .fill(session.status.color)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
                Text(session.date, format: .dateTime.month().day().year().hour().minute())
                    .font(.subheadline)

                HStack(spacing: 8) {
                    Text(session.status.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let template = session.templateType {
                        Text(template.displayName)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 1)
                            .background(.accent.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 2)
    }
}

extension SessionStatus {
    var color: Color {
        switch self {
        case .upcoming: return .blue
        case .completed: return .green
        case .cancelled: return .gray
        case .noShow: return .red
        }
    }
}
