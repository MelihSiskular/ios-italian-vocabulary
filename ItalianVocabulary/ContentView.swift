import SwiftUI
internal import Auth

struct ContentView: View {
    
    @State private var email = ""
    @State private var password = ""
    
    @State private var isLoggedIn = false
    @State private var isCheckingSession = true
    @State private var isLoading = false
    
    @State private var errorMessage: String?
    
    @State private var widgetWordId: Int?
    
    private let authService = AuthService()
    
    var body: some View {
        Group {
            
            if isCheckingSession {
                
                ProgressView("Session kontrol ediliyor...")
            } else if isLoggedIn {
                
                RootTabView(
                    widgetWordId:
                        $widgetWordId
                )
            }else {
                
                loginView
            }
        }
        .task {
            
            await restoreSession()
        }
        .onOpenURL { url in
            
            handleIncomingURL(url)
        }
    }
    
    private var loginView: some View {
        NavigationStack {
            
            VStack(spacing: 20) {
                
                Spacer()
                
                VStack(spacing: 8) {
                    
                    Text("Italian Vocabulary")
                        .font(.largeTitle.bold())
                    
                    Text("Accedi per continuare")
                        .foregroundStyle(.secondary)
                }
                
                VStack(spacing: 14) {
                    
                    TextField(
                        "Email",
                        text: $email
                    )
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)
                    
                    SecureField(
                        "Password",
                        text: $password
                    )
                    .textFieldStyle(.roundedBorder)
                }
                
                if let errorMessage {
                    
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }
                
                Button {
                    Task {
                        await signIn()
                    }
                } label: {
                    
                    if isLoading {
                        
                        ProgressView()
                            .frame(maxWidth: .infinity)
                        
                    } else {
                        
                        Text("Sign In")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(
                    email.isEmpty ||
                    password.isEmpty ||
                    isLoading
                )
                
                Spacer()
            }
            .padding(24)
        }
    }
    
    @MainActor
    private func restoreSession() async {
        
        defer {
            isCheckingSession = false
        }
        
        do {
            
            let session = try await authService.currentSession()
            
            if session.isExpired {
                
                isLoggedIn = false
                
            } else {
                
                isLoggedIn = true
            }
            
        } catch {
            
            isLoggedIn = false
        }
    }
    
    @MainActor
    private func signIn() async {
        
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        do {
            
            try await authService.signIn(
                email: email,
                password: password
            )
            
            isLoggedIn = true
            
        } catch {
            
            errorMessage = error.localizedDescription
        }
    }
    
    
    // MARK: - Helper
    
    private func handleIncomingURL(
        _ url: URL
    ) {
        
        guard
            url.scheme
                == "italianvocabulary",
            
                url.host
                == "word",
            
                let wordId =
                Int(
                    url.lastPathComponent
                )
                
        else {
            
            print(
                "⚠️ Unsupported deep link:",
                url
            )
            
            return
        }
        
        widgetWordId = wordId
        
        print(
            "🔗 Widget word deep link:",
            wordId
        )
    }
}
