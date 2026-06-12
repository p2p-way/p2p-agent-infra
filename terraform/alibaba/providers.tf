# Providers
provider "archive" {
}

provider "cloudinit" {
}

provider "random" {
}

provider "time" {
}

provider "tls" {
}

# Japan (Tokyo)
provider "alicloud" {
  alias  = "ap-northeast-1"
  region = "ap-northeast-1"
}

# South Korea (Seoul)
provider "alicloud" {
  alias  = "ap-northeast-2"
  region = "ap-northeast-2"
}

# Singapore
provider "alicloud" {
  alias  = "ap-southeast-1"
  region = "ap-southeast-1"
}

# Malaysia (Kuala Lumpur)
provider "alicloud" {
  alias  = "ap-southeast-3"
  region = "ap-southeast-3"
}

# Indonesia (Jakarta)
provider "alicloud" {
  alias  = "ap-southeast-5"
  region = "ap-southeast-5"
}

# Philippines (Manila)
provider "alicloud" {
  alias  = "ap-southeast-6"
  region = "ap-southeast-6"
}

# Thailand (Bangkok)
provider "alicloud" {
  alias  = "ap-southeast-7"
  region = "ap-southeast-7"
}

# Malaysia (Johor)
provider "alicloud" {
  alias                  = "ap-southeast-8"
  region                 = "ap-southeast-8"
  skip_region_validation = true
}

# China (Beijing)
provider "alicloud" {
  alias  = "cn-beijing"
  region = "cn-beijing"
}

# China (Chengdu)
provider "alicloud" {
  alias  = "cn-chengdu"
  region = "cn-chengdu"
}

# China (Fuzhou - Local Region)
provider "alicloud" {
  alias  = "cn-fuzhou"
  region = "cn-fuzhou"
}

# China (Guangzhou)
provider "alicloud" {
  alias  = "cn-guangzhou"
  region = "cn-guangzhou"
}

# China (Hangzhou)
provider "alicloud" {
  alias  = "cn-hangzhou"
  region = "cn-hangzhou"
}

# China (Heyuan)
provider "alicloud" {
  alias  = "cn-heyuan"
  region = "cn-heyuan"
}

# China (Hong Kong)
provider "alicloud" {
  alias  = "cn-hongkong"
  region = "cn-hongkong"
}

# China (Hohhot)
provider "alicloud" {
  alias  = "cn-huhehaote"
  region = "cn-huhehaote"
}

# China (Nanjing - Local Region)
provider "alicloud" {
  alias  = "cn-nanjing"
  region = "cn-nanjing"
}

# China (Qingdao)
provider "alicloud" {
  alias  = "cn-qingdao"
  region = "cn-qingdao"
}

# China (Shanghai)
provider "alicloud" {
  alias  = "cn-shanghai"
  region = "cn-shanghai"
}

# China (Shenzhen)
provider "alicloud" {
  alias  = "cn-shenzhen"
  region = "cn-shenzhen"
}

# China (Wuhan - Local Region)
provider "alicloud" {
  alias                  = "cn-wuhan-lr"
  region                 = "cn-wuhan-lr"
  skip_region_validation = true
}

# China (Ulanqab)
provider "alicloud" {
  alias  = "cn-wulanchabu"
  region = "cn-wulanchabu"
}

# China (Zhangjiakou)
provider "alicloud" {
  alias  = "cn-zhangjiakou"
  region = "cn-zhangjiakou"
}

# China (Zhongwei)
provider "alicloud" {
  alias  = "cn-zhongwei"
  region = "cn-zhongwei"
}

# Germany (Frankfurt)
provider "alicloud" {
  alias  = "eu-central-1"
  region = "eu-central-1"
}

# UK (London)
provider "alicloud" {
  alias  = "eu-west-1"
  region = "eu-west-1"
}

# France‌ (Paris)
provider "alicloud" {
  alias                  = "eu-west-2"
  region                 = "eu-west-2"
  skip_region_validation = true
}

# SAU (Riyadh - Partner Region)
provider "alicloud" {
  alias  = "me-central-1"
  region = "me-central-1"
}

# UAE (Dubai)
provider "alicloud" {
  alias  = "me-east-1"
  region = "me-east-1"
}

# Mexico
provider "alicloud" {
  alias                  = "na-south-1"
  region                 = "na-south-1"
  skip_region_validation = true
}

# US (Virginia)
provider "alicloud" {
  alias  = "us-east-1"
  region = "us-east-1"
}

# US (Silicon Valley)
provider "alicloud" {
  alias  = "us-west-1"
  region = "us-west-1"
}
