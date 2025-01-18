# Vision Link - Core OS for Even Realities G1

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

## Thanks
Special thanks to @meyskens and her repository [fahrplan](https://github.com/meyskens/fahrplan) for the uptodate G1 bluetooth commands. 

