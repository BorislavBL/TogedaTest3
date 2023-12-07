import SwiftUI

extension View{
    /// - For Making it Simple and easy to use
    @ViewBuilder
    func frame(_ size: CGSize)->some View{
        self
            .frame(width: size.width, height: size.height)
    }
    
    /// - Haptic Feedback
    func haptics(_ style: UIImpactFeedbackGenerator.FeedbackStyle){
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}

struct CropPhotoView: View {
    @State var selectedImage: UIImage?
    @Binding var finalImage: Image?
    @Environment(\.dismiss) private var dismiss
    
    var crop: Crop
//    var onCrop: (UIImage?,Bool)->()
    
    /// - View Properties
    /// - Gesture Properties
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 0
    @State private var offset: CGSize = .zero
    @State private var lastStoredOffset: CGSize = .zero
    @GestureState private var isInteracting: Bool = false
    
    var body: some View{
        NavigationStack{
            ImageView()
                .navigationTitle("Crop View")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarBackground(Color.black, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .frame(maxWidth: .infinity,maxHeight: .infinity)
                .background {
                    Color.black
                        .ignoresSafeArea()
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            /// Converting View to Image (Native iOS 16+)
                            let renderer = ImageRenderer(content: ImageView(true))
                            renderer.proposedSize = .init(crop.size())
                            if let image = renderer.uiImage{
//                                onCrop(image,true)
                                finalImage = Image(uiImage: image)
                            }else{
//                                onCrop(nil,false)
                                finalImage = nil
                            }
                            dismiss()
                        } label: {
                            Image(systemName: "checkmark")
                                .font(.callout)
                                .fontWeight(.semibold)
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.callout)
                                .fontWeight(.semibold)
                        }
                    }
                }
        }
    }
    
    @ViewBuilder
    func ImageView(_ hideGrids: Bool = false)->some View{
        let cropSize = crop.size()
        GeometryReader{
            let size = $0.size
            
            if let selectedImage{
                Image(uiImage: selectedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .overlay(content: {
                        GeometryReader { proxy in
                            let rect = proxy.frame(in: .named("CROPVIEW"))
                            
                            Color.clear
                                .onChange(of: isInteracting) {oldValue, newValue in
                                    /// - true Dragging
                                    /// - false Stopped Dragging
                                    /// With the Help of GeometryReader
                                    /// We can now read the minX,Y and maxX,Y of the Image
                                    if !newValue{
                                        withAnimation(.easeInOut(duration: 0.2)){
                                            if rect.minX > 0{
                                                /// - Resetting to Last Location
                                                haptics(.medium)
                                                offset.width = (offset.width - rect.minX)
                                            }
                                            if rect.minY > 0{
                                                /// - Resetting to Last Location
                                                haptics(.medium)
                                                offset.height = (offset.height - rect.minY)
                                            }
                                            
                                            /// - Doing the Same for maxX,Y
                                            if rect.maxX < size.width{
                                                /// - Resetting to Last Location
                                                haptics(.medium)
                                                offset.width = (rect.minX - offset.width)
                                            }
                                            
                                            if rect.maxY < size.height{
                                                /// - Resetting to Last Location
                                                haptics(.medium)
                                                offset.height = (rect.minY - offset.height)
                                            }
                                        }
                                        
                                        /// - Storing Last Offset
                                        lastStoredOffset = offset
                                    }
                                }
                        }
                    })
                    .frame(size)
            }
        }
        .scaleEffect(scale)
        .offset(offset)
        .overlay(content: {
            /// We Don't Need Grid View for Cropped Image
            if !hideGrids{
                Grids()
            }
        })
        .coordinateSpace(name: "CROPVIEW")
        .gesture(
            DragGesture()
                .updating($isInteracting, body: { _, out, _ in
                    out = true
                }).onChanged({ value in
                    let translation = value.translation
                    offset = CGSize(width: translation.width + lastStoredOffset.width, height: translation.height + lastStoredOffset.height)
                })
        )
        .gesture(
            MagnificationGesture()
                .updating($isInteracting, body: { _, out, _ in
                    out = true
                }).onChanged({ value in
                    let updatedScale = value + lastScale
                    /// - Limiting Beyond 1
                    scale = (updatedScale < 1 ? 1 : updatedScale)
                }).onEnded({ value in
                    withAnimation(.easeInOut(duration: 0.2)){
                        if scale < 1{
                            scale = 1
                            lastScale = 0
                        }else{
                            lastScale = scale - 1
                        }
                    }
                })
        )
        .frame(cropSize)
        .cornerRadius(crop == .circle ? cropSize.height / 2 : 0)
    }
    
    /// - Grids
    @ViewBuilder
    func Grids()->some View{
        ZStack{
            HStack{
                ForEach(1...5,id: \.self){_ in
                    Rectangle()
                        .fill(.white.opacity(0.7))
                        .frame(width: 1)
                        .frame(maxWidth: .infinity)
                }
            }
            
            VStack{
                ForEach(1...8,id: \.self){_ in
                    Rectangle()
                        .fill(.white.opacity(0.7))
                        .frame(height: 1)
                        .frame(maxHeight: .infinity)
                }
            }
        }
    }
}

struct CropPhotoView_Previews: PreviewProvider {
    static var previews: some View {
        CropPhotoView(finalImage: .constant(Image("person_1")), crop: .custom(CGSize(width: 300, height: 500)))
    }
}
