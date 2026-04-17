import SwiftUI

// MARK: - Model

private struct OnboardingStep: Identifiable {
    let id: Int
    let systemImage: String
    let title: String
    let body: String
}

private let steps: [OnboardingStep] = [
    OnboardingStep(
        id: 0,
        systemImage: "bookmark.fill",
        title: "Welcome to Save4Later",
        body: "Your personal collection for links, recipes, places, and anything worth coming back to."
    ),
    OnboardingStep(
        id: 1,
        systemImage: "plus.circle.fill",
        title: "Save Your First Item",
        body: "Tap the + button in the top-right corner to add a link, recipe, place, or any item you want to revisit."
    ),
    OnboardingStep(
        id: 2,
        systemImage: "square.and.arrow.up",
        title: "Share from Any App",
        body: "Found something while browsing? Use the Share button in Safari or any app, then tap Save4Later to save it instantly."
    ),
]

// MARK: - View

struct OnboardingView: View {
    /// Called when the user dismisses the tour.
    var onFinish: () -> Void

    @State private var currentStep = 0

    private var isLastStep: Bool { currentStep == steps.count - 1 }

    var body: some View {
        ZStack {
            Color.s4lBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // ── Paged card area ──────────────────────────────────────────
                TabView(selection: $currentStep) {
                    ForEach(steps) { step in
                        StepCard(step: step)
                            .tag(step.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 380)

                // ── Page dots ────────────────────────────────────────────────
                HStack(spacing: 8) {
                    ForEach(steps.indices, id: \.self) { i in
                        Capsule()
                            .fill(i == currentStep ? Color.s4lAccent : Color.s4lAccent.opacity(0.25))
                            .frame(width: i == currentStep ? 22 : 8, height: 8)
                            .animation(.spring(response: 0.35), value: currentStep)
                    }
                }
                .padding(.top, 24)

                Spacer()

                // ── Action buttons ───────────────────────────────────────────
                VStack(spacing: 12) {
                    Button {
                        if isLastStep {
                            onFinish()
                        } else {
                            withAnimation { currentStep += 1 }
                        }
                    } label: {
                        Text(isLastStep ? "Get Started" : "Next")
                            .font(.custom("OpenSans-Regular", size: 17))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .background(
                                LinearGradient(
                                    colors: [Color.s4lAccent, Color.s4lAccent.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    if !isLastStep {
                        Button("Skip") {
                            onFinish()
                        }
                        .font(.custom("OpenSans-Regular", size: 15))
                        .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 48)
            }
        }
    }
}

// MARK: - Step card

private struct StepCard: View {
    let step: OnboardingStep

    var body: some View {
        VStack(spacing: 28) {
            ZStack {
                Circle()
                    .fill(Color.s4lAccent.opacity(0.12))
                    .frame(width: 110, height: 110)
                Image(systemName: step.systemImage)
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundColor(Color.s4lAccent)
            }

            VStack(spacing: 12) {
                Text(step.title)
                    .font(.custom("OpenSans-Regular", size: 24))
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(step.body)
                    .font(.custom("OpenSans-Regular", size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
            }
        }
        .padding(.top, 8)
    }
}

// MARK: - Preview

#Preview {
    OnboardingView(onFinish: {})
        .font(.custom("OpenSans-Regular", size: 16))
}
