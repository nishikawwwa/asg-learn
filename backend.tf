terraform {
  backend "s3" {
    bucket  = "terraform-nishikawa"
    key     = "asg"
    region  = "ap-northeast-1"
    profile = "akarin"
  }
}
