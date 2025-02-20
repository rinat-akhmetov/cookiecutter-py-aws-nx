from typing import Any


def lambda_handler(event: dict[str, Any], context: Any) -> dict[str, Any]:
    # Retrieve the output from the LLM function
    llm_output = event.get("llm_output", "")

    # Simulate a simple sentiment analysis by checking for keywords
    if "good" in llm_output.lower():
        sentiment = "positive"
    elif "bad" in llm_output.lower():
        sentiment = "negative"
    else:
        sentiment = "neutral"

    # Return the analyzed sentiment along with the original LLM output
    return {"analyzed_text": llm_output, "sentiment": sentiment}
