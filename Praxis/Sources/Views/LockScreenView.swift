import SwiftUI

struct LockScreenView: View {
    let onUnlock: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "lock.shield.fill")
                .font(.system(size: 64))
                .foregroundStyle(.accent)

            Text("Praxis")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Tap to unlock")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Button(action: onUnlock) {
                Label("Unlock", systemImage: "faceid")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.accent)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
}
