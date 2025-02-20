from src.app import lambda_handler


def test_positive_sentiment():
    event = {"llm_output": "This is a good response"}
    result = lambda_handler(event, {})

    assert result["sentiment"] == "positive"
    assert result["analyzed_text"] == event["llm_output"]


def test_negative_sentiment():
    event = {"llm_output": "This is a bad outcome"}
    result = lambda_handler(event, {})

    assert result["sentiment"] == "negative"
    assert result["analyzed_text"] == event["llm_output"]


def test_neutral_sentiment():
    event = {"llm_output": "This is a neutral statement"}
    result = lambda_handler(event, {})

    assert result["sentiment"] == "neutral"
    assert result["analyzed_text"] == event["llm_output"]


def test_empty_input():
    event = {"llm_output": ""}
    result = lambda_handler(event, {})

    assert result["sentiment"] == "neutral"
    assert result["analyzed_text"] == ""
