//
//  AuthenticationView.swift
//  HealthTrackAI
//
//  Sign in view for returning users
//

import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var showingAlert = false

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // Logo
            Image(systemName: "heart.text.square.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)

            Text("Welcome Back")
                .font(.largeTitle)
                .bold()

            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.horizontal, 40)

            Button(action: signIn) {
                if authViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Sign In")
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(email.isEmpty || password.isEmpty ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.horizontal, 40)
            .disabled(email.isEmpty || password.isEmpty || authViewModel.isLoading)

            Spacer()
        }
        .alert("Sign In Failed", isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(authViewModel.errorMessage ?? "Unknown error")
        }
    }

    private func signIn() {
        Task {
            await authViewModel.signIn(email: email, password: password)

            if !authViewModel.isAuthenticated {
                showingAlert = true
            }
        }
    }
}
