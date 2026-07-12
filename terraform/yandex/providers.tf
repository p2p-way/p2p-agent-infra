# Providers
provider "archive" {
}

provider "cloudinit" {
}

provider "tls" {
}

provider "http" {
}

# Russia
provider "yandex" {
}

# Kazakhstan
provider "yandex" {
  alias            = "kz1"
  zone             = "kz1-a"
  endpoint         = "api.yandexcloud.kz:443"
  storage_endpoint = "https://storage.yandexcloud.kz"
}
