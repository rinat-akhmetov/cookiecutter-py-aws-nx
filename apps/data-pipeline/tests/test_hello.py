"""Hello unit test module."""

from apps_data_pipeline.hello import hello


def test_hello():
    """Test the hello function."""
    assert hello() == "Hello apps-data-pipeline"
