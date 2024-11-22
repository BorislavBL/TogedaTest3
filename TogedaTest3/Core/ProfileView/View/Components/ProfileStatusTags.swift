//
//  ProfileStatusTags.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 18.11.24.
//

import SwiftUI

struct ProfileStatusTags: View {
    var body: some View {
        AmbassadorTag()
    }
}

struct AmbassadorTag: View {
    var body: some View {
        HStack{
            AmbassadorSealMini()

            Text("Ambassador")
                .bold()
                .font(.footnote)
        }
        .foregroundStyle(
            CommodityColor.gold.linearGradient
        )
        .frame(height: 16)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background{Capsule().fill(Color("main-secondary-color"))}
        .overlay( // Add the stroke border here
            Capsule()
                .stroke(
                    CommodityColor.gold.linearGradient
                )
        )
    }
}


struct AmbassadorSeal: View {
    var body: some View {
        ZStack{
            Image(systemName: "seal.fill")
                .font(.title3)
                .foregroundStyle(
                    CommodityColor.gold.linearGradient
                )

            Text("A")
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .font(.footnote)
                .foregroundStyle(
                    .white
                )
        }
    }
}

struct AmbassadorSealMini: View {
    var body: some View {
        ZStack{
            Image(systemName: "seal.fill")
                .font(.custom("", size: 15))
                .foregroundStyle(
                    CommodityColor.gold.linearGradient
                )

            Text("A")
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .font(.custom("", size: 9))
                .foregroundStyle(
                    .white
                )
        }
    }
}

struct AmbassadorSealMiniature: View {
    var body: some View {
        ZStack{
            Image(systemName: "seal.fill")
                .font(.custom("", size: 13))
                .foregroundStyle(
                    CommodityColor.gold.linearGradient
                )

            Text("A")
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .font(.custom("", size: 7))
                .foregroundStyle(
                    .white
                )
        }
    }
}

struct PartnerTag: View {
    var body: some View {
        HStack{
            PartnerSealMini()

            Text("Partner")
                .bold()
                .font(.footnote)
        }
        .foregroundStyle(
            CommodityColor.silver.linearGradient
        )
        .frame(height: 16)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background{Capsule().fill(Color("main-secondary-color"))}
        .overlay( // Add the stroke border here
            Capsule()
                .stroke(
                    CommodityColor.silver.linearGradient
                )
        )
    }
}


struct PartnerSeal: View {
    var body: some View {
        ZStack{
            Image(systemName: "seal.fill")
                .font(.title3)
                .foregroundStyle(
                    CommodityColor.silver.linearGradient
                )

            Text("P")
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .font(.footnote)
                .foregroundStyle(
                    .white
                )
        }
    }
}

struct PartnerSealMini: View {
    var body: some View {
        ZStack{
            Image(systemName: "seal.fill")
                .font(.custom("", size: 15))
                .foregroundStyle(
                    CommodityColor.silver.linearGradient
                )

            Text("P")
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .font(.custom("", size: 9))
                .foregroundStyle(
                    .white
                )
        }
    }
}

struct PartnerSealMiniature: View {
    var body: some View {
        ZStack{
            Image(systemName: "seal.fill")
                .font(.custom("", size: 13))
                .foregroundStyle(
                    CommodityColor.silver.linearGradient
                )

            Text("P")
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .font(.custom("", size: 7))
                .foregroundStyle(
                    .white
                )
        }
    }
}

#Preview {
    ProfileStatusTags()
}


