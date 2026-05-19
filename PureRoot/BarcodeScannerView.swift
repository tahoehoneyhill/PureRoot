//
//  BarcodeScannerView.swift
//  PureRoot
//

import SwiftUI

#if os(iOS)
import Vision
import VisionKit

struct BarcodeScannerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var manualCode: String = ""
    let onCode: (String) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                    BarcodeCameraView { code in
                        onCode(code)
                        dismiss()
                    }
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "barcode.viewfinder")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text("Camera scanning isn't available on this device.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        Text("(Simulator has no real camera — enter a barcode manually below.)")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.05))
                }

                VStack(spacing: 10) {
                    Text("Or enter barcode manually")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack {
                        TextField("e.g. 028400090001", text: $manualCode)
                            .keyboardType(.numberPad)
                            .padding(10)
                            .background(Color.prInputField)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        Button("Look up") {
                            let trimmed = manualCode.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmed.isEmpty else { return }
                            onCode(trimmed)
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        .disabled(manualCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                .padding()
            }
            .navigationTitle("Scan Barcode")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

private struct BarcodeCameraView: UIViewControllerRepresentable {
    let onCode: (String) -> Void

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.barcode(symbologies: [.ean13, .ean8, .upce, .code128, .code39, .code93])],
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: false,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        try? uiViewController.startScanning()
    }

    func makeCoordinator() -> Coordinator { Coordinator(onCode: onCode) }

    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let onCode: (String) -> Void
        var handled = false

        init(onCode: @escaping (String) -> Void) { self.onCode = onCode }

        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            guard !handled, let first = addedItems.first else { return }
            if case .barcode(let barcode) = first, let payload = barcode.payloadStringValue {
                handled = true
                dataScanner.stopScanning()
                onCode(payload)
            }
        }
    }
}

#else
struct BarcodeScannerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var manualCode: String = ""
    let onCode: (String) -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Barcode scanning is iOS only.")
                .font(.subheadline)
            HStack {
                TextField("Enter barcode", text: $manualCode)
                Button("Look up") {
                    onCode(manualCode)
                    dismiss()
                }
                .disabled(manualCode.isEmpty)
            }
            Button("Cancel") { dismiss() }
        }
        .padding()
        .frame(minWidth: 360, minHeight: 240)
    }
}
#endif
