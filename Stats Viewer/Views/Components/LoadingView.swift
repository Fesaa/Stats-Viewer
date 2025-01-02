import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Loading...")
                .font(.headline)
                .foregroundColor(.gray)
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .padding()
            Spacer()
        }
    }
}
