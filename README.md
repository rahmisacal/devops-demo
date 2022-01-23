Kubeadmn Windows Vagrant Installation Instructions 
===============

# Gereksinimler

1. virtualbox: https://www.virtualbox.org/wiki/Downloads
2. vagrant: https://www.vagrantup.com/downloads

# Vagrant-k8s

**cd /infra**

Vagrant sanal makine provizyonlamak için kullanılır. Vagrantfile içerisinde oluşturulacak sanal makinelerin konfigurasyonları yazılır ve **vagrant up** komutu ile makineler provizyonlanır. **vagrant destroy -f** komutu ile oluşturulan makineler silinir. Vagrantfile'ın olduğu dizinde bu komutlar çalıştırılır ve bu dizini oluşan makinelerin /vagrant dizini altına mount eder.

vagrant ile 3 makine üretip makinelerin içerisine ubuntu 20.04, docker ve kubernetes kuracağız.

Vagrantfile içerisinde üretilecek bu 3 makine konfigurasyonları ve bu makinelerde çalışacak common.sh, master.sh ve node.sh scriptleri çağrılmakta.

common.sh makinelere gerekli ubuntu, docker ve kubernetes paketlerini kurup her makinede olması gereken konfigürasyonları yapacak.

master.sh kubernetes cluster'ını oluşturacak.

node.sh ise kubernetes cluster'ına node'ları ekleyecek.

https://app.vagrantup.com/ubuntu/boxes/focal64 adresinden ubuntu focal imajı Vagrantfile'ın olduğu dizine indirilir.

**vagrant up** ile kurulumu başlattığımızda birden fazla interface bulursa aşağıdaki gibi bridged network interfaces'lardan birini seçmemizi isteyecek, 1 numarayı seçerek ilerleyebiliriz. 

    ==> node2: Available bridged network interfaces:
    1) Intel(R) Wi-Fi 6 AX200 160MHz
    2) Hyper-V Virtual Ethernet Adapter
    ==> node2: When choosing an interface, it is usually the one that is
    ==> node2: being used to connect to the internet.
    ==> node2:
        node2: Which interface should the network bridge to? **1**
    

vagrant ürettiği ilk makinenin 22 portunu 2222'ye, ikinci makineninkini 2200'e ve üçüncü makineninkini 2201'e forward eder.
makineler oluştuktan sonra örneğin hostname'i master olan bir makineye vagrant ssh master veya ssh vagrant@localhost -p 2222 -i .vagrant/machines/master/virtualbox/private_key komutları ile bağlanılabilir.

vagrantfile içerisinde oluşturulacak k8s cluster'ının node'larının 30000 portunu Vagrantfile sırasıyla host'un 1234 ve 1235 portlarına yönlendirdik ve node'ların 30000 portunda bir nginx kaldırıp(kubectl apply -f /vagrant/nginx.yml) http://localhost:1234 ve http://localhost:1235 adreslerinde nginx'in geldiğini göreceğiz ve clusterı test etmiş olacağız.

# Deploy devops tools

nginx örneğini kubernetes üzerinde deploy ettikten sonra kubectl apply -f /devops-apps/jenkins/ ve kubectl apply -f /devops-apps/nexus/ komutları ile jenkins ve nexus deployment edilir. Burada jenkins ui'dan gerekli pluginler (maven, kubernetes vs..) indirilip gerekli konfigürasyonların yapıldığını kabul ediyoruz.
her build için bir jenkins pod'u çalışıp, build işleminde bir tane jar/war dosyası nexus'a gidecek, yine pom.xml içinde görebileceğimiz **google jib plugini** ile jib build sonrası bir docker imajı da hedef registry'e gönderilecektir.
deployment ve webhook trigger için jenkins kullanmak yerine argocd tercih edebiliriz. kubectl apply -f /devops-apps/argocd/crd.yml komutu ile custom resource definition argocd objelerini ayağa kaldıracak ilgili secret dan şifre ile login olabileceğiz. 

# Deploy ve Webhook Trigger App

/devops-apps/argocd/projects/devops-demo.yml dosyası içinde gözükeceği üzere argocd default 3dk'da bir /springboot/deployment klasörü içindeki yml file'ları ilgili cluster'daki objeler ile kıyaslayıp yapılan her değişikliğin deployment'ını yapacaktır.