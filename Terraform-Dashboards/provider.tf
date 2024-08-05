terraform {
  required_providers {
    newrelic = {
      source = "newrelic/newrelic"
      version = "3.40.1"
    }
  }
}

provider "newrelic" {
  # Configuration options
  account_id = "4510907"
  api_key = "NRAK-BCQ0CCD3QRJVPZPAZIW0WTIE35I"

}