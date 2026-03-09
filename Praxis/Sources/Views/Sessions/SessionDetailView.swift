import SwiftUI
import SwiftData
import PhotosUI

struct SessionDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var session: Session
    @State private var showingImagePicker = false
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddReminder = false
    @State private var showingDeleteConfirmation = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isRecording = false
    @State private var showingMicPermissionAlert = false

    @State private var audioRecorder = AudioRecorderService()

    var body: some View {
        List {
            Section("Status") {
                Picker("Status", selection: $session.status) {
                    ForEach(SessionStatus.allCases) { status in
                        Text(status.displayName).tag(status)
                    }
                }
            }

            Section("Notes") {
                if session.noteContent == nil {
                    HStack {
                        Text("Start with a template:")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Menu {
                            Button("Free Text") {
                                session.noteContent = ""
                            }
                            ForEach(NoteTemplate.allCases) { template in
                                Button(template.displayName) {
                                    session.noteContent = template.templateContent
                                    session.templateType = template
                                }
                            }
                        } label: {
                            Label("Add Notes", systemImage: "plus")
                        }
                    }
                } else {
                    TextEditor(text: Binding(
                        get: { session.noteContent ?? "" },
                        set: { session.noteContent = $0 }
                    ))
                    .frame(minHeight: 200)
                }
            }

            Section("Attachments") {
                ForEach(session.attachments) { attachment in
                    AttachmentRowView(attachment: attachment)
                }
                .onDelete(perform: deleteAttachments)

                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Label("Add Image", systemImage: "photo")
                }

                Button {
                    toggleRecording()
                } label: {
                    Label(
                        isRecording ? "Stop Recording" : "Record Voice Note",
                        systemImage: isRecording ? "stop.circle.fill" : "mic.circle"
                    )
                    .foregroundStyle(isRecording ? .red : .accent)
                }
            }
            .onChange(of: selectedPhoto) { _, newValue in
                if let newValue {
                    loadImage(from: newValue)
                }
            }
            .onChange(of: audioRecorder.permissionDenied) { _, denied in
                if denied {
                    isRecording = false
                    showingMicPermissionAlert = true
                    audioRecorder.permissionDenied = false
                }
            }
            .alert("Microphone Access", isPresented: $showingMicPermissionAlert) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Praxis needs microphone access to record voice notes. Enable it in Settings.")
            }

            Section("Reminders") {
                ForEach(session.reminders) { reminder in
                    ReminderRowView(reminder: reminder)
                }

                Button {
                    showingAddReminder = true
                } label: {
                    Label("Add Reminder", systemImage: "plus")
                }
            }
        }
        .navigationTitle(session.date.formatted(.dateTime.month().day().year()))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .alert("Delete Session", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                modelContext.delete(session)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete this session and all its notes, attachments, and reminders.")
        }
        .sheet(isPresented: $showingAddReminder) {
            AddReminderView(client: session.client, session: session)
        }
    }

    private func toggleRecording() {
        if isRecording {
            if let data = audioRecorder.stopRecording() {
                let attachment = Attachment(
                    type: .voiceNote,
                    fileName: "voice_\(Date.now.ISO8601Format()).m4a",
                    data: data,
                    session: session
                )
                modelContext.insert(attachment)
            }
        } else {
            audioRecorder.startRecording()
        }
        isRecording.toggle()
    }

    private func deleteAttachments(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(session.attachments[index])
        }
    }

    private func loadImage(from item: PhotosPickerItem) {
        Task {
            guard let data = try? await item.loadTransferable(type: Data.self) else { return }
            let attachment = Attachment(
                type: .image,
                fileName: "image_\(Date.now.ISO8601Format()).jpg",
                data: data,
                session: session
            )
            modelContext.insert(attachment)
            selectedPhoto = nil
        }
    }
}
