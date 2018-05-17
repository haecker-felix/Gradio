# Gradio 8.0 - Rust
This is Gradio - completely rewritten in Rust. This is just a experiment. **Maybe** this version will replace the Vala version of Gradio.

It is splitted into two parts:
- **Rustio** - Backend
  - Network communication
  - radio-browser.info API acess
  - Audio Playback
- **Gradio** - Frontend
  - GTK Interface
  - Desktop integration
  - Library management

####  Environment variables for Gradio
- **Debug output**: `RUST_LOG=rustio,gradio=debug`
- **Proxy**: `http_proxy=http://myproxy:80`