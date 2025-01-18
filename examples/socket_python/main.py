import asyncio
import os
from realtime import AsyncRealtimeClient, RealtimeSubscribeStates
from dotenv import load_dotenv
from typing import Optional
from supabase import create_client, Client

load_dotenv()

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_ANON_KEY")

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)


email = os.getenv("SUPABASE_USER_EMAIL")
password = os.getenv("SUPABASE_USER_PASSWORD")

# login
auth_response = supabase.auth.sign_in_with_password(
    {"email": email, "password": password}
)


if not auth_response.session:
    raise Exception("Login failed. Please check your credentials.")
else:
    print("Logged in successfully")


def handle_callback(payload):
    print("Received payload:", payload)


def _on_subscribe(status: RealtimeSubscribeStates, err: Optional[Exception]):
    if status == RealtimeSubscribeStates.SUBSCRIBED:
        print("Connected!")
    elif status == RealtimeSubscribeStates.CHANNEL_ERROR:
        print(f"There was an error subscribing to channel: {err.message}")
    elif status == RealtimeSubscribeStates.TIMED_OUT:
        print("Realtime server did not respond in time.")
    elif status == RealtimeSubscribeStates.CLOSED:
        print("Realtime channel was unexpectedly closed.")


async def on_postgres_changes(socket):
    await socket.connect()
    channel = socket.channel("visionlink")
    await channel.on_postgres_changes(
        "*", table="transcriptions", schema="public", callback=handle_callback
    ).subscribe(_on_subscribe)
    print("Listening for changes")
    await socket.listen()


async def main():
    socket = AsyncRealtimeClient(
        url=f"{SUPABASE_URL}/realtime/v1", token=SUPABASE_KEY, auto_reconnect=True
    )
    await socket.set_auth(auth_response.session.access_token)
    await on_postgres_changes(socket)


if __name__ == "__main__":
    asyncio.run(main())
