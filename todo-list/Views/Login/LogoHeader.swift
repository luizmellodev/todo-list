import SwiftUI

struct LogoHeader: View {
    var body: some View {
        VStack(spacing: 10) {
            Image("newicon")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.white)
            
            HStack {
                Text("Tickr:")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("Todo list!")
                    .font(.title)
                    .fontWeight(.thin)
                    .foregroundColor(.white)
            }
        }
    }
}

