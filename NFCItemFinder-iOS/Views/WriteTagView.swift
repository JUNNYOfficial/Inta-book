import SwiftUI

struct WriteTagView: View {
    @EnvironmentObject var nfcManager: NFCManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: nfcManager.isScanning ? "wave.3.right" : "checkmark.circle")
                    .font(.system(size: 80))
                    .foregroundColor(nfcManager.isScanning ? .blue : .green)
                    .opacity(nfcManager.isScanning ? 0.5 : 1.0)
                    .scaleEffect(nfcManager.isScanning ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: nfcManager.isScanning)

                Text(nfcManager.isScanning ? "请将手机靠近 NFC 标签" : "写入完成")
                    .font(.title2)
                    .bold()

                Text(nfcManager.statusMessage)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                if case .error(let msg) = nfcManager.lastResult {
                    Text(msg)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }

                Spacer()

                Button(action: { dismiss() }) {
                    Text("完成")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("写入标签")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
