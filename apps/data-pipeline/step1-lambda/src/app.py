from typing import Any


def lambda_handler(event: dict[str, Any], context: Any) -> dict[str, Any]:
    # Extract prompt from the incoming event; use a default prompt if none is provided
    prompt = event.get("prompt", "Hello, how are you?")

    # Simulate LLM response (in practice, call your LLM API here)
    generated_text = f"LLM Response based on prompt: {prompt}"

    # Return the LLM output as part of the response payload
    return {"llm_output": generated_text}
