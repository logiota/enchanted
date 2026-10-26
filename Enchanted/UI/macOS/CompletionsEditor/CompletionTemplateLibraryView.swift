//
//  CompletionTemplateLibraryView.swift
//  Enchanted
//

#if os(macOS)
import SwiftUI

struct CompletionTemplateLibraryView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var completions: [CompletionInstructionSD]
    var onSave: () -> ()

    @State private var searchText = ""
    @State private var category: CompletionTemplate.Category?
    @State private var selectedTemplateId: CompletionTemplate.ID? = CompletionTemplate.all.first?.id

    private var filteredTemplates: [CompletionTemplate] {
        CompletionTemplate.all.filter { template in
            guard category == nil || template.category == category else { return false }
            guard !searchText.isEmpty else { return true }
            return template.name.localizedCaseInsensitiveContains(searchText) || template.task.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var sections: [(category: CompletionTemplate.Category, templates: [CompletionTemplate])] {
        let templates = filteredTemplates
        return CompletionTemplate.Category.allCases.compactMap { category in
            let categoryTemplates = templates.filter { $0.category == category }
            return categoryTemplates.isEmpty ? nil : (category, categoryTemplates)
        }
    }

    private var selectedTemplate: CompletionTemplate? {
        CompletionTemplate.all.first { $0.id == selectedTemplateId }
    }

    private var usedKeys: Set<String> {
        Set(completions.map { $0.keyboardCharacter.lowercased() })
    }

    private func addedCompletion(for template: CompletionTemplate) -> CompletionInstructionSD? {
        completions.first { $0.instruction == template.instruction }
    }

    private func add(_ template: CompletionTemplate) {
        guard addedCompletion(for: template) == nil else { return }
        let completion = CompletionInstructionSD(
            name: template.name,
            keyboardCharacterStr: template.availableKey(excluding: usedKeys),
            instruction: template.instruction,
            order: completions.count,
            modelTemperature: template.temperature
        )
        withAnimation {
            completions.append(completion)
        }
        onSave()
    }

    private func close() {
        presentationMode.wrappedValue.dismiss()
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Text("Template Library")
                    .font(.title)
                    .fontWeight(.thin)
                    .enchantify()
                    .padding(.bottom, 30)

                Spacer()

                Button(action: close) {
                    Text("Close")
                }
                .buttonStyle(GrowingButton())
            }

            Text("\(CompletionTemplate.all.count) ready-made completions for everyday tasks. Add the ones you use to your completions panel, then edit them like any other completion.")
                .padding(.bottom, 10)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                TextField("Search templates", text: $searchText)
                    .textFieldStyle(.roundedBorder)

                Picker("Category", selection: $category) {
                    Text("All Categories").tag(CompletionTemplate.Category?.none)
                    Divider()
                    ForEach(CompletionTemplate.Category.allCases) { category in
                        Label(category.rawValue, systemImage: category.systemImage)
                            .tag(Optional(category))
                    }
                }
                .labelsHidden()
                .frame(width: 220)
            }
            .padding(.bottom, 10)

            HStack(alignment: .top, spacing: 16) {
                templateList
                    .frame(width: 380)

                templateDetail
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
        .padding()
        .frame(width: 860, height: 620)
    }

    private var templateList: some View {
        List(selection: $selectedTemplateId) {
            ForEach(sections, id: \.category) { section in
                Section(section.category.rawValue) {
                    ForEach(section.templates) { template in
                        TemplateRow(
                            template: template,
                            isAdded: addedCompletion(for: template) != nil,
                            onAdd: { add(template) }
                        )
                        .tag(template.id)
                    }
                }
            }
        }
        .overlay {
            if filteredTemplates.isEmpty {
                ContentUnavailableView.search(text: searchText)
            }
        }
    }

    @ViewBuilder
    private var templateDetail: some View {
        if let template = selectedTemplate {
            let added = addedCompletion(for: template)

            VStack(alignment: .leading, spacing: 12) {
                Label(template.category.rawValue, systemImage: template.category.systemImage)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(template.name)
                    .font(.title2)

                HStack(spacing: 12) {
                    CompletionButtonView(
                        name: template.name,
                        keyboardCharacter: added?.keyboardCharacter ?? Character(template.availableKey(excluding: usedKeys)),
                        action: {}
                    )

                    Text("Temperature \(String(format: "%.1f", template.temperature))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                ScrollView {
                    Text(template.instruction)
                        .font(.system(.callout, design: .monospaced))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                }
                .background(RoundedRectangle(cornerRadius: 5).fill(Color.gray.opacity(0.1)))

                Text("The selected text replaces {{text}} when the completion runs. You can edit the prompt after adding it.")
                    .font(.caption)
                    .foregroundColor(.gray)

                HStack {
                    Spacer()

                    Button(action: { add(template) }) {
                        Text(added == nil ? "Add to Completions" : "Added")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(added != nil)
                }
            }
        } else {
            ContentUnavailableView("Select a Template", systemImage: "text.badge.plus")
        }
    }
}

private struct TemplateRow: View {
    var template: CompletionTemplate
    var isAdded: Bool
    var onAdd: () -> ()

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(template.name)

                Text(template.task)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            if isAdded {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.accentColor)
                    .help("Added to your completions")
            } else {
                Button(action: onAdd) {
                    Image(systemName: "plus.circle")
                }
                .buttonStyle(GrowingButton())
                .help("Add to your completions")
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    CompletionTemplateLibraryView(completions: .constant(CompletionInstructionSD.samples), onSave: {})
}
#endif
