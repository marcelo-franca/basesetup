# Class: basesetup
# This class will be install base packages and
# configure /etc/hosts 
#
class basesetup {
  include basesetup::packages
  include basesetup::hosts
}
