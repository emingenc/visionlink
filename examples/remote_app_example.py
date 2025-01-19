import streamlit as st
from supabase import create_client, Client
from dotenv import load_dotenv
load_dotenv()

st.set_page_config(page_title="Realtime App")
st.title("Realtime Transactions")

supabase_url = "YOUR_SUPABASE_URL"
supabase_key = "YOUR_SUPABASE_ANON_KEY"
supabase: Client = create_client(supabase_url, supabase_key)

if "logged_in" not in st.session_state:
    st.session_state["logged_in"] = False

if not st.session_state["logged_in"]:
    with st.form("Login"):
        email = st.text_input("Email")
        password = st.text_input("Password", type="password")
        if st.form_submit_button("Login"):
            try:
                auth_response = supabase.auth.sign_in(email=email, password=password)
                if auth_response:
                    st.session_state["logged_in"] = True
            except Exception:
                st.write("Login failed")
else:
    st.write("Logged in!")
    def handle_realtime(msg):
        st.write("Realtime update:", msg)
    supabase.realtime.subscribe("transactions", callback=handle_realtime)
    st.write("Listening for transactions updates in real-time.")
