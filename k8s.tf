# Script permettant de déployer X VMs sur hôte Proxmox via Cloud-Init & Terraform

# Création variable pour nombre de VMs à déployer (récupéré via l'argument -var 'nombre=X')
variable "nombre" {
  type = number
  default = 1
}

variable "ci_password" {
  type = string
  sensitive = true
}

# Définition de la VM à créer
resource "proxmox_vm_qemu" "proxmox_vm" {
  count             = var.nombre
  name              = "k8s-worker-0${count.index}"
  vmid              = "21${count.index}"
  # Nom du node sur lequel le déploiement aura lieu
  target_node       = "paulinux-proxmox"
  clone             = "VM-Template-Alma"
  full_clone        = true
  os_type           = "cloud-init"
  cores             = 2
  sockets           = "1"
  cpu               = "host"
  memory            = 2048
  scsihw            = "virtio-scsi-pci"
  bootdisk          = "scsi0"
  ipconfig0         = "ip=192.168.1.21${count.index + 1}/24,gw=192.168.1.254"
  sshkeys           = <<EOT
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDAZJa0FgbRwLU2jg/UzLnuAgI7rZUbHOCj5Ye/E5ji/5Zv0d44N2IP2vZgBaiApnZtym2pQCYcqFK1e0ydFFfOUjyWag2ymXMpRVi67RdwXICvZX2iBFjso6oJ9zNwrKUwRlcsfZ/o+Dit4bjtMyPDnstGusbxpsM0AaYQoTZhBKElpQSGjkbbsrWjmKSta7qxmUjTg/z7jNIyAQfmmTTRmSAmxBF2Bc17a53oTNB5DcEUtLkcaA11aARuffFI7RFIzXNOz3M7YERclJP+oeuEE/GhkJZWIi/1UUWcRQqu0uObT8+/qa2EvjDiqu9XVVAwLZpmKQciUco6UA40DiqRmvMs3GNgWIbTNFIt/ozzokrFpftgd9S9tt8M1nPo0q73KOgeCfAekjVCW1efF0WVOO/yg4UN7cDsCGFRCFBJyf2v9DIgFFXR7LtdQXwpVrTgJ/XP3SO22fCWpQspEyv1m2tTE4KAj2Cg5zXFb6YRKJiakvADq6q6wmLaRxAnmvs= root@paulinux-proxmox
EOT

  ciuser           = "kube"
  cipassword       = var.ci_password
  searchdomain     = "paulinux.local"
  nameserver       = "192.168.1.254"

disk {
    #id              = 0
    size            = "32G"
    type            = "scsi"
    storage         = "local"
    #storage_type    = "lvm"
    #iothread        = true
  }
network {
    #id              = 0
    model           = "virtio"
    bridge          = "vmbr1"
  }

  provisioner "file" {
    source      = "startup.sh"
    destination = "/tmp/startup.sh"
      connection {
      type     = "ssh"
      user     = "kube"
      private_key     = "${file("~/.ssh/pve_client")}"
      host     = "192.168.1.21${count.index + 1}"
   }
  }
  # Exécution du script de démarrage
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/startup.sh",
      "/tmp/startup.sh",
    ]
    connection {
      type     = "ssh"
      user     = "kube"
      private_key     = "${file("~/.ssh/pve_client")}"
      host     = "192.168.1.21${count.index + 1}"
   }
  }

}