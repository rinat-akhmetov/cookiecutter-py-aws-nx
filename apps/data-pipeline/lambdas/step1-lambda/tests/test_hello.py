"""Hello unit test module."""

from data_pipeline_lambdas_step1_lambda.hello import hello


def test_hello():
    """Test the hello function."""
    assert hello() == "Hello data-pipeline-lambdas-step1-lambda"
