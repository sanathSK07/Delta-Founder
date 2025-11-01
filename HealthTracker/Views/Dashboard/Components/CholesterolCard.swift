//
//  CholesterolCard.swift
//  HealthTracker
//
//  Cholesterol metric card
//

import SwiftUI

struct CholesterolCard: View {
    let cholesterol: Cholesterol?

    var body: some View {
        if let chol = cholesterol {
            MetricCard(
                icon: "waveform.path.ecg",
                title: "Cholesterol",
                value: String(format: "%.0f", chol.totalCholesterol),
                unit: "mg/dL",
                color: .purple,
                status: chol.totalCholesterolStatus.rawValue
            )
        } else {
            EmptyMetricCard(
                icon: "waveform.path.ecg",
                title: "Cholesterol",
                color: .purple
            )
        }
    }
}

#Preview {
    VStack {
        CholesterolCard(cholesterol: Cholesterol(totalCholesterol: 180))
        CholesterolCard(cholesterol: nil)
    }
    .padding()
}
