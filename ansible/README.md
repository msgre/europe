# How to start europe project on Digital ocean

* Create Droplet on Digital Ocean
  - Ubuntu 14.04.3 x64
  - $5/months
  - Amsterdam 3
  - Michal SSH key
  - hostname "europe"

* Set IP address of Droplet into `hosts` file (copy `hosts.example` to `hosts` 
  and edit it)

* Run ansible playbook

    ansible-playbook bootstrap.yml -i hosts

  (answer yes to SSH question about key)

* SSH into droplet (`ssh root@<IP>`) and start `~/europe/start.sh`

* Optionaly: set A record on your domain to to droplet IP

* Visit URL `http://<your_domain_OR_drople_IP>/europe_01.html`
