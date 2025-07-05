//
//  WebGIFView.swift
//  AudioConverter
//
//  Created by Max on 04.07.2025.
//

import SwiftUI
import WebKit

struct WebGIFView: UIViewRepresentable {
    let gifURL: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = .clear
        webView.isOpaque = false
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Prepare HTML string with CSS for aspect fit
        let gifPath = gifURL.absoluteString

        let html = """
        <html>
          <head>
            <style>
              body, html {
                margin: 0; padding: 0; background: transparent;
                height: 100%; width: 100%;
                display: flex;
                justify-content: center;
                align-items: center;
              }
              img {
                max-width: 100%;
                max-height: 100%;
                height: auto;
                object-fit: contain;
              }
            </style>
          </head>
          <body>
            <img src="\(gifPath)" />
          </body>
        </html>
        """

        uiView.loadHTMLString(html, baseURL: gifURL.deletingLastPathComponent())
    }
}
