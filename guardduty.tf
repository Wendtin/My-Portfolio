provider "aws" {    
  region = "us-east-1"    
}    
    
# SABOTAGE: The radar is installed, but the power switch is flipped off.    
resource "aws_guardduty_detector" "primary_radar" {    
  enable                       = true    
  finding_publishing_frequency = "FIFTEEN_MINUTES"    
}    
