//
//  AIChatView.swift
//  HealthTracker
//
//  AI chat coach interface
//

import SwiftUI

struct AIChatView: View {
    @StateObject private var viewModel = AIChatViewModel()
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }

                        if viewModel.isLoading {
                            HStack {
                                ProgressView()
                                    .padding()
                                Spacer()
                            }
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) { _ in
                    if let lastMessage = viewModel.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }

            // Input bar
            HStack(spacing: 12) {
                TextField("Ask your AI coach...", text: $viewModel.currentMessage, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .focused($isTextFieldFocused)
                    .lineLimit(1...5)

                Button {
                    Task {
                        await viewModel.sendMessage()
                    }
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(viewModel.currentMessage.isEmpty ? .gray : .blue)
                }
                .disabled(viewModel.currentMessage.isEmpty || viewModel.isLoading)
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .navigationTitle("AI Coach")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.clearChat()
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .sheet(isPresented: $viewModel.showPaywall) {
            PaywallView()
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isUser {
                Spacer(minLength: 50)
            }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.body)
                    .foregroundColor(message.isUser ? .white : .primary)
                    .padding(12)
                    .background(message.isUser ? Color.blue : Color(.secondarySystemBackground))
                    .cornerRadius(16)

                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            if !message.isUser {
                Spacer(minLength: 50)
            }
        }
    }
}

#Preview {
    NavigationView {
        AIChatView()
    }
}
