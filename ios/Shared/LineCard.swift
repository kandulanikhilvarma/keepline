import SwiftUI
import KeeplineCore

struct LineCard: View {
    let line: Line?
    var failure = false
    @Environment(\.colorScheme) private var scheme
    private var ink: Color { scheme == .dark ? Color(red: 0.91, green: 0.91, blue: 0.83) : Color(red: 0.13, green: 0.23, blue: 0.19) }
    static let paper = Color(red: 0.94, green: 0.93, blue: 0.87)

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(line?.period.title ?? "Keepline").font(.caption.weight(.medium))
                Spacer()
                Image(systemName: "line.3.horizontal").accessibilityHidden(true)
            }
            Spacer(minLength: 0)
            Text(line?.text ?? (failure ? "Open Keepline to restore your lines." : "Your words belong here."))
                .font(.system(.title2, design: .serif).weight(.medium))
                .minimumScaleFactor(0.65).lineLimit(4)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer(minLength: 0)
            Text(line == nil ? (failure ? "Shared storage needs attention" : "Save a line in Keepline") : "Keep it in sight.")
                .font(.caption)
        }
        .foregroundStyle(ink)
        .accessibilityElement(children: .combine)
    }
}
