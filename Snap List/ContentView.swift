import SwiftUI
import Vision
import CoreML
import UIKit
struct ContentView: View {
    @State private var itemName = ""
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var selectedImage: UIImage?
    @State private var isImagePickerDisplay = false
    @State private var snappedItems: [String] = (UserDefaults.standard.stringArray(forKey: "snappedItemsArray") ?? [])
    @State private var showConfirmationSheet = false
    @State private var detectedItem = ""
    @State private var nameSelection: NameSelection = .detected
    @State private var customName: String = ""
    enum NameSelection {
        case detected
        case custom
    }
    var body: some View {
        NavigationStack {
            VStack {
                if snappedItems.count == 0 {
                    Section {
                        Text("You have no items in your snapped list!")
                    }
                } else {
                    List {
                        Section {
                            ForEach(snappedItems.indices, id: \.self) { index in
                                Text("\(index + 1). \(self.snappedItems[index])")
                            }
                                .onDelete(perform: deleteItem)
                        }
                    }
                }
                if selectedImage != nil {
                    Group { }
                        .onChange(of: selectedImage) { newValue in
                        guard let newImage = newValue else {
                            fatalError("Error loading new image")
                        }
                        detect(newImage)
                    }
                }
            }
                .navigationBarTitle("Snap List")
                .toolbar {
                Button {
                    self.isImagePickerDisplay.toggle()
                } label: {
                    Image(systemName: "plus")
                }
            }
                .sheet(isPresented: self.$isImagePickerDisplay, onDismiss: {
                print("detectedItem-L> \(detectedItem)")
                showConfirmationSheet.toggle()
            }) {
                ImagePickerView(selectedImage: self.$selectedImage, sourceType: self.sourceType)
            }
                .sheet(isPresented: self.$showConfirmationSheet) {
                VStack {
                    if let uiimage = selectedImage {
                        Image(uiImage: uiimage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 300, height: 300)
                            .onAppear {
                            detect(uiimage)
                        }
                            .onChange(of: selectedImage) { newValue in
                            guard let newImage = newValue else {
                                fatalError("Error loading new image")
                            }
                            detect(newImage)
                        }
                    }
                    Form {
                        Section(header: Text("Add Item")) {
                            Picker("Name", selection: $nameSelection) {
                                Text("\(detectedItem)").tag(NameSelection.detected)
                                Text("Custom").tag(NameSelection.custom)
                            }

                            if nameSelection == .custom {
                                TextField("Custom Name", text: $customName)
                            }

                            Button(action: addItem) {
                                Text("Add to List")
                            }
                        }
                    }
                }
            }
        }
    }
    func addItem() {
        let newItem: String
        switch nameSelection {
        case .detected:
            newItem = detectedItem
        case .custom:
            newItem = customName
        }
        snappedItems.append(newItem)
        UserDefaults.standard.set(snappedItems, forKey: "snappedItemsArray")
        customName = ""
        showConfirmationSheet.toggle()
    }
    func deleteItem(at offsets: IndexSet) {
        snappedItems.remove(atOffsets: offsets)
        UserDefaults.standard.set(snappedItems, forKey: "snappedItemsArray")
    }
    private func detect(_ image: UIImage) {
        guard let CIImage = CIImage(image: image) else {
            fatalError("Cannot convert to CIImage")
        }
        guard let model = try? VNCoreMLModel(for: SqueezeNet().model) else {
            fatalError("Cannot detect ML Model")
        }
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let result = request.results as? [VNClassificationObservation] else {
                fatalError("Cannot get result")
            }

            if let first = result.first {
                detectedItem = first.identifier.components(separatedBy: ", ")[0].capitalized
            }
        }
        let handler = VNImageRequestHandler(ciImage: CIImage)
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
}
struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var isPresented
    var sourceType: UIImagePickerController.SourceType
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = self.sourceType
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(picker: self)
    }
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var picker: ImagePickerView
        @Environment(\.presentationMode) var isPresented
        init(picker: ImagePickerView) {
            self.picker = picker
        }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            guard let selectedImage = info[.originalImage] as? UIImage else { return }
            self.picker.selectedImage = selectedImage
            self.picker.isPresented.wrappedValue.dismiss()
        }
    }
}
