"""Supabase client configuration and utilities."""

import os
from typing import Optional
from supabase import create_client, Client
from dotenv import load_dotenv

load_dotenv()


class SupabaseClient:
    """Singleton Supabase client."""

    _instance: Optional[Client] = None

    @classmethod
    def get_client(cls) -> Client:
        """Get or create Supabase client instance."""
        if cls._instance is None:
            url = os.getenv("SUPABASE_URL")
            key = os.getenv("SUPABASE_KEY")

            if not url or not key:
                raise ValueError("SUPABASE_URL and SUPABASE_KEY must be set in environment")

            cls._instance = create_client(url, key)

        return cls._instance

    @classmethod
    def reset(cls):
        """Reset the client instance (useful for testing)."""
        cls._instance = None


def get_supabase() -> Client:
    """Dependency for FastAPI routes."""
    return SupabaseClient.get_client()
