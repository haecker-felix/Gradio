# Gradio 8.0 - Rust
This is Gradio - completely rewritten in Rust. This is just a experiment. **Maybe** this version will replace the Vala version of Gradio.

It is splitted into two parts:
- **Rustio** - radio-browser API
  - Network communication
  - radio-browser.info API acess

- **Gradio**
  - GTK Interface
  - Desktop integration
  - Library management
  - Audio Playback

####  Environment variables for Gradio
- **Debug output**: `RUST_LOG=rustio,gradio=debug`
- **Proxy**: `http_proxy=http://myproxy:80`