# Vision Link - Core OS for Even Realities G1

VisionLink is an open-source operating system for device-to-device communication, powered by Supabase. Think of it as a neural network for your IoT devices - they listen, think, and respond autonomously.

## What is VisionLink?

- 🔄 **Real-time Device Orchestra**: Your devices subscribe to a shared channel, working together like a well-coordinated team
- 🔐 **Secure**: Built on Supabase authentication and real-time capabilities
- 🤖 **Proactive**: Devices intelligently determine their responsibilities and respond automatically (in progress)

## How It Works

1. Devices connect to VisionLink using Supabase authentication
2. Each device subscribes to the transcription channel
3. When a transcription arrives, devices evaluate if they should respond
4. Responsible device(s) execute commands by inserting into device_commands

Example: When G1 glasses detect a "lights" command, your smart bulbs know they're responsible and automatically handle the request.

[Getting Started →](#getting-started)

This application is a Supabase-based life assistant designed specifically for the Even Realities G1 smartglasses. It leverages Supabase Auth and real-time features to orchestrate communication between G1 and various IoT devices, allowing automation, notifications, and commands to be synchronized seamlessly.

## Key Features
- Supabase Auth for secure user management.
- Real-time communication with IoT devices.
- Notification and text forwarding to G1 glasses.
- Core OS functionality for G1.

## Supabase Setup
1. Copy the example environment file:
```bash
cp env_example .env
```
2. Fill in the necessary environment variables in your new .env file.
3. Populate Supabase using the instructions and SQL files in the supabase folder. For example:
```bash
supabase db push --schema-only
```

## Getting Started

1. Set up Supabase:
    - Create a new Supabase project
    - Push the schema to your project
    - Copy your project URL and anon key
    - Update `.env` with these credentials

2. Install the Flutter app:
    - Clone the repository
    - Run `flutter pub get`
    - Build and install on your phone
    - Sign up using Supabase auth

3. Test the communication flow:
    - Run the example socket listener:
      ```bash
      cd examples/socket_python
      python main.py
      ```
    - Perform a left tap hold on G1 glasses
    - Observe the transaction in Supabase
    - The Python script will process and create device commands
    - Commands will be synced to G1 glasses

4. Extend functionality:
    - Add new IoT devices by creating handlers
    - Define custom commands in device_commands table
    - Process transactions with LLMs for automated responses

## Thanks
Special thanks to @meyskens and her repository [fahrplan](https://github.com/meyskens/fahrplan) for the uptodate G1 bluetooth commands. 

