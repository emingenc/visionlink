# Socket Python Example

This example demonstrates a remote server implementation that tracks transactions from G1 Smart Glasses and sends corresponding responses.

## Requirements

```bash
pip3 install -r requirements.txt
```
## Environment Setup

Create a `.env` file based on the provided `.env.example`:

```bash
cp .env.example .env
```

Update the `.env` file with your credentials:
```
EMAIL=your_email@example.com    # Email used in Android app signup
PASSWORD=your_password          # Password used in Android app signup
```
## Usage

Run the server:

```bash
python3 main.py
```

## Description

This server:
- Listens for WebSocket connections from G1 Smart Glasses
- Tracks incoming transactions and events
- Processes the received data
- Sends appropriate responses back to the glasses

The server acts as a monitoring system to maintain communication with VisionLink-enabled G1 Smart Glasses and handle their transaction events in real-time.