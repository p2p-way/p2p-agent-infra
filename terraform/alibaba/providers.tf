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

# Agent - Japan (Tokyo)
provider "alicloud" {
  alias  = "ap-northeast-1"
  region = "ap-northeast-1"
}

# Agent - South Korea (Seoul)
provider "alicloud" {
  alias  = "ap-northeast-2"
  region = "ap-northeast-2"
}

# Agent - Singapore
provider "alicloud" {
  alias  = "ap-southeast-1"
  region = "ap-southeast-1"
}

# Agent - Malaysia (Kuala Lumpur)
provider "alicloud" {
  alias  = "ap-southeast-3"
  region = "ap-southeast-3"
}

# Agent - Indonesia (Jakarta)
provider "alicloud" {
  alias  = "ap-southeast-5"
  region = "ap-southeast-5"
}

# Agent - Philippines (Manila)
provider "alicloud" {
  alias  = "ap-southeast-6"
  region = "ap-southeast-6"
}

# Agent - Thailand (Bangkok)
provider "alicloud" {
  alias  = "ap-southeast-7"
  region = "ap-southeast-7"
}

# Agent - China (Beijing)
provider "alicloud" {
  alias  = "cn-beijing"
  region = "cn-beijing"
}

# Agent - China (Chengdu)
provider "alicloud" {
  alias  = "cn-chengdu"
  region = "cn-chengdu"
}

# Agent - China (Fuzhou - Local Region)
provider "alicloud" {
  alias  = "cn-fuzhou"
  region = "cn-fuzhou"
}

# Agent - China (Guangzhou)
provider "alicloud" {
  alias  = "cn-guangzhou"
  region = "cn-guangzhou"
}

# Agent - China (Hangzhou)
provider "alicloud" {
  alias  = "cn-hangzhou"
  region = "cn-hangzhou"
}

# Agent - China (Heyuan)
provider "alicloud" {
  alias  = "cn-heyuan"
  region = "cn-heyuan"
}

# Agent - China (Hong Kong)
provider "alicloud" {
  alias  = "cn-hongkong"
  region = "cn-hongkong"
}

# Agent - China (Hohhot)
provider "alicloud" {
  alias  = "cn-huhehaote"
  region = "cn-huhehaote"
}

# Agent - China (Nanjing - Local Region)
provider "alicloud" {
  alias  = "cn-nanjing"
  region = "cn-nanjing"
}

# Agent - China (Qingdao)
provider "alicloud" {
  alias  = "cn-qingdao"
  region = "cn-qingdao"
}

# Agent - China (Shanghai)
provider "alicloud" {
  alias  = "cn-shanghai"
  region = "cn-shanghai"
}

# Agent - China (Shenzhen)
provider "alicloud" {
  alias  = "cn-shenzhen"
  region = "cn-shenzhen"
}

# Agent - China (Wuhan - Local Region)
provider "alicloud" {
  alias                  = "cn-wuhan-lr"
  region                 = "cn-wuhan-lr"
  skip_region_validation = true
}

# Agent - China (Ulanqab)
provider "alicloud" {
  alias  = "cn-wulanchabu"
  region = "cn-wulanchabu"
}

# Agent - China (Zhangjiakou)
provider "alicloud" {
  alias  = "cn-zhangjiakou"
  region = "cn-zhangjiakou"
}

# Agent - Germany (Frankfurt)
provider "alicloud" {
  alias  = "eu-central-1"
  region = "eu-central-1"
}

# Agent - UK (London)
provider "alicloud" {
  alias  = "eu-west-1"
  region = "eu-west-1"
}

# Agent - SAU (Riyadh - Partner Region)
provider "alicloud" {
  alias  = "me-central-1"
  region = "me-central-1"
}

# Agent - UAE (Dubai)
provider "alicloud" {
  alias  = "me-east-1"
  region = "me-east-1"
}

# Agent - Mexico
provider "alicloud" {
  alias  = "na-south-1"
  region = "na-south-1"
}

# Agent - US (Virginia)
provider "alicloud" {
  alias  = "us-east-1"
  region = "us-east-1"
}

# Agent - US (Silicon Valley)
provider "alicloud" {
  alias  = "us-west-1"
  region = "us-west-1"
}
