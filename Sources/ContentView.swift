
import SwiftUI
import PencilKit

struct ContentView: View {
    var body: some View {
        Home()
    }
}

struct Home: View {

    @State var canvas = PKCanvasView()
    @State var color: Color = .black
    @State var type: PKInkingTool.InkType = .marker
    
    var body: some View {
        
        NavigationView {
            
            // Drawing View //
            DrawingView(canvas: $canvas, type: $type, color: $color)
                .navigationTitle("Stroke Matching")
                .font(.system(size: 35))
                .navigationBarTitleDisplayMode(.inline)
                .foregroundColor(Color.purple)
                // .navigationBarItems(
                //     leading: Button(
                //         action: {
                //             // Saving Image //
                //             saveImage()
                //         }, label: {
                //             Image(systemName: "square.and.arrow.down.fill")
                //             .font(.title)
                //             .foregroundColor(Color.orange)
                //         })
                // )
        }
    }
    
    func saveImage() {
        
        // getting image from Canvas
        
        let drawingData = canvas.drawing.dataRepresentation()
        
        // saving to file
        let fileManager = FileManager.default
        guard let documentDirectory = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            return
        }

        let fileURL = documentDirectory.appendingPathComponent("drawingFile.drawing")
        print("FILE", fileURL)
        
        do {
            try drawingData.write(to: fileURL)
        } 
        catch {
            print("catch error",error.localizedDescription)
        }
       
    }
}

struct DrawingView: UIViewRepresentable {

    @Binding var canvas: PKCanvasView
    @Binding var type: PKInkingTool.InkType
    @Binding var color: Color
    
    var ink: PKInkingTool {
        PKInkingTool(type, color: UIColor(color))
    }
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvas.delegate = context.coordinator
        canvas.drawingPolicy = .anyInput
        
        return canvas
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // updating the tool whenever the view updates
        uiView.tool = ink
    }

    func makeCoordinator() -> Coordinator {
        let backgroundDrawing = loadDrawing()
        let backgroundStrokes = (backgroundDrawing?.strokes.count ?? 0)
        if let drawing = backgroundDrawing {
            canvas.drawing = drawing
        }
        return Coordinator(self, backgroundDrawing, backgroundStrokes)
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: DrawingView
        var backgroundStrokes: Int = 0
        var correctStrokes: Int = 0
        var backgroundDrawing: PKDrawing?

        init(_ uiView: DrawingView, _ backgroundDrawing: PKDrawing?, _ backgroundStrokes: Int) {
            self.parent = uiView
            self.backgroundDrawing = backgroundDrawing
            self.backgroundStrokes = backgroundStrokes
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            let currentStrokes = canvasView.drawing.strokes.count - backgroundStrokes

            guard currentStrokes > 0 else {
                return
            }

            guard correctStrokes < backgroundStrokes else {
                return
            }

            guard let lastStroke = canvasView.drawing.strokes.last, let lastBackgroundStroke = backgroundDrawing?.strokes[correctStrokes] else { 
                return 
            }

            let maxPointCount: CGFloat = 50
            let minParametricStep: CGFloat = 0.2
            let stepSizeA = max(CGFloat(lastStroke.path.count) / maxPointCount, minParametricStep)
            let pathA = lastStroke.path.interpolatedPoints(by: .parametricStep(stepSizeA)).map {
                $0.location.applying(lastStroke.transform)
            }
            let stepSizeB = max(CGFloat(lastBackgroundStroke.path.count) / maxPointCount, minParametricStep)
            let pathB = lastBackgroundStroke.path.interpolatedPoints(by: .parametricStep(stepSizeB)).map { 
                $0.location.applying(lastBackgroundStroke.transform) 
            }
            
            // Compute the discrete Fréchet distance.
            let countA: Int32 = Int32(pathA.count)
            let countB: Int32 = Int32(pathB.count)

            guard countA > 0 && countB > 0 else { return }

            // Stroke matching.
            let passFrechetDistance = StrokeMatchingWrapper.passFrechetDistance(pathA, countA: countA, pointsB: pathB, countB: countB)

            if passFrechetDistance {
                correctStrokes += 1
                print("pass")
            } else {
                print("no_pass")
                if correctStrokes > 0 {
                    correctStrokes -= 1
                }
                canvasView.drawing.strokes.removeLast()
            }
            
            if correctStrokes == backgroundStrokes {
                print("FINISH")
                canvasView.drawingGestureRecognizer.isEnabled = false
            }
        }
    }

    func loadDrawing() -> PKDrawing? {  

        let fileManager = FileManager.default 

		guard let path = Bundle.main.path(forResource: "MainResources", ofType: "bundle"), 
            let resourceBundle = Bundle(path: path) else {
                return nil
		}

        guard let resourcePath = resourceBundle.path(forResource: "test", ofType: "drawing") else {
            return nil
        }

        guard let data = fileManager.contents(atPath: resourcePath), var drawing = try? PKDrawing(data: data) else { 
            return nil
        }

        drawing.strokes = drawing.strokes.map { stroke -> PKStroke in
            // Modify the strokes to have the correct color.
            var stroke = stroke
            stroke.ink = PKInk(.marker, color: .red)
            return stroke
        }
        
        return drawing
    }
}