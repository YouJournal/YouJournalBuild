//
//  AWSCredentials.swift
//  YouJournal
//
//  Created by Luke Trotman on 22/3/2024.
//

import AWSS3

struct AWSCredentials {
    static let accessKeyId = "AKIA47CRY7LG6LZUZ5S6"
    static let secretAccessKey = "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"
}

class AWSManager {
    static let shared = AWSManager()
    
    private init() {
        // Configure the AWSS3 library with your AWS credentials and region
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: "AKIA47CRY7LG6LZUZ5S6", secretKey: "lwcgYnLEw9Huuf4dNntMdUe8yCvNuk2iqJ8n4skj")
        let configuration = AWSServiceConfiguration(region: .EUWest2, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
}
