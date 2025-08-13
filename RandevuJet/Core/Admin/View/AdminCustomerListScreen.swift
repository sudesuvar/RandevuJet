//
//  AdminCustomerListScreen.swift
//  RandevuJet
//
//  Created by sude on 12.08.2025.
//

import SwiftUI

public struct AdminCustomerListScreen: View {
    @EnvironmentObject var adminViewModel: AdminViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var searchText = ""
    
    public var body: some View {
        List(filteredCustomers) { customer in
            VStack(alignment: .leading) {
                Text(customer.fullName)
                    .font(.headline)
                Text(customer.phone)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
        .navigationTitle("Müşteri Listesi")
        .searchable(text: $searchText, prompt: "Müşteri ara")
        .onAppear {
            Task {
                if let hairdresserId = authViewModel.currentHairdresser?.id {
                    await adminViewModel.fetchCustomers(hairdresserId: hairdresserId)
                }
            }
        }
    }
    
    // MARK: - Filtrelenmiş ve Sıralı Müşteri Listesi
    private var filteredCustomers: [Customer] {
        let sortedCustomers = adminViewModel.customers.sorted { $0.fullName < $1.fullName }
        if searchText.isEmpty {
            return sortedCustomers
        } else {
            return sortedCustomers.filter {
                $0.fullName.localizedCaseInsensitiveContains(searchText) ||
                $0.phone.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

#Preview {
    AdminCustomerListScreen()
        .environmentObject(AdminViewModel())
        .environmentObject(AuthViewModel())
}
