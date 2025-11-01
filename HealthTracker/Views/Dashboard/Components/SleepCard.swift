//
//  SleepCard.swift
//  HealthTracker
//
//  Sleep metric card
//

import SwiftUI

struct SleepCard: View {
    let sleep: SleepEntry?

    var body: some View {
        if let sleepEntry = sleep {
            MetricCard(
                icon: "bed.double.fill",
                title: "Sleep",
                value: sleepEntry.displayDuration,
                unit: "",
                color: .indigo,
                status: sleepEntry.status.rawValue
            )
        } else {
            EmptyMetricCard(
                icon: "bed.double.fill",
                title: "Sleep",
                color: .indigo
            )
        }
    }
}

#Preview {
    VStack {
        SleepCard(sleep: SleepEntry(
            bedTime: Calendar.current.date(byAdding: .hour, value: -8, to: Date())!,
            wakeTime: Date()
        ))
        SleepCard(sleep: nil)
    }
    .padding()
}
