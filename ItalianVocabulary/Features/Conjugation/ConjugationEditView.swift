//
//  ConjugationEditView.swift
//  ItalianVocabulary
//

import SwiftUI


struct ConjugationEditView: View {
    
    let item: ConjugationVerbItem
    let tense: ConjugationTense
    
    @Environment(\.dismiss)
    private var dismiss
    
    @State private var io = ""
    @State private var tu = ""
    @State private var luiLei = ""
    @State private var noi = ""
    @State private var voi = ""
    @State private var loro = ""
    
    @State private var isSaving = false
    @State private var errorMessage: String?
    
    private let service =
    ConjugationService()
    
    
    init(
        item: ConjugationVerbItem,
        tense: ConjugationTense
    ) {
        
        self.item = item
        self.tense = tense
        
        _io = State(
            initialValue:
                item.conjugation?.io ?? ""
        )
        
        _tu = State(
            initialValue:
                item.conjugation?.tu ?? ""
        )
        
        _luiLei = State(
            initialValue:
                item.conjugation?.luiLei ?? ""
        )
        
        _noi = State(
            initialValue:
                item.conjugation?.noi ?? ""
        )
        
        _voi = State(
            initialValue:
                item.conjugation?.voi ?? ""
        )
        
        _loro = State(
            initialValue:
                item.conjugation?.loro ?? ""
        )
    }
    
    
    var body: some View {
        
        ScrollView {
            
            VStack(
                alignment: .leading,
                spacing:
                    AppTheme.Spacing.xl
            ) {
                
                verbHeader
                
                conjugationFields
                
                if let errorMessage {
                    
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
            .padding(
                .horizontal,
                AppTheme.Layout
                    .horizontalPadding
            )
            .padding(
                .top,
                AppTheme.Spacing.sm
            )
            .padding(
                .bottom,
                110
            )
        }
        .navigationTitle(
            "Edit Conjugation"
        )
        .navigationBarTitleDisplayMode(
            .inline
        )
        .safeAreaInset(
            edge: .bottom
        ) {
            
            saveArea
        }
    }
    
    
    // MARK: - Header
    
    private var verbHeader:
    some View {
        
        VStack(
            alignment: .leading,
            spacing:
                AppTheme.Spacing.xs
        ) {
            
            Text(
                item.word.italian
            )
            .font(
                .system(
                    size: 34,
                    weight: .bold,
                    design: .rounded
                )
            )
            
            
            if let english =
                item.word.english,
               !english.isEmpty {
                
                Text(english)
                    .font(.title3)
                    .foregroundStyle(
                        .secondary
                    )
            }
            
            
            if let turkish =
                item.word.turkish,
               !turkish.isEmpty {
                
                Text(turkish)
                    .font(.subheadline)
                    .foregroundStyle(
                        .secondary
                    )
            }
            
            
            Text(
                tense.title
            )
            .font(
                .caption.weight(
                    .semibold
                )
            )
            .foregroundStyle(
                .secondary
            )
            .padding(
                .top,
                AppTheme.Spacing.xs
            )
        }
    }
    
    
    // MARK: - Fields
    
    private var conjugationFields:
    some View {
        
        AppCard {
            
            VStack(
                spacing:
                    AppTheme.Spacing.md
            ) {
                
                conjugationField(
                    label: "io",
                    text: $io
                )
                
                Divider()
                
                conjugationField(
                    label: "tu",
                    text: $tu
                )
                
                Divider()
                
                conjugationField(
                    label: "lui / lei",
                    text: $luiLei
                )
                
                Divider()
                
                conjugationField(
                    label: "noi",
                    text: $noi
                )
                
                Divider()
                
                conjugationField(
                    label: "voi",
                    text: $voi
                )
                
                Divider()
                
                conjugationField(
                    label: "loro",
                    text: $loro
                )
            }
        }
    }
    
    
    private func conjugationField(
        label: String,
        text: Binding<String>
    ) -> some View {
        
        HStack(
            spacing:
                AppTheme.Spacing.md
        ) {
            
            Text(label)
                .font(
                    .headline
                )
                .frame(
                    width: 70,
                    alignment: .leading
                )
            
            
            TextField(
                "Enter form",
                text: text
            )
            .textInputAutocapitalization(
                .never
            )
            .autocorrectionDisabled()
            .multilineTextAlignment(
                .trailing
            )
        }
    }
    
    
    // MARK: - Save
    
    private var saveArea:
    some View {
        
        VStack(
            spacing: 0
        ) {
            
            Divider()
            
            
            Button {
                
                Task {
                    await save()
                }
                
            } label: {
                
                if isSaving {
                    
                    ProgressView()
                        .frame(
                            maxWidth:
                                    .infinity
                        )
                    
                } else {
                    
                    Text(
                        "Save Conjugation"
                    )
                    .fontWeight(
                        .semibold
                    )
                    .frame(
                        maxWidth:
                                .infinity
                    )
                }
            }
            .buttonStyle(
                .borderedProminent
            )
            .controlSize(
                .large
            )
            .disabled(
                isSaving
            )
            .padding(
                .horizontal,
                AppTheme.Layout
                    .horizontalPadding
            )
            .padding(
                .vertical,
                AppTheme.Spacing.md
            )
        }
        .background(
            .bar
        )
    }
    
    
    // MARK: - Save Action
    
    @MainActor
    private func save() async {
        
        isSaving = true
        errorMessage = nil
        
        defer {
            isSaving = false
        }
        
        
        do {
            
            try await service
                .saveConjugation(
                    wordId:
                        item.word.id,
                    tense:
                        tense,
                    io:
                        io,
                    tu:
                        tu,
                    luiLei:
                        luiLei,
                    noi:
                        noi,
                    voi:
                        voi,
                    loro:
                        loro
                )
            
            dismiss()
            
        } catch {
            
            errorMessage =
            error.localizedDescription
            
            print(
                "❌ Conjugation save error:",
                error
            )
        }
    }
}
