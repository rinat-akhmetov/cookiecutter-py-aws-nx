"""Hello unit test module."""

from src.app import lambda_handler


def test_hello():
    """Test the hello function."""
    event = {"prompt": "Hello, how are you?"}
    context = {}

    assert (
        lambda_handler(event, context)["llm_output"]
        == "LLM Response based on prompt: Hello, how are you?"
    )
