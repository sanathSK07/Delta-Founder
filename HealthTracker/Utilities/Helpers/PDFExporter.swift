//
//  PDFExporter.swift
//  HealthTracker
//
//  PDF export utility for health reports
//

import Foundation
import UIKit
import PDFKit

class PDFExporter {
    static let shared = PDFExporter()

    private init() {}

    // MARK: - Generate Health Report

    func generateHealthReport(
        user: User?,
        bloodSugar: [BloodSugar],
        bloodPressure: [BloodPressure],
        cholesterol: [Cholesterol],
        foodEntries: [FoodEntry]
    ) -> Data {
        let pageSize = CGRect(x: 0, y: 0, width: 612, height: 792) // US Letter size
        let renderer = UIGraphicsPDFRenderer(bounds: pageSize)

        let data = renderer.pdfData { context in
            context.beginPage()

            var yPosition: CGFloat = 60

            // Title
            yPosition = drawTitle("Health Report", at: yPosition, in: pageSize)
            yPosition += 20

            // Date
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            yPosition = drawText(
                "Generated on \(dateFormatter.string(from: Date()))",
                at: yPosition,
                fontSize: 12,
                color: .gray,
                in: pageSize
            )
            yPosition += 30

            // User Profile
            if let user = user {
                yPosition = drawSectionHeader("Profile", at: yPosition, in: pageSize)
                yPosition = drawText("Name: \(user.name)", at: yPosition, in: pageSize)
                yPosition = drawText("Age: \(user.age) years", at: yPosition, in: pageSize)
                yPosition = drawText(
                    "Weight: \(String(format: "%.1f", user.weight)) \(user.weightUnit.rawValue)",
                    at: yPosition,
                    in: pageSize
                )
                yPosition = drawText(
                    "Height: \(String(format: "%.1f", user.height)) \(user.heightUnit.rawValue)",
                    at: yPosition,
                    in: pageSize
                )
                yPosition += 20
            }

            // Blood Sugar Summary
            if !bloodSugar.isEmpty {
                yPosition = drawSectionHeader("Blood Glucose", at: yPosition, in: pageSize)
                let avgBS = bloodSugar.map { $0.value }.reduce(0, +) / Double(bloodSugar.count)
                yPosition = drawText(
                    "Average: \(String(format: "%.0f", avgBS)) mg/dL",
                    at: yPosition,
                    in: pageSize
                )
                yPosition = drawText("Total Readings: \(bloodSugar.count)", at: yPosition, in: pageSize)
                yPosition += 20
            }

            // Blood Pressure Summary
            if !bloodPressure.isEmpty {
                yPosition = drawSectionHeader("Blood Pressure", at: yPosition, in: pageSize)
                let avgSystolic = bloodPressure.map { Double($0.systolic) }.reduce(0, +) / Double(bloodPressure.count)
                let avgDiastolic = bloodPressure.map { Double($0.diastolic) }.reduce(0, +) / Double(bloodPressure.count)
                yPosition = drawText(
                    "Average: \(Int(avgSystolic))/\(Int(avgDiastolic)) mmHg",
                    at: yPosition,
                    in: pageSize
                )
                yPosition = drawText("Total Readings: \(bloodPressure.count)", at: yPosition, in: pageSize)
                yPosition += 20
            }

            // Cholesterol Summary
            if !cholesterol.isEmpty {
                yPosition = drawSectionHeader("Cholesterol", at: yPosition, in: pageSize)
                let avgTotal = cholesterol.map { $0.totalCholesterol }.reduce(0, +) / Double(cholesterol.count)
                yPosition = drawText(
                    "Average Total: \(String(format: "%.0f", avgTotal)) mg/dL",
                    at: yPosition,
                    in: pageSize
                )
                yPosition = drawText("Total Readings: \(cholesterol.count)", at: yPosition, in: pageSize)
                yPosition += 20
            }

            // Nutrition Summary
            if !foodEntries.isEmpty {
                yPosition = drawSectionHeader("Nutrition", at: yPosition, in: pageSize)
                let totalCalories = foodEntries.reduce(0) { $0 + $1.calories }
                let avgCalories = totalCalories / Double(foodEntries.count)
                yPosition = drawText(
                    "Average Daily Calories: \(String(format: "%.0f", avgCalories))",
                    at: yPosition,
                    in: pageSize
                )
                yPosition = drawText("Total Meals Logged: \(foodEntries.count)", at: yPosition, in: pageSize)
                yPosition += 20
            }

            // Disclaimer
            yPosition = pageSize.height - 100
            yPosition = drawSectionHeader("Important Notice", at: yPosition, in: pageSize)
            yPosition = drawText(
                "This report is for informational purposes only and should not replace professional medical advice. Always consult with your healthcare provider regarding your health.",
                at: yPosition,
                fontSize: 10,
                color: .gray,
                in: pageSize,
                width: pageSize.width - 120
            )
        }

        return data
    }

    // MARK: - Drawing Helpers

    private func drawTitle(_ text: String, at yPosition: CGFloat, in pageSize: CGRect) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 24),
            .foregroundColor: UIColor.black
        ]

        let textRect = CGRect(
            x: 60,
            y: yPosition,
            width: pageSize.width - 120,
            height: 40
        )

        text.draw(in: textRect, withAttributes: attributes)
        return yPosition + 40
    }

    private func drawSectionHeader(_ text: String, at yPosition: CGFloat, in pageSize: CGRect) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor.black
        ]

        let textRect = CGRect(
            x: 60,
            y: yPosition,
            width: pageSize.width - 120,
            height: 30
        )

        text.draw(in: textRect, withAttributes: attributes)
        return yPosition + 30
    }

    private func drawText(
        _ text: String,
        at yPosition: CGFloat,
        fontSize: CGFloat = 14,
        color: UIColor = .black,
        in pageSize: CGRect,
        width: CGFloat? = nil
    ) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: fontSize),
            .foregroundColor: color
        ]

        let textWidth = width ?? (pageSize.width - 120)
        let textRect = CGRect(
            x: 60,
            y: yPosition,
            width: textWidth,
            height: 1000 // Large height to allow multi-line
        )

        let attributedText = NSAttributedString(string: text, attributes: attributes)
        let textSize = attributedText.boundingRect(
            with: CGSize(width: textWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )

        text.draw(in: textRect, withAttributes: attributes)
        return yPosition + textSize.height + 10
    }
}
